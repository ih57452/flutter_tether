---
sidebar_position: 3
---

# Models

Tether generates models for your Supabase tables and views, allowing you to
interact with your data in a Flutter manner, typically to a
`lib/database/models.g.dart` file.

## Model Generation

Take a schema like this, where you have a `books` table with various fields,
including foreign keys to `images` and `authors`, and a many-to-many
relationship with `genres`:

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

Tether will generate a model for each table, translating the SQLite types to
Dart types to conform to the original Postgres schema. It will also create
relationships between the models based on the foreign keys and many-to-many
relationships defined in the schema.

For the above schema, Tether will generate a `BookModel`, `ImageModel`,
`AuthorModel`, `GenreModel`, and `BookGenreModel`. Each model will include
fields corresponding to the columns in the table, as well as methods for
serialization and deserialization from Supabase and SQLite.

The generated model will look like this:

```dart
class BookModel extends TetherModel<BookModel> {
  final String? authorId;
  final String? bannerImageId;
  final String? coverImageId;
  final DateTime? createdAt;
  final String? description;
  final String? document;
  final String id;
  final Map<String, dynamic>? metadata;
  final double? price;
  final DateTime? publicationDate;
  final int? stockCount;
  final List<String>? tags;
  final String title;
  final DateTime? updatedAt;
  final AuthorModel? author;
  final ImageModel? bannerImage;
  final ImageModel? coverImage;
  final List<BookGenreModel>? bookGenres;
  final List<BookstoreBookModel>? bookstoreBooks;

  BookModel({
    this.authorId,
    this.bannerImageId,
    this.coverImageId,
    this.createdAt,
    this.description,
    this.document,
    required this.id,
    this.metadata,
    this.price,
    this.publicationDate,
    this.stockCount,
    this.tags,
    required this.title,
    this.updatedAt,
    this.author,
    this.bannerImage,
    this.coverImage,
    this.bookGenres,
    this.bookstoreBooks,
  }) : super({
         'author_id': authorId,
         'banner_image_id': bannerImageId,
         'cover_image_id': coverImageId,
         'created_at': createdAt,
         'description': description,
         'document': document,
         'id': id,
         'metadata': metadata,
         'price': price,
         'publication_date': publicationDate,
         'stock_count': stockCount,
         'tags': tags,
         'title': title,
         'updated_at': updatedAt,
         'author': author,
         'bannerImage': bannerImage,
         'coverImage': coverImage,
         'bookGenres': bookGenres,
         'bookstoreBooks': bookstoreBooks,
       });

  /// The primary key for this model instance.
  @override
  String get localId => id;

  /// Creates an instance from a JSON map (e.g., from Supabase).
  factory BookModel.fromJson(Map<String, dynamic> json) {
    ...
  }

  /// Creates an instance from a map (e.g., from SQLite row containing nested JSON in 'jsobjects' column).
  factory BookModel.fromSqlite(Row row) {
    ...
  }

  /// Converts the instance to a JSON map (for Supabase).
  @override
  Map<String, dynamic> toJson() {
    ...
  }

  /// Converts the instance to a map suitable for SQLite insertion/update.
  @override
  Map<String, dynamic> toSqlite() {
    ...
  }

  /// Creates a copy of this instance with potentially modified fields.
  @override
  BookModel copyWith({...}) {
    ...
  }

  @override
  String toString() {
    return 'BookModel(authorId: $authorId, bannerImageId: $bannerImageId, coverImageId: $coverImageId, createdAt: $createdAt, description: $description, document: $document, id: $id, metadata: $metadata, price: $price, publicationDate: $publicationDate, stockCount: $stockCount, tags: $tags, title: $title, updatedAt: $updatedAt, author: $author, bannerImage: $bannerImage, coverImage: $coverImage, bookGenres: $bookGenres, bookstoreBooks: $bookstoreBooks)';
  }
}
```

Factories are provided to connect and translate the data from Supabase and
SQLite to the model. These are consumed by the Managers and you typically will
not need to interact with them directly.

## Working with Manager Results

When using Tether managers, all operations return a `TetherClientReturn<TModel>`
object:

```dart
// Get books with count information
final result = await bookManager.query
  .select(bookSelect)
  .eq(BooksColumn.published, true)
  .limit(10);

// Access the data
final books = result.data; // List<BookModel>
final totalCount = result.count; // int? - total matching records
final hasError = result.hasError; // bool

// Handle potential errors
if (result.hasError) {
  print('Error: ${result.error}');
  return;
}

// Get a single book
try {
  final book = result.single; // Throws if no data
  print('First book: ${book.title}');
} catch (e) {
  print('No books found');
}
```

## Streaming Results

Streams also return `TetherClientReturn<TModel>` objects:

```dart
final booksStream = bookManager.query
  .select(bookSelect)
  .eq(BooksColumn.published, true)
  .asStream();

booksStream.listen((result) {
  if (result.hasError) {
    print('Stream error: ${result.error}');
    return;
  }
  
  final books = result.data;
  final count = result.count;
  print('Loaded ${books.length} books, total available: $count');
});
```

## Things to Note

- Typical SQL snake case conventions are translated to camel case in Dart. For
  example, `created_at` becomes `createdAt`.
- All manager operations return `TetherClientReturn<TModel>` which includes both
  data and metadata like count.
- The `count` field provides the total number of records matching your query,
  useful for pagination.

### Relationships

- Relationships to other models are generated off the foreign keys for forward
  relationships, thus `author_id` will become 'author' in the books model. The
  config file lets you set custom `sanitization_endings` to remove suffixes like
  `_id` or `_fk` from the model names.
- Many-to-many relationships are represented as lists of models. For example,
  the `book_genres` table will create a `List<BookGenreModel>` as `bookGenres`.
