-- Table: bookstores
CREATE TABLE bookstores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    address JSONB, -- Example of a JSONB field for storing structured data
    established_date DATE, -- Example of a DATE field
    is_open BOOLEAN DEFAULT TRUE, -- Example of a BOOLEAN field
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster lookups by name
CREATE INDEX idx_bookstores_name ON bookstores (name);

-- Table: authors
CREATE TABLE authors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    bio TEXT, -- Example of a TEXT field for longer content
    birth_date DATE, -- Example of a DATE field
    death_date DATE, -- Example of a nullable DATE field
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    document tsvector -- Column for full-text search
);

-- Index for faster lookups by last name
CREATE INDEX idx_authors_last_name ON authors (last_name);

-- Create a GIN index on the "document" column in the authors table
CREATE INDEX idx_authors_full_text_search ON authors USING GIN (document);

-- Table: genres
CREATE TABLE genres (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE, -- Example of a UNIQUE constraint
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster lookups by name
CREATE INDEX idx_genres_name ON genres (name);

-- Table for images (placeholder for actual image storage)
CREATE TABLE images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    url TEXT NOT NULL, -- URL of the image
    alt_text TEXT, -- Alternative text for the image
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: books
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

-- Index for faster lookups by title
CREATE INDEX idx_books_title ON books (title);

-- Index for faster lookups by publication date
CREATE INDEX idx_books_publication_date ON books (publication_date);

-- Create a GIN index on the "document" column in the books table
CREATE INDEX idx_books_full_text_search ON books USING GIN (document);

-- Table: book_genres (join table for many-to-many relationship between books and genres)
CREATE TABLE book_genres (
    id SERIAL PRIMARY KEY, -- Example of an auto-incrementing integer field
    book_id UUID REFERENCES books(id) ON DELETE CASCADE,
    genre_id UUID REFERENCES genres(id) ON DELETE CASCADE,
    UNIQUE (book_id, genre_id) -- Ensure no duplicate relationships
);

-- Index for faster lookups by book_id
CREATE INDEX idx_book_genres_book_id ON book_genres (book_id);

-- Index for faster lookups by genre_id
CREATE INDEX idx_book_genres_genre_id ON book_genres (genre_id);

-- Table: bookstore_books (join table for many-to-many relationship between bookstores and books)
CREATE TABLE bookstore_books (
    id SERIAL PRIMARY KEY,
    bookstore_id UUID REFERENCES bookstores(id) ON DELETE CASCADE,
    book_id UUID REFERENCES books(id) ON DELETE CASCADE,
    UNIQUE (bookstore_id, book_id) -- Ensure no duplicate relationships
);

-- Index for faster lookups by bookstore_id
CREATE INDEX idx_bookstore_books_bookstore_id ON bookstore_books (bookstore_id);

-- Index for faster lookups by book_id
CREATE INDEX idx_bookstore_books_book_id ON bookstore_books (book_id);

-- Table: profiles (stores public user data, linked to auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE, -- Links to auth.users table
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    website TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Optional: Add an index on username for faster lookups if you query by username frequently
CREATE INDEX idx_profiles_username ON profiles (username);

-- Function to automatically create a profile entry when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, updated_at, created_at)
  VALUES (NEW.id, NOW(), NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call handle_new_user function after a new user is inserted into auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update the "document" column in the books table
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

-- Trigger to update the "document" column in the books table on INSERT or UPDATE
-- CREATE TRIGGER trg_update_books_document  -- This trigger definition remains the same
-- AFTER INSERT OR UPDATE ON books
-- FOR EACH ROW EXECUTE FUNCTION update_books_document(); -- This line was BEFORE, should be AFTER

-- Corrected Trigger definition (should be BEFORE INSERT OR UPDATE for NEW.document modification)
CREATE OR REPLACE  TRIGGER trg_update_books_document
BEFORE INSERT OR UPDATE ON books -- Use BEFORE to modify NEW before it's written
FOR EACH ROW EXECUTE FUNCTION update_books_document();


-- Function to update the "document" column in the authors table
CREATE OR REPLACE FUNCTION update_authors_document() RETURNS TRIGGER AS $$
BEGIN
    -- Assign different weights: 'A' for author's name, 'B' for bio, 'C' for aggregated book titles/descriptions
    NEW.document :=
        setweight(to_tsvector('english', COALESCE(NEW.first_name || ' ' || NEW.last_name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.bio, '')), 'B') || -- Assuming you want to include bio
        setweight(to_tsvector('english', COALESCE((SELECT STRING_AGG(books.title || ' ' || books.description, ' ')
                                                  FROM books WHERE books.author_id = NEW.id), '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Corrected Trigger definition for authors (should be BEFORE INSERT OR UPDATE)
CREATE OR REPLACE  TRIGGER trg_update_authors_document
BEFORE INSERT OR UPDATE ON authors -- Use BEFORE to modify NEW
FOR EACH ROW EXECUTE FUNCTION update_authors_document();


-- Trigger to update the "document" column in the authors table when a related book is updated
CREATE OR REPLACE FUNCTION update_authors_on_books_change() RETURNS TRIGGER AS $$
DECLARE
    v_author_id UUID;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        v_author_id := OLD.author_id;
    ELSE -- INSERT OR UPDATE
        v_author_id := NEW.author_id;
    END IF;

    IF v_author_id IS NOT NULL THEN
        UPDATE authors
        SET document = (
            setweight(to_tsvector('english', COALESCE(authors.first_name || ' ' || authors.last_name, '')), 'A') ||
            setweight(to_tsvector('english', COALESCE(authors.bio, '')), 'B') ||
            setweight(to_tsvector('english', COALESCE((SELECT STRING_AGG(b.title || ' ' || b.description, ' ')
                                                      FROM books b WHERE b.author_id = authors.id), '')), 'C')
        )
        WHERE id = v_author_id;

        -- If the author_id changed on UPDATE, also update the old author
        IF (TG_OP = 'UPDATE' AND OLD.author_id IS NOT NULL AND OLD.author_id <> NEW.author_id) THEN
             UPDATE authors
             SET document = (
                setweight(to_tsvector('english', COALESCE(authors.first_name || ' ' || authors.last_name, '')), 'A') ||
                setweight(to_tsvector('english', COALESCE(authors.bio, '')), 'B') ||
                setweight(to_tsvector('english', COALESCE((SELECT STRING_AGG(b.title || ' ' || b.description, ' ')
                                                          FROM books b WHERE b.author_id = authors.id), '')), 'C')
            )
            WHERE id = OLD.author_id;
        END IF;
    END IF;
    RETURN NULL; -- This is an AFTER trigger, so return NULL or OLD/NEW as appropriate if it were FOR EACH ROW
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_update_authors_on_books_change -- This trigger definition remains the same
AFTER INSERT OR UPDATE OR DELETE ON books
FOR EACH ROW EXECUTE FUNCTION update_authors_on_books_change();