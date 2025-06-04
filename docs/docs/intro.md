---
sidebar_position: 1
---

# About Tether

**Tether** is an opinionated library that connects Supabase and a Flutter app.

Tether does the following:

- **Creates and manages a local database** for your application using SQLite.
  Manages migrations and schema updates automatically. Automatically mirrors the
  Postgres DB schema locally, including all relationships.
- **Generates Dart models** from your Supabase database schema, allowing you to
  work with your data in a type-safe manner.
- **Provides a wrapper around the Supabase API** to simplify interactions
  between the remote and local database. Automatically handles caching,
  optimistic updates, synchronization, and conflict resolution between the two.
- **Select builders** Creates a set of query builders that allow you to
  construct complex queries in a simplified, dart-compliant, and reusable
  manner.
- **Supports real-time updates** from Supabase.
- **Provides a set of utilities** to simplify common tasks, such as managing
  authentication and profiles, managing feeds, full-text search, managing user
  preferences, and running code in a background service.

## Why Tether?

Supabase is an amazing platform and Postgres is a powerful database. However,
Supabase did not include class generation out of the box for Dart like they do
for Javascript. It does include first-class support of GraphQL, but I found that
cumbersome to work with, especially when you have the need to cache data locally
and synchronize it with the remote database. When you factor in the typical need
for full-text search, I ended up with a very complicated system for interacting
within my Flutter apps. You could not get around the need to use both the
Supabase API, interact with GraphQL and a third-party full-text search service
(and associated synchronization complexity). My ideal solution was to centralize
all these services through Supabase so that there was a simplified point of
interaction.

## Technology

Tether is built on top of the following technologies:

- [Supabase](https://supabase.com/)
- [SQLite Async](https://pub.dev/packages/sqlite_async)
- [Riverpod](https://riverpod.dev/) \- Not required\, but a lot of extended
  features are built on top of Riverpod.
- [flutter\_background\_service](https://pub.dev/packages/flutter_background_service) -
  Only required if you use the background services.

## Getting Started

To install Tether add the following to your project:

```bash
# Install the dependencies
flutter pub add tether_libs supabase_flutter sqlite_async sqlite3_flutter_libs supabase equatable uuid

# Install the generator
flutter pub add -d tether

# If you want to use the Riverpod features
flutter pub add flutter_riverpod

# If you want to use the background service
flutter pub add flutter_background_service
```

### Create the Config files

Create a `tether.yaml` file in the root of your project. You should not have to
change many of these settings, but best practice is to either include all the
tables you need or exclude the ones you do not need.

Use the full table name plus the schema name, e.g. `public.profiles`.

```yaml
database:
  host: TETHER_SUPABASE_HOST 
  port: TETHER_PORT_NAME 
  database: TETHER_DB_NAME 
  username: TETHER_DB_USERNAME 
  password: TETHER_DB_PASSWORD 
  ssl: TETHER_SSL 

generation:
  output_directory: lib/database
  exclude_tables:
    - '_realtime.*'
    - 'auth.*'
    - 'net.*'
    - 'pgsodium.*'
    - 'realtime.*'
    - 'storage.*'
    - 'supabase_functions.*'
    - 'vault.*'
  include_tables: []
  exclude_references: []
  generate_for_all_tables: true

  dbClassName: AppDb
  databaseName: 'app_db.sqlite'

  models:
    enabled: true 
    filename: models.g.dart
    prefix: ''
    suffix: Model
    use_null_safety: true

  supabase_selectors:
    enabled: true 

  supabase_select_builders:
    enabled: true 
    filename: 'supabase_select_builders.g.dart'
    generated_schema_dart_file_name: 'supabase_schema.g.dart'
    suffix: SelectBuilder

  schema_registry_file_name: 'schema_registry.g.dart'

  sqlite_migrations:
    enabled: true 
    output_subdir: 'sqlite_migrations'

  client_managers:
    enabled: true 
    use_riverpod: true

  providers:
    enabled: true 
    output_subdir: 'providers'

  authentication:
    enabled: true
    profile_table: 'profiles' 

  background_services:
    enabled: true

  sanitization_endings:
    - _id
    - _fk
    - _uuid
```

Create a '.env' file at the root of your project and put in the secrets for
connecting to your Supabase database. Make sure to gitignore this file.

```env
TETHER_SUPABASE_HOST=your_supabase_host
TETHER_PORT_NAME=5432
TETHER_DB_NAME=your_database_name
TETHER_DB_USERNAME=your_database_username
TETHER_DB_PASSWORD=your_database_password
TETHER_SSL=true
```

## Run the generator

Run the generator to create the necessary files:

```bash
dart run tether --config tether.yaml
```

This will generate the necessary files in the `lib/database` directory by
default.

# Using Tether

Tether is made to be accessed via Riverpod. Check the documents for other ways
to access.

### Database

```dart
final db = ref.watch(databaseProvider);
```

### Models

Type-safe Dart classes automatically generated from your database schema:

```dart
// Generated from your 'books' table
final book = BookModel(
  id: '123',
  title: 'Flutter Development Guide',
  authorId: 'author-456',
  published: true,
  createdAt: DateTime.now(),
);

// Convert to/from JSON and SQLite
final json = book.toJson();
final fromJson = BookModel.fromJson(json);
```

### Select Builders

Select builders allow you to construct complex queries in a type-safe manner:

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

### Managers

Managers provide a layer for CRUD operations with caching and synchronization:

```dart
final bookManager = ref.watch(bookManagerProvider);

final books = await bookManager.query()
  .select(bookSelect)
  .eq(BookColumns.published, true)
  .order(BookColumns.createdAt, ascending: false)
  .limit(10);
```
