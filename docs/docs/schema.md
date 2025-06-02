---
sidebar_position: 2
---

# Schema Management

Tether automates the management of your local SQLite database schema by
mirroring the Postgres schema from your Supabase project. This includes handling
migrations, creating tables, and managing relationships.

As SQLite is a full SQL database, you have to manage migrations of the local
schema over time when you change the schema in your Supabase project so that you
can persist the existing data in running installations of your application.

Tether will configure and manage these for you.

## Schema Generation

When you run the generator, Tether will:

- Fetch the schema from your Supabase project.
- Create files in `/lib/database/schema` that represent the schema. The system
  will compare these over time to create migrations.
- Generate the necessary SQLite commands to create the tables and relationships
  in your local SQLite database.
- Create a `supabase_schema.dart` file that is a snapshot of the current schema.
  This file is used by the managers to interact with relationships.
- Create migrations for the local SQLite database in
  `lib/database/sqlite_migrations`.
- Create the database files for the local SQLite database. Typically at
  `lib/database/database.dart`.

## Schema Conventions

Tether will try to following:

- Use the same table names as in your Supabase project. i.e. `user_profiles` in
  Supabase will be `user_profiles` in SQLite.
- Use the same column names as in your Supabase project. i.e. `some_column` in
  Supabase will be `some_column` in SQLite.
- Use the same data types as in your Supabase project or will transform them to
  the closest equivalent in SQLite. Most data types will be mapped to the corred
  Dart type by the Models system.
- Use the same relationships as in your Supabase project. i.e. a `profiles`
  table with a foreign key to a `users` table will create a relationship in the
  SQLite database.
- Use the same indexes as in your Supabase project. i.e. a `profiles` table with
  an index on the `email` column will create an index in the SQLite database.

Tether does not currently provide a way to manually define things like indexes
on the local DB outside of the automatic generation.

### Best Practices

- Tether will automatically rename column that are reserved words in Dart. For
  example, a column named `default` in Supabase will be renamed to
  `defaultValue` in SQLite.
