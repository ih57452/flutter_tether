---
sidebar_position: 5
---

# Managers

Tether will create a `Manager` class for each table that is defined in the
schema. The Manager is in-essence a wrapper around the Supabase client API and
operates very much like the Supabase client API. It will automatically handle
caching data fetched from the remote database as well as automatically handle
optimisitc updates for inserts, updates, and deletes.

## Accessing Managers

After generation managers will be available in the `lib/database/managers`
directory.

The intended way to use the manager is via Riverpod, but you can also use it
directly with another state management solution or even without any state
management.

```dart
// With Riverpod
final booksManager = ref.watch(booksManagerProvider);

// Without Riverpod - you have to pass some options in to the constructor, but you could then use it via GetIt or any other DI solution.
final bookManager = BooksManager(
    localDb: database.db, // The local SQLite database instance
    client: Supabase.instance.client, // The Supabase client instance
    tableSchemas: globalSupabaseSchema, // The global schema for the tables
    fromJsonFactory: (json) => BookModel.fromJson(json), // Factory to convert Supabase JSON to the model.
    fromSqliteFactory: (json) => BookModel.fromSqlite(json), // Factory to convert SQLite JSON to the model.
  );
```

## Basic Usage

The Tether Manager API is almost identical to the Supabase client API, so if you
are familiar with the Supabase client API, you will feel right at home. It wraps
the following APIs:

- Database client API
  - RPC is supported, but see notes below.
  - Full-text search is supported, but see notes below.
- Realtime client API

### Database Client API

This will be the most commonly used API. It allows you to fetch data from
Supabase, cache it locally, and mutate it. You will use the same methods to also
fetch data from the local SQLite database.

You can use the `query()` method to create a query builder for the table, and
then use the `select()`, `insert()`, `update()`, and `delete()`, filter and
transform methods to build your query.

There are a few key differences to the Supabase client API:

- The `select()` method does not take a string, but rather a `SelectBuilder`
  instance that allows you to build the select statement in a Tether manner.
- The `insert()`, `update()`, `upsert()` and `delete()` methods take a list of
  models (BookModel, AuthorModel, etc.) rather than a map of data. This allows
  you to work with the models directly and ensures type safety.
- Filters and Transforms, like `eq()`, `like()`, `order()`, etc., accept a
  `TetherColumn` instance rather than a string. This allows you to use the
  generated columns from the models directly, ensuring type safety and avoiding
  typos.
- On inserts and updates you do not need to pass the ending `.select()` to get
  returning data like you would with the Supabase client API. Tether will
  automatically return the inserted or updated data as a list of models.
- Managers will always return a list of models, even if you are querying for a
  single item. While using the Supabase client API by itself can return both a
  list and a single item, it was not possible when wrapping the API.

Some examples of how to use the Manager API:

```dart
final booksManager = ref.watch(booksManagerProvider);

// Fetch all books
final books = await booksManager.query.select(BooksSelectBuilder().select());

// Fetch a single book by ID
final book = await booksManager.query.select(BooksSelectBuilder().select())
    .eq(BooksColumn.id, 'some-book-id')
    .limit(1);

// Insert a new book
final newBook = BookModel(
  id: 'new-book-id',
  title: 'New Book',
  authorId: 'author-id',
  // other fields...
);
final insertedBook = await booksManager.query.insert([newBook]);

// Update a book
final updatedBook = BookModel(
  id: 'some-book-id',
  title: 'Updated Book Title',
  // other fields...
); // You will typically want to pass in a mutated version of the whole model, not just the fields you want to update.
final updatedBooks = await booksManager.query.update([updatedBook])
    .eq(BooksColumn.id, 'some-book-id');

// Delete a book
final deletedBooks = await booksManager.query.delete()
    .eq(BooksColumn.id, 'some-book-id');
```

#### Streaming Data

You will can use the same manager to listen to have flutter create a `Stream` of
your data by using `onStream()` instead of `await` on the query. This will
return a `Stream` of the data that you can listen to for changes from the local
database. On initialization of the stream it will also fetch data from the
remote database and cache it locally.

Best practice is to define your streams in a Riverpod provider so that you can
easily listen to them in your widgets. This also allow you an easy way to pass
in options to the manager, such as listening to a specific item based on id.

```dart
// Watch a single book by ID
final bookProvider = StreamProvider.autoDispose.family<List<BookModel>, String>((ref, bookId) {
  final booksManager = ref.watch(booksManagerProvider);
  // Fetch a single book by ID and listen for changes
  return booksManager.query.select(BooksSelectBuilder().select())
      .eq(BooksColumn.id, bookId)
      .limit(1)
      .onStream();
});

// In your widget
class BookWidget extends ConsumerWidget {
  final String bookId;

  BookWidget({required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsyncValue = ref.watch(bookProvider(bookId));

    return bookAsyncValue.when(
      data: (books) {
        if (books.isEmpty) return Text('Book not found');
        final book = books.first;
        return Text('Book title: ${book.title}');
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

As all the mutations (insert, update, delete) are automatically optimistically
updated, you can listen to the stream and get real-time updates from the local
database without having to worry about the state of the remote database.

#### Local or Remote Fetching

You can use the `localOnly()` and `remoteOnly()` methods to tell the manager to
only fetch data from the local SQLite database or the remote Supabase database,
respectively. This is useful when you want to ensure you are only working with
the local data or when you want to bypass the local cache and fetch fresh data
from the remote database.

Note: All remote queries will automatically cache the data locally.

```dart
final booksManager = ref.watch(booksManagerProvider);

// Fetch all books from the remote database only - useful if you are refreshing data you are watching via a Stream.
final remoteBooks = await booksManager.query
    .select(BooksSelectBuilder().select())
    .remoteOnly();
```

#### Relationships

Manager are smart and will automatically handle relationships fetching and
caching the data for all the related items. Just pass in a SelectBuilder
instance to the `select()` method and use the `with*` methods to include related
items in the query.

```dart
final booksManager = ref.watch(booksManagerProvider);

// Fetch all books with their authors
final booksWithAuthors = await booksManager.query
    .select(
        BooksSelectBuilder().select()
        .withAuthor(
            AuthorsSelectBuilder().select()
            ),
        ),
    .eq(BooksColumn.id, 'some-book-id');
```

You can also query a table by columns on a related table. For example, if you
want to fetch all books by a specific author, you can do it like this:

```dart
final booksManager = ref.watch(booksManagerProvider);

// Fetch all books by a specific author
final booksByAuthor = await booksManager.query
    .select(BooksSelectBuilder().select())
    .withAuthor(
        AuthorsSelectBuilder().select()
    ).eq(AuthorsColumn.name, 'Author Name');
```

### RPC Calls

Tether supports calling Remote Procedure Calls (RPC) defined in your Supabase
project. There are a few things to note to make this work:

- RPCs are related to the table the Manager is for.
- Because of this your stored proceedure will need to return an Array of JSON
  objects with columns that match that table in the database. This should look
  the same as what the Supabase API returns for a table query.
  - For example, if you have a `books` table, your RPC should return an array of
    objects with the same structure as the `books` table.
  - You can also return data from related tables, but you will need to make sure
    it conforms to the structure that a Tether model expects (look at the
    related Factory method in the model for the expected structure).

```dart
final booksManager = ref.watch(booksManagerProvider);

// Call an RPC that returns books
final books = await booksManager.rpc('get_books_by_author', params: {
  'author_id': 'author-id',
}).select(BooksSelectBuilder().select());
```

## Realtime Client API

Tether Managers also support the Supabase Realtime API. This allows you to
listen to changes in the database and get real-time updates in your app, all
cached locally.

The realtime features of the Tether Manager works similarly to the Supabase
Realtime API, but with a few differences:

```dart
final booksManager = ref.watch(booksManagerProvider);

// Listen to changes in the books table
final booksStream = booksManager
    .realtime // Call the realtime method
    .eq(BooksColumn.id, 'some-book-id') // Add all the filters and transforms next
    .listen(); // Call .listen() to stream

// Using an in filter
final booksStream = booksManager
    .realtime
    .inFilter(BooksColumn.id, ['book-id-1', 'book-id-2'])
    .listen();
```

- You can use the `realtime()` method to create a realtime query builder for the
  table, and then use the same filters and transforms as you would with the
  database client API.
- Add all the filters and transforms before calling `listen()` (see
  [Supabase documentation](https://supabase.com/docs/reference/dart/stream)).
- The Manager will automatically handle caching the data locally and return the
  TetherModels for the items that changed.
- By default, the realtime stream will return all changes to the table.
