---
sidebar_position: 4
---

# Select Builders

Tether provides a system for building queries that conform to both Supabase and
SQLite syntax. This allows you to construct complex queries in a simplified,
Dart-compliant, and composable manner. All queries return
`TetherClientReturn<TModel>` objects that include both data and metadata.

## Column Enums

Tether generates enums for each table in your database. These enums represent
the columns in the table and can be used to construct queries.

For the following table:

```sql
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    publication_date DATE,
    price NUMERIC(10, 2), -- Example of a NUMERIC field for precise decimal values
    stock_count INTEGER DEFAULT 0, -- Example of an INTEGER field
    cover_image_id UUID REFERENCES images(id) ON DELETE SET NULL, -- Foreign key to images
    banner_image_id UUID REFERENCES images(id) ON DELETE SET NULL, -- Foreign key to images
    author_id UUID REFERENCES authors(id) ON DELETE SET NULL, -- Foreign key to authors
    metadata JSONB, -- Example of a JSONB field for storing arbitrary metadata
    tags TEXT[], -- Example of an array field for storing tags
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    document tsvector -- Column for full-text search
);
```

Would generate a `BooksColumns` enum, which is used in the select builders to
reference the columns in the `books` table. This allows you to reference columns
for both Supabase and SQLite like `BooksColumn.id.originalName` or
`BooksColumn.id.localName`.

## Select Builders

A Select Builder is a helper class that will allow you to construct the select
string for your queries to be consumed by the Supabase API or SQLite, managing
the data you want to fetch from the database. These will mostly be used by the
Managers when building a query.

It's recommended that you define all the select statements you need in a single
file that you can reference in your code. The select builder system is very
flexible, allowing you to assemble complex queries with relationships.

## Basic Usage

Use the .select() method to specify the columns you want to fetch.

```dart
final bookSelectAll = BooksSelectBuilder().select();
```

If you call select without any arguments, it will select all columns. This will
pass `'*'` into the select method in the Supabase API when built.

Passing in an array of [BooksColumn] will select only those columns. Note: if
you have required columns you will need to include them here.

```dart
final bookSelectSome = BooksSelectBuilder().select([
  BooksColumn.id,
  BooksColumn.title,
  BooksColumn.authorId,
]);
```

This is will pass `'id,title,author_id'` into the select method in the Supabase
API when built, selecting only those columns.

## Using Select Builders with Managers

When using select builders with managers, all operations return
`TetherClientReturn<TModel>`:

```dart
final bookManager = ref.watch(bookManagerProvider);

// Query with count information
final result = await bookManager.query
  .select(bookSelect)
  .eq(BooksColumn.published, true)
  .order(BooksColumn.createdAt, ascending: false)
  .limit(10);

// Access the results
final books = result.data; // List<BookModel>
final totalCount = result.count; // int? - total records matching the query
final hasError = result.hasError; // bool

print('Loaded ${books.length} books of ${totalCount ?? 'unknown'} total');

// Stream with count information
final booksStream = bookManager.query
  .select(bookSelect)
  .eq(BooksColumn.published, true)
  .asStream(); // Stream<TetherClientReturn<BookModel>>

booksStream.listen((result) {
  if (result.hasError) {
    print('Error: ${result.error}');
    return;
  }
  
  final books = result.data;
  final count = result.count;
  print('Stream update: ${books.length} books, total: $count');
});
```

## Relationships

Let's take the previous schema as an example.

```sql
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    publication_date DATE,
    price NUMERIC(10, 2), -- Example of a NUMERIC field for precise decimal values
    stock_count INTEGER DEFAULT 0, -- Example of an INTEGER field
    cover_image_id UUID REFERENCES images(id) ON DELETE SET NULL, -- Foreign key to images
    banner_image_id UUID REFERENCES images(id) ON DELETE SET NULL, -- Foreign key to images
    author_id UUID REFERENCES authors(id) ON DELETE SET NULL, -- Foreign key to authors
    metadata JSONB, -- Example of a JSONB field for storing arbitrary metadata
    tags TEXT[], -- Example of an array field for storing tags
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    document tsvector -- Column for full-text search
);

CREATE TABLE images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    url TEXT NOT NULL, -- URL of the image
    alt_text TEXT, -- Alternative text for the image
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE authors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE genres (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE, -- Example of a UNIQUE constraint
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE book_genres (
    book_id UUID REFERENCES books(id) ON DELETE CASCADE,
    genre_id UUID REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, genre_id) -- Composite primary key
);
```

### One-to-One and One-to-Many Relationships

For each one-to-one relationship in the table, the Select Builder will generate
a helper method to let you include that data in the select statement. For
example, for an associated item from `authors`, you would have a method named
`withAuthor` (singularized as it is to a single item).

```dart
final bookSelectWithAuthor = BooksSelectBuilder()
  .select()
  .withAuthor(AuthorsSelectBuilder()
    .select(),
    );
```

You need to pass in the Select Builder for the related table, in this case
`AuthorsSelectBuilder`, and call it's `.select()` method to specify the columns
you want to fetch from the related table.

Then built, it will pass the following select string to the Supabase API:
`*, author:authors!books_author_id_fkey(*)`, fetching all the columns for the
Book and all the columns for the related Author in one query.

#### Multiple Related Items

In your `books` table we have two foreign keys to the `images` table, one for
the cover image and one for the banner image. Tether will generate two methods
for these relationships: `withCoverImage` and `withBannerImage`. You can use
these methods to include the related images in the select statement.

```dart
final bookSelectWithImages = BooksSelectBuilder()
  .select()
  .withCoverImage(ImagesSelectBuilder().select())
  .withBannerImage(ImagesSelectBuilder().select());
```

This will pass the following select string to the Supabase API:
`*, cover_image:images!books_cover_image_id_fkey(*), banner_image:images!books_banner_image_id_fkey(*)`,
fetching data for both items, but clearly distinguishing between the two in the
resulting response. Tether will handle caching them separately for you.

### Many-to-Many Relationships

In our example schema we have a many-to-many relationship between `books` and
`genres` through the `book_genres` table. In the Supabase API you can get a list
of all the `genres` without fetching the `book_genres` table as a convenience,
Tether requires the join table, `book_genres`, so that we can accurately
represent the relationship in the local SQLite database.

- One thing to note is that with Tether, when selecting related items, you will
  not be able to paginate them. If you need to paginate the related items, you
  will need to query them separately.

In this case the `BooksSelectBuilder` will generate a method named
`withBookGenres` that allows you to include the related genres in the select
statement.

You would use it like this:

```dart
final bookSelectWithGenres = BooksSelectBuilder()
  .select()
  .withBookGenres(BookGenresSelectBuilder().select().withGenre(
    GenresSelectBuilder().select(),
  ));
```

Note you need to call the `withGenre` method on the `BookGenresSelectBuilder`
and pass in the `GenresSelectBuilder` to specify the columns you want to fetch
from the `genres` table.

This will pass the following select string to the Supabase API:
`*, book_genres:book_genres!books_book_id_fkey(*, genre:genres!book_genres_genre_id_fkey(*))`.

#### Filtering Many-to-Many Relationships

You can query a referenced table by indicating the relation is an `inner join`,
then filtering through the Manager API on the related table column. For example,
let's say you have a `posts` table with a `likes` table that has a many-to-many
relationship with `users`. You can filter the posts by the users who liked them
like this:

```dart
final postsWithLikes = PostsSelectBuilder()
  .select()
  .withLikes(UsersSelectBuilder().select(), innerJoin: true);

final result = await postsManager.query.select(postsWithLikes)
  .eq(LikesColumn.userId, 'some-user-id');

// Access results with count information
final posts = result.data; // List<PostModel>
final totalCount = result.count; // int? - total matching posts
```

This will pass the following select string to the Supabase API:
`*, likes:likes!inner(*)`, and then filter the results based on the `user_id`
column in the `likes` table returning all the data for the posts and only the
`likes` that match the specified user ID.

## Reusable Select Builders

Select Builders are made to be reuseable, so best practice is to define define
the data you want for each type of query you might need. Typically you will want
to fetch all the data from the table, but there are cases where you might want
to fetch only a subset of the data, for example if you have a `user_profiles`
table and you want to fetch only the `name` and `description` columns for a
foreign user, but all the columns for the current user.

For the `books` example, you might define this like so:

```dart
final imageSelect = ImagesSelectBuilder().select();

final genreSelect = GenresSelectBuilder().select();

final authorSelect = AuthorsSelectBuilder().select();

final bookGenreSelect = BookGenresSelectBuilder().select().withGenre(
  genreSelect,
);

final bookSelect = BooksSelectBuilder()
    .select()
    .withAuthor(authorSelect)
    .withBookGenres(bookGenreSelect.withGenre(genreSelect))
    .withCoverImage(imageSelect)
    .withBannerImage(imageSelect);
```

## Count Information

All manager operations that use select builders return count information when
available:

```dart
// Get count with limited results
final result = await bookManager.query
  .select(bookSelect)
  .eq(BooksColumn.published, true)
  .limit(20);

print('Showing ${result.data.length} of ${result.count} published books');

// Use count for pagination decisions
final hasMorePages = result.count != null && result.data.length < result.count!;
if (hasMorePages) {
  print('More pages available');
}
```

This count information is particularly useful for:

- Pagination UI (showing "page X of Y")
- Load more buttons (only show if more items available)
- Progress indicators
- Search result summaries ("X results found")
