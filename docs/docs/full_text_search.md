---
sidebar_position: 6
---

# Full Text Search

Tether works great with the built-in full-text search capabilities of Postgres.
While it takes more setup that a third-party service like Elasticsearch, it is a
powerful and flexible solution that is built into Postgres and works seamlessly
with Supabase.

This guide will walk you through how to set up full-text search in your Supabase
project and how to use it in your Flutter app with Tether.

## Setting Up Full-Text Search in Supabase

1. **Create a `tsvector` Column**: Add a `tsvector` column to your table that
   you want to search. This column will store the full-text search index.

   ```sql
   ALTER TABLE books ADD COLUMN document tsvector;
   ```
2. **Create a Trigger**: Create a trigger that updates the `tsvector` column
   whenever the relevant columns are inserted or updated.

   ```sql
   CREATE TRIGGER books_tsvector_update
   BEFORE INSERT OR UPDATE ON books
   FOR EACH ROW EXECUTE FUNCTION
   tsvector_update_trigger(document, 'pg_catalog.english', title, description);
   ```
3. **Create an Index**: Create a GIN index on the `tsvector` column to speed up
   search queries.

   ```sql
   CREATE INDEX idx_books_document ON books USING GIN (document);
   ```
4. **Populate the `tsvector` Column**: If you have existing data, you will need
   to populate the `tsvector` column for all existing rows.

   ```sql
   UPDATE books SET document = to_tsvector('pg_catalog.english', title || ' ' || description);
   ```

## Advanced Setup

If you want to use advanced features like ranking, searching across multiple
columns, or using columns in related tables, you can create a custom trigger
function that combines multiple fields with different weights.

Here is an example of a custom trigger that let's you set different weights for
columns as well as including related table data:

```sql
CREATE OR REPLACE FUNCTION update_books_document() RETURNS TRIGGER AS $$
BEGIN
    -- Assign different weights: 'A' for title, 'B' for description, 'C' for author's name
    NEW.document :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE((SELECT authors.first_name || ' ' || authors.last_name
                                                  FROM authors WHERE authors.id = NEW.author_id), '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER books_document_update
   BEFORE INSERT OR UPDATE ON books
   FOR EACH ROW EXECUTE FUNCTION update_books_document();
```

## Using Full-Text Search in Tether

Using full-text search in Tether is straightforward, as we follow the same
conventions as the Supabase API.

```dart
final booksManager = ref.watch(booksManagerProvider);

// Perform a full-text search
final searchResults = await booksManager
    .query()
    .select(
        BookSelectBuilder().select()
        )
    .textSearch(
        BooksColumn.tsvector, // The tsvector column to search
        'search query',
    );

// You can also combine full-text search with other filters
final filteredResults = await booksManager
    .query()
    .select(BookSelectBuilder().select())
    .textSearch(
        BooksColumn.tsvector,
        'search query',
    )
    .eq(BooksColumn.type, 'fiction')
```
