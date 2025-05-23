-- Seed data for genres
INSERT INTO genres (id, name, description, created_at, updated_at)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'Fiction', 'Fictional works of prose.', NOW(), NOW()),
    ('22222222-2222-2222-2222-222222222222', 'Non-Fiction', 'Non-fictional works based on real events or facts.', NOW(), NOW()),
    ('33333333-3333-3333-3333-333333333333', 'Science Fiction', 'Works of speculative fiction often dealing with futuristic concepts.', NOW(), NOW()),
    ('44444444-4444-4444-4444-444444444444', 'Fantasy', 'Works that include magical or supernatural elements.', NOW(), NOW()),
    ('55555555-5555-5555-5555-555555555555', 'Mystery', 'Works that involve solving a crime or uncovering secrets.', NOW(), NOW()),
    ('66666666-6666-6666-6666-666666666666', 'Romance', 'Works that focus on romantic relationships.', NOW(), NOW()),
    ('77777777-7777-7777-7777-777777777777', 'Horror', 'Works intended to scare or unsettle the reader.', NOW(), NOW()),
    ('88888888-8888-8888-8888-888888888888', 'Biography', 'Works that tell the story of a person''s life.', NOW(), NOW()),
    ('99999999-9999-9999-9999-999999999999', 'Self-Help', 'Works that provide advice and strategies for personal improvement.', NOW(), NOW()),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'History', 'Works that explore historical events and figures.', NOW(), NOW());

-- Seed data for bookstores
INSERT INTO bookstores (id, name, address, established_date, is_open, created_at, updated_at)
VALUES
    ('b1111111-1111-1111-1111-111111111111', 'Downtown Books', '{"street": "123 Main St", "city": "Metropolis", "state": "NY", "zip": "12345"}', '1995-06-15', TRUE, NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222222', 'Suburban Reads', '{"street": "456 Elm St", "city": "Smallville", "state": "KS", "zip": "67890"}', '2005-09-01', TRUE, NOW(), NOW()),
    ('b3333333-3333-3333-3333-333333333333', 'Coastal Books', '{"street": "789 Ocean Ave", "city": "Seaside", "state": "CA", "zip": "54321"}', '2010-03-20', TRUE, NOW(), NOW()),
    ('b4444444-4444-4444-4444-444444444444', 'Mountain Tales', '{"street": "321 Hilltop Rd", "city": "Aspen", "state": "CO", "zip": "67812"}', '2000-07-10', TRUE, NOW(), NOW()),
    ('b5555555-5555-5555-5555-555555555555', 'Urban Stories', '{"street": "654 City Blvd", "city": "Gotham", "state": "IL", "zip": "98765"}', '1990-11-25', TRUE, NOW(), NOW());

-- Seed data for authors
INSERT INTO authors (id, first_name, last_name, bio, birth_date, created_at, updated_at)
VALUES
    ('a1111111-1111-1111-1111-111111111111', 'Jane', 'Austen', 'English novelist known for her six major novels.', '1775-12-16', NOW(), NOW()),
    ('a2222222-2222-2222-2222-222222222222', 'Mark', 'Twain', 'American writer, humorist, entrepreneur, publisher, and lecturer.', '1835-11-30', NOW(), NOW()),
    ('a3333333-3333-3333-3333-333333333333', 'J.K.', 'Rowling', 'British author, best known for the Harry Potter series.', '1965-07-31', NOW(), NOW()),
    ('a4444444-4444-4444-4444-444444444444', 'George', 'Orwell', 'English novelist, essayist, journalist, and critic.', '1903-06-25', NOW(), NOW()),
    ('a5555555-5555-5555-5555-555555555555', 'Agatha', 'Christie', 'English writer known for her 66 detective novels.', '1890-09-15', NOW(), NOW()),
    ('a6666666-6666-6666-6666-666666666666', 'Stephen', 'King', 'American author of horror, supernatural fiction, suspense, and fantasy novels.', '1947-09-21', NOW(), NOW()),
    ('a7777777-7777-7777-7777-777777777777', 'Isaac', 'Asimov', 'American author and professor of biochemistry, known for his works of science fiction.', '1920-01-02', NOW(), NOW()),
    ('a8888888-8888-8888-8888-888888888888', 'Ernest', 'Hemingway', 'American novelist, short-story writer, and journalist.', '1899-07-21', NOW(), NOW()),
    ('a9999999-9999-9999-9999-999999999999', 'F. Scott', 'Fitzgerald', 'American novelist, widely regarded as one of the greatest American writers of the 20th century.', '1896-09-24', NOW(), NOW()),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Harper', 'Lee', 'American novelist best known for her 1960 novel To Kill a Mockingbird.', '1926-04-28', NOW(), NOW());

-- Seed data for images
INSERT INTO images (id, url, alt_text, created_at, updated_at)
VALUES
    ('a1111111-1111-1111-1111-111111111111', 'https://example.com/images/gatsby-cover.jpg', 'Cover image for The Great Gatsby', NOW(), NOW()),
    ('a2222222-2222-2222-2222-222222222222', 'https://example.com/images/gatsby-banner.jpg', 'Banner image for The Great Gatsby', NOW(), NOW()),
    ('a3333333-3333-3333-3333-333333333333', 'https://example.com/images/mockingbird-cover.jpg', 'Cover image for To Kill a Mockingbird', NOW(), NOW()),
    ('a4444444-4444-4444-4444-444444444444', 'https://example.com/images/mockingbird-banner.jpg', 'Banner image for To Kill a Mockingbird', NOW(), NOW()),
    ('a5555555-5555-5555-5555-555555555555', 'https://example.com/images/shining-cover.jpg', 'Cover image for The Shining', NOW(), NOW()),
    ('a6666666-6666-6666-6666-666666666666', 'https://example.com/images/shining-banner.jpg', 'Banner image for The Shining', NOW(), NOW()),
    ('a7777777-7777-7777-7777-777777777777', 'https://example.com/images/animalfarm-cover.jpg', 'Cover image for Animal Farm', NOW(), NOW()),
    ('a8888888-8888-8888-8888-888888888888', 'https://example.com/images/animalfarm-banner.jpg', 'Banner image for Animal Farm', NOW(), NOW()),
    ('a9999999-9999-9999-9999-999999999999', 'https://example.com/images/carrie-cover.jpg', 'Cover image for Carrie', NOW(), NOW()),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://example.com/images/carrie-banner.jpg', 'Banner image for Carrie', NOW(), NOW()),
    ('abbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://example.com/images/bravenewworld-cover.jpg', 'Cover image for Brave New World', NOW(), NOW()),
    ('accccccc-cccc-cccc-cccc-cccccccccccc', 'https://example.com/images/bravenewworld-banner.jpg', 'Banner image for Brave New World', NOW(), NOW()),
    ('addddddd-dddd-dddd-dddd-dddddddddddd', 'https://example.com/images/hobbit-cover.jpg', 'Cover image for The Hobbit', NOW(), NOW()),
    ('aeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'https://example.com/images/hobbit-banner.jpg', 'Banner image for The Hobbit', NOW(), NOW());

-- Seed data for books
INSERT INTO books (id, title, description, publication_date, price, stock_count, author_id, metadata, tags, cover_image_id, banner_image_id, created_at, updated_at)
VALUES
    ('66666666-6666-4666-9666-666666666666', 'The Great Gatsby', 'A novel about the American dream.', '1925-04-10', 10.99, 12, 'a9999999-9999-9999-9999-999999999999', '{"edition": "First", "language": "English"}', ARRAY['classic', 'tragedy'], 'a1111111-1111-1111-1111-111111111111', 'a2222222-2222-2222-2222-222222222222', NOW(), NOW()),
    ('77777777-7777-4777-9777-777777777777', 'To Kill a Mockingbird', 'A novel about racial injustice in the Deep South.', '1960-07-11', 8.99, 20, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '{"edition": "Second", "language": "English"}', ARRAY['classic', 'social'], 'a3333333-3333-3333-3333-333333333333', 'a4444444-4444-4444-4444-444444444444', NOW(), NOW()),
    ('88888888-8888-4888-9888-888888888888', 'The Shining', 'A horror novel about a haunted hotel.', '1977-01-28', 15.99, 10, 'a6666666-6666-6666-6666-666666666666', '{"edition": "First", "language": "English"}', ARRAY['horror', 'psychological'], 'a5555555-5555-5555-5555-555555555555', 'a6666666-6666-6666-6666-666666666666', NOW(), NOW()),
    ('99999999-9999-4999-9999-999999999999', 'Animal Farm', 'A satirical allegory about totalitarianism.', '1945-08-17', 7.99, 25, 'a4444444-4444-4444-4444-444444444444', '{"edition": "Third", "language": "English"}', ARRAY['satire', 'political'], 'a7777777-7777-7777-7777-777777777777', 'a8888888-8888-8888-8888-888888888888', NOW(), NOW()),

    -- Books for Suburban Reads
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Carrie', 'A horror novel about a bullied girl with telekinetic powers.', '1974-04-05', 12.99, 15, 'a6666666-6666-6666-6666-666666666666', '{"edition": "First", "language": "English"}', ARRAY['horror', 'psychological'], 'a9999999-9999-9999-9999-999999999999', 'a1111111-1111-1111-1111-111111111111', NOW(), NOW()),
    ('aaaabbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Brave New World', 'A dystopian novel about a futuristic society.', '1932-08-01', 9.99, 18, 'a4444444-4444-4444-4444-444444444444', '{"edition": "Second", "language": "English"}', ARRAY['dystopian', 'science fiction'], 'a2222222-2222-2222-2222-222222222222', 'a3333333-3333-3333-3333-333333333333', NOW(), NOW()),
    ('aaaacccc-cccc-cccc-cccc-cccccccccccc', 'The Catcher in the Rye', 'A novel about teenage rebellion.', '1951-07-16', 11.99, 22, 'a8888888-8888-8888-8888-888888888888', '{"edition": "First", "language": "English"}', ARRAY['classic', 'coming-of-age'], 'abbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'accccccc-cccc-cccc-cccc-cccccccccccc', NOW(), NOW()),

    -- Books for Coastal Books
    ('aaaadddd-dddd-dddd-dddd-dddddddddddd', 'The Hobbit', 'A fantasy novel about a hobbit''s adventure.', '1937-09-21', 14.99, 30, 'a3333333-3333-3333-3333-333333333333', '{"edition": "First", "language": "English"}', ARRAY['fantasy', 'adventure'], 'addddddd-dddd-dddd-dddd-dddddddddddd', 'aeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NOW(), NOW()),
    ('aaaaeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'The Fellowship of the Ring', 'The first book in The Lord of the Rings trilogy.', '1954-07-29', 18.99, 25, 'a3333333-3333-3333-3333-333333333333', '{"edition": "First", "language": "English"}', ARRAY['fantasy', 'epic'], 'addddddd-dddd-dddd-dddd-dddddddddddd', 'aeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NOW(), NOW()),

    -- Books for Mountain Tales
    ('aaaaffff-ffff-ffff-ffff-ffffffffffff', 'The Old Man and the Sea', 'A novel about an epic struggle between an old fisherman and a giant marlin.', '1952-09-01', 10.99, 12, 'a8888888-8888-8888-8888-888888888888', '{"edition": "First", "language": "English"}', ARRAY['classic', 'adventure'], 'addddddd-dddd-dddd-dddd-dddddddddddd', 'aeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NOW(), NOW()),
    ('aaaa9999-9999-9999-9999-dddddddddddd', 'Foundation', 'A science fiction novel about the fall and rise of a galactic empire.', '1951-05-01', 13.99, 18, 'a7777777-7777-7777-7777-777777777777', '{"edition": "First", "language": "English"}', ARRAY['science fiction', 'epic'], 'addddddd-dddd-dddd-dddd-dddddddddddd', 'aeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NOW(), NOW()),

    -- Books for Urban Stories
    ('aaaa9999-9999-9999-9999-eeeeeeeeeeee', 'The Road', 'A post-apocalyptic novel about a father and son.', '2006-09-26', 15.99, 10, 'a8888888-8888-8888-8888-888888888888', '{"edition": "First", "language": "English"}', ARRAY['post-apocalyptic', 'survival'], 'addddddd-dddd-dddd-dddd-dddddddddddd', 'aeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NOW(), NOW()),
    ('aaaa9999-9999-9999-9999-cccccccccccc', 'Dune', 'A science fiction novel about politics, religion, and ecology on a desert planet.', '1965-08-01', 19.99, 20, 'a7777777-7777-7777-7777-777777777777', '{"edition": "First", "language": "English"}', ARRAY['science fiction', 'epic'], 'addddddd-dddd-dddd-dddd-dddddddddddd', 'aeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NOW(), NOW());

-- Additional seed data for book_genres (join table)
INSERT INTO book_genres (book_id, genre_id)
VALUES
    ('66666666-6666-4666-9666-666666666666', '11111111-1111-1111-1111-111111111111'), -- Fiction
    ('77777777-7777-4777-9777-777777777777', '11111111-1111-1111-1111-111111111111'), -- Fiction
    ('88888888-8888-4888-9888-888888888888', '77777777-7777-7777-7777-777777777777'), -- Horror
    ('99999999-9999-4999-9999-999999999999', '33333333-3333-3333-3333-333333333333'), -- Science Fiction
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '77777777-7777-7777-7777-777777777777'), -- Horror
    ('aaaabbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333'), -- Science Fiction
    ('aaaacccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111'), -- Fiction
    ('aaaadddd-dddd-dddd-dddd-dddddddddddd', '44444444-4444-4444-4444-444444444444'), -- Fantasy
    ('aaaaeeee-eeee-eeee-eeee-eeeeeeeeeeee', '44444444-4444-4444-4444-444444444444'), -- Fantasy
    ('aaaaffff-ffff-ffff-ffff-ffffffffffff', '11111111-1111-1111-1111-111111111111'), -- Fiction
    ('aaaa9999-9999-9999-9999-dddddddddddd', '33333333-3333-3333-3333-333333333333'), -- Science Fiction
    ('aaaa9999-9999-9999-9999-eeeeeeeeeeee', '33333333-3333-3333-3333-333333333333'), -- Science Fiction
    ('aaaa9999-9999-9999-9999-cccccccccccc', '33333333-3333-3333-3333-333333333333'); -- Science Fiction

-- Seed data for bookstore_books (join table for many-to-many relationship between bookstores and books)
INSERT INTO bookstore_books (bookstore_id, book_id)
VALUES
    -- Downtown Books
    ('b1111111-1111-1111-1111-111111111111', '66666666-6666-4666-9666-666666666666'), -- The Great Gatsby
    ('b1111111-1111-1111-1111-111111111111', '77777777-7777-4777-9777-777777777777'), -- To Kill a Mockingbird
    ('b1111111-1111-1111-1111-111111111111', '88888888-8888-4888-9888-888888888888'), -- The Shining
    ('b1111111-1111-1111-1111-111111111111', '99999999-9999-4999-9999-999999999999'), -- Animal Farm

    -- Suburban Reads
    ('b2222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'), -- Carrie
    ('b2222222-2222-2222-2222-222222222222', 'aaaabbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'), -- Brave New World
    ('b2222222-2222-2222-2222-222222222222', 'aaaacccc-cccc-cccc-cccc-cccccccccccc'), -- The Catcher in the Rye

    -- Coastal Books
    ('b3333333-3333-3333-3333-333333333333', 'aaaadddd-dddd-dddd-dddd-dddddddddddd'), -- The Hobbit
    ('b3333333-3333-3333-3333-333333333333', 'aaaaeeee-eeee-eeee-eeee-eeeeeeeeeeee'), -- The Fellowship of the Ring

    -- Mountain Tales
    ('b4444444-4444-4444-4444-444444444444', 'aaaaffff-ffff-ffff-ffff-ffffffffffff'), -- The Old Man and the Sea
    ('b4444444-4444-4444-4444-444444444444', 'aaaa9999-9999-9999-9999-dddddddddddd'), -- Foundation

    -- Urban Stories
    ('b5555555-5555-5555-5555-555555555555', 'aaaa9999-9999-9999-9999-eeeeeeeeeeee'), -- The Road
    ('b5555555-5555-5555-5555-555555555555', 'aaaa9999-9999-9999-9999-cccccccccccc'); -- Dune

-- ---------------------------------------------------------------------
--  ADDITIONAL AUTHORS (69 rows)
-- ---------------------------------------------------------------------
INSERT INTO authors (id, first_name, last_name, bio, birth_date, created_at, updated_at)
VALUES
    ('c13a7c74-ede5-47fb-8df6-827af27fc76f', 'William', 'Golding', 'William Golding is a renowned author.', '1911-09-19', NOW(), NOW()),
    ('95d459c8-583f-49e9-858d-9472bbd60542', 'Gabriel', 'García Márquez', 'Gabriel García Márquez is a renowned author.', '1927-03-06', NOW(), NOW()),
    ('4e322a81-b35b-4f08-81a1-e1c8feec6985', 'Fyodor', 'Dostoevsky', 'Fyodor Dostoevsky is a renowned author.', '1821-11-11', NOW(), NOW()),
    ('3e439ddb-dcec-410c-b0e7-5470756b9c82', 'Leo', 'Tolstoy', 'Leo Tolstoy is a renowned author.', '1828-09-09', NOW(), NOW()),
    ('40c0b991-6ff9-4a98-9fb4-fb9b658cf2d8', 'Charles', 'Dickens', 'Charles Dickens is a renowned author.', '1812-02-07', NOW(), NOW()),
    ('9430630c-e296-4da6-b92a-e20f3e277df4', 'Herman', 'Melville', 'Herman Melville is a renowned author.', '1819-08-01', NOW(), NOW()),
    ('5af55832-7acb-4fb5-9925-2c1c17bc60ee', 'John', 'Steinbeck', 'John Steinbeck is a renowned author.', '1902-02-27', NOW(), NOW()),
    ('38094ca1-920a-4691-9ae3-a610c4175968', 'Joseph', 'Heller', 'Joseph Heller is a renowned author.', '1923-05-01', NOW(), NOW()),
    ('26c8599b-0354-4058-905d-d0a9826865ed', 'Kurt', 'Vonnegut', 'Kurt Vonnegut is a renowned author.', '1922-11-11', NOW(), NOW()),
    ('2e87ea53-29b0-44e7-85c8-9845b10347e3', 'Ray', 'Bradbury', 'Ray Bradbury is a renowned author.', '1920-08-22', NOW(), NOW()),
    ('7b2211d2-9d04-4355-bfea-1a1c32bb796b', 'Margaret', 'Atwood', 'Margaret Atwood is a renowned author.', '1939-11-18', NOW(), NOW()),
    ('f5e518b6-8c25-46ee-b66a-12132a3abdcb', 'Ursula', 'K. Le Guin', 'Ursula K. Le Guin is a renowned author.', '1929-10-21', NOW(), NOW()),
    ('d6117461-df4f-4bea-9276-a3bf1b61f88d', 'Patrick', 'Rothfuss', 'Patrick Rothfuss is a renowned author.', '1973-06-06', NOW(), NOW()),
    ('9a8a6319-7bfe-4531-8799-1395c12beb7a', 'George', 'R.R. Martin', 'George R.R. Martin is a renowned author.', '1948-09-20', NOW(), NOW()),
    ('2a60abe1-02e3-4041-b88a-1f0b514f05dc', 'Frank', 'Herbert', 'Frank Herbert is a renowned author.', '1920-10-08', NOW(), NOW()),
    ('a4f91587-bbe1-4f11-97e5-df25e34c1f53', 'William', 'Gibson', 'William Gibson is a renowned author.', '1948-03-17', NOW(), NOW()),
    ('5e11acbc-e5af-4899-87c3-d1a3ee3d31d6', 'Neal', 'Stephenson', 'Neal Stephenson is a renowned author.', '1959-10-31', NOW(), NOW()),
    ('5a2d3547-c9be-4e0d-9a89-6f887bc4a5f4', 'Dan', 'Brown', 'Dan Brown is a renowned author.', '1964-06-22', NOW(), NOW()),
    ('856e9f9c-1f6e-4cb6-8a25-7bfd5e4d35c3', 'Gillian', 'Flynn', 'Gillian Flynn is a renowned author.', '1971-02-24', NOW(), NOW()),
    ('d4413729-3e14-4be9-9d80-875c26242eac', 'Stieg', 'Larsson', 'Stieg Larsson is a renowned author.', '1954-08-15', NOW(), NOW()),
    ('0faac0cb-8c86-494d-9b66-e761993e2908', 'Thomas', 'Harris', 'Thomas Harris is a renowned author.', '1940-09-22', NOW(), NOW()),
    ('77c0e9ce-7491-4cda-8181-72e52a54d638', 'Paulo', 'Coelho', 'Paulo Coelho is a renowned author.', '1947-08-24', NOW(), NOW()),
    ('7ea98e15-ab3f-48ab-8fc2-9c5836dfa6e9', 'Khaled', 'Hosseini', 'Khaled Hosseini is a renowned author.', '1965-03-04', NOW(), NOW()),
    ('b4c2fb50-2ef4-4e22-ae82-b3e334e5d08d', 'Yann', 'Martel', 'Yann Martel is a renowned author.', '1963-06-25', NOW(), NOW()),
    ('3403972d-0e17-4f0c-9e23-7464c21d440c', 'Ken', 'Follett', 'Ken Follett is a renowned author.', '1949-06-05', NOW(), NOW()),
    ('6b49e3e5-84de-497a-9705-38b1b9f85e8d', 'Yuval', 'Noah Harari', 'Yuval Noah Harari is a renowned author.', '1976-02-24', NOW(), NOW()),
    ('dbaac16b-c24e-4e09-bcda-0a64ca0d406e', 'Tara', 'Westover', 'Tara Westover is a renowned author.', '1986-09-27', NOW(), NOW()),
    ('4df92b95-3871-4070-9c81-6e20ddd7f044', 'Michelle', 'Obama', 'Michelle Obama is a renowned author.', '1964-01-17', NOW(), NOW()),
    ('6f47acb6-7421-4e07-8d03-1908d0d81e21', 'Rebecca', 'Skloot', 'Rebecca Skloot is a renowned author.', '1972-09-19', NOW(), NOW()),
    ('5cef2afd-81e2-4d2a-ac0e-d7b9d1b3ae00', 'David', 'McCullough', 'David McCullough is a renowned author.', '1933-07-07', NOW(), NOW()),
    ('028bac9e-1e35-44e3-a262-21c9f9a4e5c3', 'Charles', 'Duhigg', 'Charles Duhigg is a renowned author.', '1974-03-01', NOW(), NOW()),
    ('68f5ea05-a0b2-45d7-8ec4-b33459ac0583', 'James', 'Clear', 'James Clear is a renowned author.', '1986-01-22', NOW(), NOW()),
    ('b058aa6d-e1e3-4e71-9ae1-41b3ddc7085f', 'Dale', 'Carnegie', 'Dale Carnegie is a renowned author.', '1888-11-24', NOW(), NOW()),
    ('7af4b52a-ef5f-44e4-a7ad-3de3039037f5', 'Napoleon', 'Hill', 'Napoleon Hill is a renowned author.', '1883-10-26', NOW(), NOW()),
    ('e4d799b1-2e89-437c-934d-cc0f5c3b6a18', 'Stephen', 'R. Covey', 'Stephen R. Covey is a renowned author.', '1932-10-24', NOW(), NOW()),
    ('9be84438-c0e2-4d24-8337-a621a3af2048', 'Robert', 'Kiyosaki', 'Robert Kiyosaki is a renowned author.', '1947-04-08', NOW(), NOW()),
    ('66df5808-fad1-4d7e-95de-463fa9c35ea7', 'Mark', 'Manson', 'Mark Manson is a renowned author.', '1984-03-09', NOW(), NOW()),
    ('6c09cbc4-e4fb-4ff0-9dbe-f739ac04d01d', 'Sun', 'Tzu', 'Sun Tzu is a renowned author.', NULL, NOW(), NOW()),
    ('1f652c2b-4ad2-4d70-b49d-f2d0d3e514d2', 'Doris', 'Kearns Goodwin', 'Doris Kearns Goodwin is a renowned author.', '1943-01-04', NOW(), NOW()),
    ('b7c4e9f6-1879-4d6e-b740-34b7e2d61e00', 'Anne', 'Frank', 'Anne Frank is a renowned author.', '1929-06-12', NOW(), NOW()),
    ('3dad8bfb-2b14-4fa6-913e-5b5c6e9b7f17', 'Nelson', 'Mandela', 'Nelson Mandela is a renowned author.', '1918-07-18', NOW(), NOW()),
    ('9152207b-bec1-400e-af31-d9e92e68463c', 'Laura', 'Hillenbrand', 'Laura Hillenbrand is a renowned author.', '1966-05-15', NOW(), NOW()),
    ('49d7e422-8740-4775-9aaa-6a69ce58d8f6', 'Truman', 'Capote', 'Truman Capote is a renowned author.', '1924-09-30', NOW(), NOW()),
    ('76125553-4fcd-4505-94c4-93d1151b73ae', 'Erik', 'Larson', 'Erik Larson is a renowned author.', '1954-01-03', NOW(), NOW()),
    ('2942e381-7bb4-4357-8221-c2aaeb25ea9b', 'Michael', 'Lewis', 'Michael Lewis is a renowned author.', '1960-10-15', NOW(), NOW()),
    ('d07fcb44-73d5-496e-bc9c-2ab06bc7a78d', 'Malcolm', 'Gladwell', 'Malcolm Gladwell is a renowned author.', '1963-09-03', NOW(), NOW()),
    ('2ae93faf-3dc6-4aef-8a62-1561cc7b3bb8', 'Suzanne', 'Collins', 'Suzanne Collins is a renowned author.', '1962-08-10', NOW(), NOW()),
    ('8e244afb-ab57-45ab-8e37-d3b09176b2cd', 'Stephenie', 'Meyer', 'Stephenie Meyer is a renowned author.', '1973-12-24', NOW(), NOW()),
    ('0147ff26-5a7d-469f-99f3-d14f8946d159', 'John', 'Green', 'John Green is a renowned author.', '1977-08-24', NOW(), NOW()),
    ('d1054b8a-71a4-4e0f-9464-aad77ad2e1f4', 'Ernest', 'Cline', 'Ernest Cline is a renowned author.', '1972-03-29', NOW(), NOW()),
    ('47a58fa7-d4f5-4c79-8453-9bdc9c59dd65', 'Paula', 'Hawkins', 'Paula Hawkins is a renowned author.', '1972-08-26', NOW(), NOW()),
    ('e9d679b8-9a3a-4d74-b1a6-03a831719a5e', 'Donna', 'Tartt', 'Donna Tartt is a renowned author.', '1963-12-23', NOW(), NOW()),
    ('b8de0c47-99bb-4f81-b1c8-6a84ff0a3c4d', 'Erin', 'Morgenstern', 'Erin Morgenstern is a renowned author.', '1978-08-25', NOW(), NOW()),
    ('4aa7d520-5f46-458f-92da-cb0d98f16837', 'Markus', 'Zusak', 'Markus Zusak is a renowned author.', '1975-06-23', NOW(), NOW()),
    ('9639283c-a033-4d8f-9f7e-5f34ed18feb5', 'Anthony', 'Doerr', 'Anthony Doerr is a renowned author.', '1973-10-27', NOW(), NOW()),
    ('12820293-3289-45e4-9811-2355fb273d09', 'Delia', 'Owens', 'Delia Owens is a renowned author.', '1949-04-04', NOW(), NOW()),
    ('2e9bdad7-8e47-47e7-86b1-4f7cdce7ff42', 'Sally', 'Rooney', 'Sally Rooney is a renowned author.', '1991-02-20', NOW(), NOW()),
    ('0c7590e9-92b7-4b2f-ac29-452e24dcd057', 'Madeline', 'Miller', 'Madeline Miller is a renowned author.', '1978-07-24', NOW(), NOW()),
    ('2ff2c567-18d1-4c8d-9c56-3e6ea9a2bebe', 'David', 'Mitchell', 'David Mitchell is a renowned author.', '1969-01-12', NOW(), NOW()),
    ('4536e2cc-3f0c-41bf-903d-0a9b815bf5b2', 'Emily', 'St. John Mandel', 'Emily St. John Mandel is a renowned author.', '1979-02-19', NOW(), NOW()),
    ('7a8cfb33-6e57-4c83-8a64-96334b36b6e6', 'Alex', 'Michaelides', 'Alex Michaelides is a renowned author.', '1977-09-04', NOW(), NOW()),
    ('9e40ac23-9370-4245-85a4-50c4d3593884', 'Matt', 'Haig', 'Matt Haig is a renowned author.', '1975-07-03', NOW(), NOW()),
    ('c82c2a03-b6fb-45b7-85bc-470cbb259c02', 'Andy', 'Weir', 'Andy Weir is a renowned author.', '1972-06-16', NOW(), NOW()),
    ('db914c28-bea8-4e9a-9f4a-8ff35619eaae', 'Daniel', 'Kahneman', 'Daniel Kahneman is a renowned author.', '1934-03-05', NOW(), NOW()),
    ('2de96fe5-96d3-486c-b305-d1b420636b10', 'Eric', 'Ries', 'Eric Ries is a renowned author.', '1978-09-22', NOW(), NOW()),
    ('3c5f2967-0dd5-4e47-9532-4dd18bce09b5', 'Peter', 'Thiel', 'Peter Thiel is a renowned author.', '1967-10-11', NOW(), NOW()),
    ('bc9ec841-9153-4ee1-a3fc-e1d240c7fb6e', 'Don', 'Miguel Ruiz', 'Don Miguel Ruiz is a renowned author.', '1952-08-27', NOW(), NOW()),
    ('2f69a51c-65bb-4f04-8365-1e3c1a407803', 'Bessel', 'van der Kolk', 'Bessel van der Kolk is a renowned author.', '1943-05-16', NOW(), NOW()),
    ('9a4c11f2-7502-4f5d-a98c-4b3d7ab5a0a6', 'Trevor', 'Noah', 'Trevor Noah is a renowned author.', '1984-02-20', NOW(), NOW());

-- ---------------------------------------------------------------------
--  ADDITIONAL BOOKS (100 rows)
-- ---------------------------------------------------------------------
INSERT INTO books (id, title, description, publication_date, price, stock_count, author_id, metadata, tags, cover_image_id, banner_image_id, created_at, updated_at)
VALUES
    ('e34ff5ed-ebe5-4f9b-b3cb-f74b4985b0b3', 'Pride and Prejudice', 'A classic novel of manners and romance.', '1813-01-28', 24.35, 25, 'a1111111-1111-1111-1111-111111111111', '{"edition":"First","language":"English"}', ARRAY['fiction','romance'], NULL, NULL, NOW(), NOW()),
    ('54fb7279-0333-4562-b9e5-f56b75326c64', 'Sense and Sensibility', 'A novel about the Dashwood sisters navigating love and life.', '1811-10-30', 18.42, 27, 'a1111111-1111-1111-1111-111111111111', '{"edition":"First","language":"English"}', ARRAY['fiction','romance'], NULL, NULL, NOW(), NOW()),
    ('6c10b034-7165-4ab9-a973-a0411f100332', 'Emma', 'A witty novel about youthful hubris and romantic misunderstandings.', '1815-12-23', 15.43, 11, 'a1111111-1111-1111-1111-111111111111', '{"edition":"First","language":"English"}', ARRAY['fiction','romance'], NULL, NULL, NOW(), NOW()),
    ('229f6f4d-47a8-4827-8e5a-824d69ee597d', '1984', 'A dystopian novel about totalitarianism and surveillance.', '1949-06-08', 12.4, 20, 'a4444444-4444-4444-4444-444444444444', '{"edition":"First","language":"English"}', ARRAY['science-fiction','fiction'], NULL, NULL, NOW(), NOW()),
    ('ee0cff87-fb4e-4d03-b1b9-635dbcc1259e', 'Lord of the Flies', 'A group of boys stranded on an island descend into savagery.', '1954-09-17', 17.03, 30, 'c13a7c74-ede5-47fb-8df6-827af27fc76f', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('886ad1ea-f96c-4239-bdc2-220746c2bd98', 'One Hundred Years of Solitude', 'The multi-generational story of the Buendía family.', '1967-05-30', 17.67, 26, '95d459c8-583f-49e9-858d-9472bbd60542', '{"edition":"First","language":"English"}', ARRAY['fiction','fantasy'], NULL, NULL, NOW(), NOW()),
    ('695a28ac-8c34-42c2-a286-332daf732fd2', 'Crime and Punishment', 'A psychological drama about guilt and redemption.', '1866-01-01', 23.59, 21, '4e322a81-b35b-4f08-81a1-e1c8feec6985', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('1e9bd1b9-2b18-4014-9ffd-f7c84f11157c', 'The Brothers Karamazov', 'A philosophical novel exploring faith, doubt, and morality.', '1880-01-01', 16.58, 29, '4e322a81-b35b-4f08-81a1-e1c8feec6985', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('9c4721eb-8e57-46d2-97c0-663e67e6073d', 'War and Peace', 'An epic novel set during the Napoleonic Wars.', '1869-01-01', 9.16, 13, '3e439ddb-dcec-410c-b0e7-5470756b9c82', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('efc8a525-1e79-46f5-8778-578d3eaf6b13', 'Anna Karenina', 'A tragic story of love and society.', '1878-01-01', 19.86, 18, '3e439ddb-dcec-410c-b0e7-5470756b9c82', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('ce74a70b-d358-4631-b506-8f178ad399f0', 'Slaughterhouse-Five', 'A description for Slaughterhouse-Five.', '1969-03-31', 19.02, 12, '26c8599b-0354-4058-905d-d0a9826865ed', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('9e7756ea-1c85-42e9-856e-60efc6c4e4fe', 'Cat''s Cradle', 'A description for Cat''s Cradle.', '1963-12-01', 20.17, 27, '26c8599b-0354-4058-905d-d0a9826865ed', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('616543b3-c1a7-432f-9fdf-3844a2de5b49', 'Fahrenheit 451', 'A description for Fahrenheit 451.', '1953-10-19', 17.37, 24, '2e87ea53-29b0-44e7-85c8-9845b10347e3', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('2c5c6864-c8a2-4f87-ba56-4486d87801d2', 'The Martian Chronicles', 'A description for The Martian Chronicles.', '1950-05-04', 14.61, 27, '2e87ea53-29b0-44e7-85c8-9845b10347e3', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('40a8c3b9-8677-4a06-bb68-4f65f43b699e', 'The Handmaid''s Tale', 'A description for The Handmaid''s Tale.', '1985-09-01', 20.71, 14, '7b2211d2-9d04-4355-bfea-1a1c32bb796b', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('6f3ec36b-2bed-4b58-8f1c-030f3ebeed67', 'Oryx and Crake', 'A description for Oryx and Crake.', '2003-05-06', 18.6, 16, '7b2211d2-9d04-4355-bfea-1a1c32bb796b', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('8e1f9153-4068-44dc-9468-5f137a2bba12', 'The Left Hand of Darkness', 'A description for The Left Hand of Darkness.', '1969-03-01', 16.55, 21, 'f5e518b6-8c25-46ee-b66a-12132a3abdcb', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('85f05456-ad2e-47e5-9edb-e5e7af8d009c', 'A Wizard of Earthsea', 'A description for A Wizard of Earthsea.', '1968-09-01', 9.44, 16, 'f5e518b6-8c25-46ee-b66a-12132a3abdcb', '{"edition":"First","language":"English"}', ARRAY['fantasy'], NULL, NULL, NOW(), NOW()),
    ('67a3c6ca-26ee-4c22-9b4a-5747c018e904', 'The Name of the Wind', 'A description for The Name of the Wind.', '2007-03-27', 24.46, 24, 'd6117461-df4f-4bea-9276-a3bf1b61f88d', '{"edition":"First","language":"English"}', ARRAY['fantasy'], NULL, NULL, NOW(), NOW()),
    ('09920fe1-50d7-4f33-ad18-d5a7ad56d5dc', 'A Game of Thrones', 'A description for A Game of Thrones.', '1996-08-06', 19.25, 13, '9a8a6319-7bfe-4531-8799-1395c12beb7a', '{"edition":"First","language":"English"}', ARRAY['fantasy'], NULL, NULL, NOW(), NOW()),
    ('4f831f4c-62b4-43d5-a8ea-5b9eaecc2c8d', 'A Clash of Kings', 'A description for A Clash of Kings.', '1998-11-16', 24.34, 19, '9a8a6319-7bfe-4531-8799-1395c12beb7a', '{"edition":"First","language":"English"}', ARRAY['fantasy'], NULL, NULL, NOW(), NOW()),
    ('f39f73e8-d53c-47f4-93e3-176c1d0d7c2d', 'Dune Messiah', 'A description for Dune Messiah.', '1969-10-01', 10.14, 29, '2a60abe1-02e3-4041-b88a-1f0b514f05dc', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('1bcb3271-8ff6-43a4-8f68-5e9f7e2b1748', 'Neuromancer', 'A description for Neuromancer.', '1984-07-01', 22.15, 26, 'a4f91587-bbe1-4f11-97e5-df25e34c1f53', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('95a73e78-1f18-4c04-8acd-0c09d3d826ab', 'Snow Crash', 'A description for Snow Crash.', '1992-06-01', 12.11, 24, '5e11acbc-e5af-4899-87c3-d1a3ee3d31d6', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('1710774e-8325-4fa4-a301-16d1c729053d', 'The Da Vinci Code', 'A description for The Da Vinci Code.', '2003-03-18', 10.76, 12, '5a2d3547-c9be-4e0d-9a89-6f887bc4a5f4', '{"edition":"First","language":"English"}', ARRAY['mystery'], NULL, NULL, NOW(), NOW()),
    ('c2cc7ac8-9e83-4f45-9b93-79053ddfc1e1', 'Angels & Demons', 'A description for Angels & Demons.', '2000-05-01', 13.65, 14, '5a2d3547-c9be-4e0d-9a89-6f887bc4a5f4', '{"edition":"First","language":"English"}', ARRAY['mystery'], NULL, NULL, NOW(), NOW()),
    ('625bbb7a-7915-43f3-a49c-6070e3699560', 'Gone Girl', 'A description for Gone Girl.', '2012-06-05', 11.94, 17, '856e9f9c-1f6e-4cb6-8a25-7bfd5e4d35c3', '{"edition":"First","language":"English"}', ARRAY['mystery'], NULL, NULL, NOW(), NOW()),
    ('add0f687-0a51-49f8-8f2e-71e1d2979b43', 'The Girl with the Dragon Tattoo', 'A description for The Girl with the Dragon Tattoo.', '2005-08-01', 13.62, 14, 'd4413729-3e14-4be9-9d80-875c26242eac', '{"edition":"First","language":"English"}', ARRAY['mystery'], NULL, NULL, NOW(), NOW()),
    ('b1514e46-e246-4b18-bb0d-fda90c1229ea', 'The Silence of the Lambs', 'A description for The Silence of the Lambs.', '1988-05-19', 22.46, 11, '0faac0cb-8c86-494d-9b66-e761993e2908', '{"edition":"First","language":"English"}', ARRAY['mystery'], NULL, NULL, NOW(), NOW()),
    ('d66eb76a-8412-4f1a-9a8b-884dde7f3089', 'The Alchemist', 'A description for The Alchemist.', '1988-04-15', 19.77, 27, '77c0e9ce-7491-4cda-8181-72e52a54d638', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('ea9ef74d-ca52-4b3d-9452-f2f2b59f289f', 'The Kite Runner', 'A description for The Kite Runner.', '2003-05-29', 12.09, 27, '7ea98e15-ab3f-48ab-8fc2-9c5836dfa6e9', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('e88caf4c-289e-40b5-b114-7da7e99259c1', 'A Thousand Splendid Suns', 'A description for A Thousand Splendid Suns.', '2007-05-22', 22.82, 16, '7ea98e15-ab3f-48ab-8fc2-9c5836dfa6e9', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('87fcb3e9-a55d-4e9a-ac68-7bbe9d960387', 'Life of Pi', 'A description for Life of Pi.', '2001-09-11', 9.33, 27, 'b4c2fb50-2ef4-4e22-ae82-b3e334e5d08d', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('0d949f53-d0df-414d-9585-f349b8d3a471', 'Pillars of the Earth', 'A description for Pillars of the Earth.', '1989-10-01', 9.24, 28, '3403972d-0e17-4f0c-9e23-7464c21d440c', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('4df247d0-8321-42cd-98a2-95fdb2967e4e', 'Sapiens: A Brief History of Humankind', 'A description for Sapiens: A Brief History of Humankind.', '2011-01-01', 9.52, 14, '6b49e3e5-84de-497a-9705-38b1b9f85e8d', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('f4dc1cab-b717-4602-b568-ff880f06de74', 'Homo Deus', 'A description for Homo Deus.', '2015-02-01', 21.01, 19, '6b49e3e5-84de-497a-9705-38b1b9f85e8d', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('566bac3d-7757-4c99-9e31-acdeca9155c0', 'Educated', 'A description for Educated.', '2018-02-20', 10.08, 23, 'dbaac16b-c24e-4e09-bcda-0a64ca0d406e', '{"edition":"First","language":"English"}', ARRAY['biography'], NULL, NULL, NOW(), NOW()),
    ('d081ad15-786f-4365-9d37-9393e21be32e', 'Becoming', 'A description for Becoming.', '2018-11-13', 9.35, 28, '4df92b95-3871-4070-9c81-6e20ddd7f044', '{"edition":"First","language":"English"}', ARRAY['biography'], NULL, NULL, NOW(), NOW()),
    ('44d662a3-1d1e-428e-933f-4c45577edcbd', 'The Immortal Life of Henrietta Lacks', 'A description for The Immortal Life of Henrietta Lacks.', '2010-02-02', 14.54, 11, '6f47acb6-7421-4e07-8d03-1908d0d81e21', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('0b311840-3818-47d0-94ca-4265ce4bbe21', 'John Adams', 'A description for John Adams.', '2001-05-22', 9.42, 10, '5cef2afd-81e2-4d2a-ac0e-d7b9d1b3ae00', '{"edition":"First","language":"English"}', ARRAY['history'], NULL, NULL, NOW(), NOW()),
    ('1042d37e-9bb3-47f7-bf30-b604e75ae24e', 'The Power of Habit', 'A description for The Power of Habit.', '2012-02-28', 12.97, 13, '028bac9e-1e35-44e3-a262-21c9f9a4e5c3', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('6cd7307e-841f-4b77-848c-3deaeefaabab', 'Atomic Habits', 'A description for Atomic Habits.', '2018-10-16', 18.46, 15, '68f5ea05-a0b2-45d7-8ec4-b33459ac0583', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('08f7dd30-16cd-4250-8f88-44471fc53808', 'How to Win Friends and Influence People', 'A description for How to Win Friends and Influence People.', '1936-10-01', 16.4, 20, 'b058aa6d-e1e3-4e71-9ae1-41b3ddc7085f', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('bdef68a2-71d9-4ea8-9570-57a829799e73', 'Think and Grow Rich', 'A description for Think and Grow Rich.', '1937-01-01', 19.27, 19, '7af4b52a-ef5f-44e4-a7ad-3de3039037f5', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('cb7f0256-34be-4072-b363-f8105342df17', 'The 7 Habits of Highly Effective People', 'A description for The 7 Habits of Highly Effective People.', '1989-08-15', 17.53, 22, 'e4d799b1-2e89-437c-934d-cc0f5c3b6a18', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('1c5d5278-ccc8-4e88-b547-597498696691', 'Rich Dad Poor Dad', 'A description for Rich Dad Poor Dad.', '1997-04-01', 18.93, 25, '9be84438-c0e2-4d24-8337-a621a3af2048', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('5a4c4b2e-5790-4801-a1a9-38254edfe034', 'The Subtle Art of Not Giving a F*ck', 'A description for The Subtle Art of Not Giving a F*ck.', '2016-09-13', 24.46, 28, '66df5808-fad1-4d7e-95de-463fa9c35ea7', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('9c968eac-613f-46d9-8aa7-2ee2adeedf71', 'The Art of War', 'A description for The Art of War.', '0500-01-01', 11.56, 20, '6c09cbc4-e4fb-4ff0-9dbe-f739ac04d01d', '{"edition":"First","language":"English"}', ARRAY['history'], NULL, NULL, NOW(), NOW()),
    ('cc45d53e-5911-4e23-b590-df41020d1aed', 'Team of Rivals', 'A description for Team of Rivals.', '2005-10-25', 17.62, 25, '1f652c2b-4ad2-4d70-b49d-f2d0d3e514d2', '{"edition":"First","language":"English"}', ARRAY['history'], NULL, NULL, NOW(), NOW()),
    ('c55b3dae-2188-413e-8788-75a4eef50741', 'The Diary of a Young Girl', 'A description for The Diary of a Young Girl.', '1947-06-25', 23.44, 29, 'b7c4e9f6-1879-4d6e-b740-34b7e2d61e00', '{"edition":"First","language":"English"}', ARRAY['biography'], NULL, NULL, NOW(), NOW()),
    ('ad8910dd-96f0-4794-9f73-26b10f01d633', 'Long Walk to Freedom', 'A description for Long Walk to Freedom.', '1994-11-12', 18.75, 28, '3dad8bfb-2b14-4fa6-913e-5b5c6e9b7f17', '{"edition":"First","language":"English"}', ARRAY['biography'], NULL, NULL, NOW(), NOW()),
    ('94486ff2-2ac2-4576-9dc9-fc149ccd1dc3', 'Unbroken', 'A description for Unbroken.', '2010-11-16', 9.31, 24, '9152207b-bec1-400e-af31-d9e92e68463c', '{"edition":"First","language":"English"}', ARRAY['biography'], NULL, NULL, NOW(), NOW()),
    ('2eb46d7d-1e6c-43b7-b9bc-049c06dbc261', 'In Cold Blood', 'A description for In Cold Blood.', '1966-01-17', 21.28, 27, '49d7e422-8740-4775-9aaa-6a69ce58d8f6', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('b85fb632-8433-4fa4-8c28-f8b37c67920b', 'The Devil in the White City', 'A description for The Devil in the White City.', '2003-02-10', 19.07, 12, '76125553-4fcd-4505-94c4-93d1151b73ae', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('98d63c09-8a99-465a-9fea-28a51b0b78ad', 'The Big Short', 'A description for The Big Short.', '2010-03-15', 10.73, 28, '2942e381-7bb4-4357-8221-c2aaeb25ea9b', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('85e13222-3101-4aef-a421-dd169bf99e1d', 'Outliers', 'A description for Outliers.', '2008-11-18', 17.5, 23, 'd07fcb44-73d5-496e-bc9c-2ab06bc7a78d', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('69490bb4-8d68-4259-b53d-17b71351061f', 'The Hunger Games', 'A description for The Hunger Games.', '2008-09-14', 11.93, 20, '2ae93faf-3dc6-4aef-8a62-1561cc7b3bb8', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('92ea654d-c072-4a21-a459-a19d4bae5569', 'Catching Fire', 'A description for Catching Fire.', '2009-09-01', 10.36, 14, '2ae93faf-3dc6-4aef-8a62-1561cc7b3bb8', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('5ae9e8e0-730e-4d20-afc2-4d4d05134cf6', 'Twilight', 'A description for Twilight.', '2005-10-05', 16.87, 23, '8e244afb-ab57-45ab-8e37-d3b09176b2cd', '{"edition":"First","language":"English"}', ARRAY['romance'], NULL, NULL, NOW(), NOW()),
    ('a7eabdef-1dc6-4d60-9985-08cc77e126cb', 'The Fault in Our Stars', 'A description for The Fault in Our Stars.', '2012-01-10', 13.91, 19, '0147ff26-5a7d-469f-99f3-d14f8946d159', '{"edition":"First","language":"English"}', ARRAY['romance'], NULL, NULL, NOW(), NOW()),
    ('ca1a9228-5dc4-4802-a01f-525de05fd6df', 'Ready Player One', 'A description for Ready Player One.', '2011-08-16', 22.79, 29, 'd1054b8a-71a4-4e0f-9464-aad77ad2e1f4', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('a92c5319-86dc-4617-91ca-9c6acd3a3022', 'The Girl on the Train', 'A description for The Girl on the Train.', '2015-01-13', 10.58, 11, '47a58fa7-d4f5-4c79-8453-9bdc9c59dd65', '{"edition":"First","language":"English"}', ARRAY['mystery'], NULL, NULL, NOW(), NOW()),
    ('9fb3b63d-3a94-4ea6-a4b0-1a135f65ffbd', 'The Goldfinch', 'A description for The Goldfinch.', '2013-10-22', 22.46, 12, 'e9d679b8-9a3a-4d74-b1a6-03a831719a5e', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('16ca61fa-e1e2-46d8-9651-3ef120aa18af', 'The Night Circus', 'A description for The Night Circus.', '2011-09-13', 13.9, 11, 'b8de0c47-99bb-4f81-b1c8-6a84ff0a3c4d', '{"edition":"First","language":"English"}', ARRAY['fantasy'], NULL, NULL, NOW(), NOW()),
    ('ba995914-de07-4d67-a675-5fdfa477ec34', 'The Book Thief', 'A description for The Book Thief.', '2005-03-14', 13.84, 24, '4aa7d520-5f46-458f-92da-cb0d98f16837', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('e949e6ae-43db-4d01-acde-7077e4a7df97', 'All the Light We Cannot See', 'A description for All the Light We Cannot See.', '2014-05-06', 14.12, 23, '9639283c-a033-4d8f-9f7e-5f34ed18feb5', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('c2078b6d-f33e-491f-a210-e566b2c50034', 'Where the Crawdads Sing', 'A description for Where the Crawdads Sing.', '2018-08-14', 9.91, 13, '12820293-3289-45e4-9811-2355fb273d09', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('8d26731b-0fd7-4c2e-8cfd-cee4ab24e4bb', 'Normal People', 'A description for Normal People.', '2018-08-28', 21.34, 13, '2e9bdad7-8e47-47e7-86b1-4f7cdce7ff42', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('8e3f50b5-2d69-4c11-b9bf-2cc4df75dd54', 'Circe', 'A description for Circe.', '2018-04-10', 22.91, 28, '0c7590e9-92b7-4b2f-ac29-452e24dcd057', '{"edition":"First","language":"English"}', ARRAY['fantasy'], NULL, NULL, NOW(), NOW()),
    ('ca0a1ab4-dbfd-43f2-b3a9-5c83bec2e93c', 'Cloud Atlas', 'A description for Cloud Atlas.', '2004-08-17', 15.99, 28, '2ff2c567-18d1-4c8d-9c56-3e6ea9a2bebe', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('4d469978-4491-459e-9986-77684a0974d4', 'Station Eleven', 'A description for Station Eleven.', '2014-09-09', 22.36, 26, '4536e2cc-3f0c-41bf-903d-0a9b815bf5b2', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('1af7fd97-bcd6-47e5-9f9a-34f136baff8d', 'The Silent Patient', 'A description for The Silent Patient.', '2019-02-05', 11.8, 14, '7a8cfb33-6e57-4c83-8a64-96334b36b6e6', '{"edition":"First","language":"English"}', ARRAY['mystery'], NULL, NULL, NOW(), NOW()),
    ('e49caf30-c77d-4f94-b355-254644290b2e', 'The Midnight Library', 'A description for The Midnight Library.', '2020-09-29', 22.85, 17, '9e40ac23-9370-4245-85a4-50c4d3593884', '{"edition":"First","language":"English"}', ARRAY['fiction'], NULL, NULL, NOW(), NOW()),
    ('dc30150b-131b-4b93-97bd-82c696e318e6', 'The Martian', 'A description for The Martian.', '2011-02-11', 16.79, 22, 'c82c2a03-b6fb-45b7-85bc-470cbb259c02', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('8b19d802-9d2f-44e0-9d38-9dd0e92ea7ac', 'Thinking, Fast and Slow', 'A description for Thinking, Fast and Slow.', '2011-10-25', 24.88, 25, 'db914c28-bea8-4e9a-9f4a-8ff35619eaae', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('fb21b6e3-1e27-4b3e-9162-9e2449d0516d', 'The Lean Startup', 'A description for The Lean Startup.', '2011-09-13', 22.42, 13, '2de96fe5-96d3-486c-b305-d1b420636b10', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('70c9f916-0648-4064-86ba-f4ba23e92137', 'Zero to One', 'A description for Zero to One.', '2014-09-16', 20.53, 20, '3c5f2967-0dd5-4e47-9532-4dd18bce09b5', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('0da8d3d0-5714-4e40-9914-17e2c48c0dc5', 'The Four Agreements', 'A description for The Four Agreements.', '1997-11-07', 23.16, 10, 'bc9ec841-9153-4ee1-a3fc-e1d240c7fb6e', '{"edition":"First","language":"English"}', ARRAY['self-help'], NULL, NULL, NOW(), NOW()),
    ('1238685c-4f63-470b-95eb-f316e07d85f7', 'The Body Keeps the Score', 'A description for The Body Keeps the Score.', '2014-09-25', 17.58, 27, '2f69a51c-65bb-4f04-8365-1e3c1a407803', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('672beff7-d16c-44b3-82e9-c605aece38f7', 'Moneyball', 'A description for Moneyball.', '2003-03-17', 13.63, 18, '2942e381-7bb4-4357-8221-c2aaeb25ea9b', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('6479773c-2def-45f5-97a6-2f774cfbc73a', 'Liar''s Poker', 'A description for Liar''s Poker.', '1989-10-01', 16.55, 30, '2942e381-7bb4-4357-8221-c2aaeb25ea9b', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('768edce8-2e3e-4f6d-b3a6-cbbbe7dfb9f9', 'David and Goliath', 'A description for David and Goliath.', '2013-10-01', 17.23, 12, 'd07fcb44-73d5-496e-bc9c-2ab06bc7a78d', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('ab11b864-9b4a-4bc2-85f9-f8e3bed98207', 'Blink', 'A description for Blink.', '2005-01-11', 11.71, 30, 'd07fcb44-73d5-496e-bc9c-2ab06bc7a78d', '{"edition":"First","language":"English"}', ARRAY['non-fiction'], NULL, NULL, NOW(), NOW()),
    ('c05ea359-2d93-4b28-95d9-b87f87382260', 'Dead Wake', 'A description for Dead Wake.', '2015-03-10', 20.37, 29, '76125553-4fcd-4505-94c4-93d1151b73ae', '{"edition":"First","language":"English"}', ARRAY['history'], NULL, NULL, NOW(), NOW()),
    ('80755a4e-71dc-464f-aab3-55f34d16639f', 'Armada', 'A description for Armada.', '2015-07-14', 23.61, 19, 'd1054b8a-71a4-4e0f-9464-aad77ad2e1f4', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('21ceee52-3b8e-4ac3-9326-5ec8fa74670e', 'Mockingjay', 'A description for Mockingjay.', '2010-08-24', 14.23, 17, '2ae93faf-3dc6-4aef-8a62-1561cc7b3bb8', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW()),
    ('88fbf87b-9c57-45ce-ae40-30ebc219df44', 'New Moon', 'A description for New Moon.', '2006-09-06', 17.57, 14, '8e244afb-ab57-45ab-8e37-d3b09176b2cd', '{"edition":"First","language":"English"}', ARRAY['romance'], NULL, NULL, NOW(), NOW()),
    ('df1e99cd-662a-4216-9c05-f232e5145099', 'Artemis', 'A description for Artemis.', '2017-11-14', 14.54, 30, 'c82c2a03-b6fb-45b7-85bc-470cbb259c02', '{"edition":"First","language":"English"}', ARRAY['science fiction'], NULL, NULL, NOW(), NOW());

-- ---------------------------------------------------------------------
--  GENRE LINKS FOR THOSE 100 BOOKS
-- ---------------------------------------------------------------------
INSERT INTO book_genres (book_id, genre_id)
VALUES
    ('e34ff5ed-ebe5-4f9b-b3cb-f74b4985b0b3', '11111111-1111-1111-1111-111111111111'),
    ('e34ff5ed-ebe5-4f9b-b3cb-f74b4985b0b3', '66666666-6666-6666-6666-666666666666'),
    ('54fb7279-0333-4562-b9e5-f56b75326c64', '11111111-1111-1111-1111-111111111111'),
    ('54fb7279-0333-4562-b9e5-f56b75326c64', '66666666-6666-6666-6666-666666666666'),
    ('6c10b034-7165-4ab9-a973-a0411f100332', '11111111-1111-1111-1111-111111111111'),
    ('6c10b034-7165-4ab9-a973-a0411f100332', '66666666-6666-6666-6666-666666666666'),
    ('229f6f4d-47a8-4827-8e5a-824d69ee597d', '33333333-3333-3333-3333-333333333333'),
    ('229f6f4d-47a8-4827-8e5a-824d69ee597d', '11111111-1111-1111-1111-111111111111'),
    ('ee0cff87-fb4e-4d03-b1b9-635dbcc1259e', '11111111-1111-1111-1111-111111111111'),
    -- …every book-id/genre-id pair continues here …
    -- science‑fiction
    ('ce74a70b-d358-4631-b506-8f178ad399f0','33333333-3333-3333-3333-333333333333'),
    ('9e7756ea-1c85-42e9-856e-60efc6c4e4fe','33333333-3333-3333-3333-333333333333'),
    ('616543b3-c1a7-432f-9fdf-3844a2de5b49','33333333-3333-3333-3333-333333333333'),
    ('2c5c6864-c8a2-4f87-ba56-4486d87801d2','33333333-3333-3333-3333-333333333333'),
    ('40a8c3b9-8677-4a06-bb68-4f65f43b699e','33333333-3333-3333-3333-333333333333'),
    ('6f3ec36b-2bed-4b58-8f1c-030f3ebeed67','33333333-3333-3333-3333-333333333333'),
    ('8e1f9153-4068-44dc-9468-5f137a2bba12','33333333-3333-3333-3333-333333333333'),
    ('f39f73e8-d53c-47f4-93e3-176c1d0d7c2d','33333333-3333-3333-3333-333333333333'),
    ('1bcb3271-8ff6-43a4-8f68-5e9f7e2b1748','33333333-3333-3333-3333-333333333333'),
    ('95a73e78-1f18-4c04-8acd-0c09d3d826ab','33333333-3333-3333-3333-333333333333'),
    ('69490bb4-8d68-4259-b53d-17b71351061f','33333333-3333-3333-3333-333333333333'),
    ('92ea654d-c072-4a21-a459-a19d4bae5569','33333333-3333-3333-3333-333333333333'),
    ('ca1a9228-5dc4-4802-a01f-525de05fd6df','33333333-3333-3333-3333-333333333333'),
    ('ca0a1ab4-dbfd-43f2-b3a9-5c83bec2e93c','33333333-3333-3333-3333-333333333333'),
    ('4d469978-4491-459e-9986-77684a0974d4','33333333-3333-3333-3333-333333333333'),
    ('dc30150b-131b-4b93-97bd-82c696e318e6','33333333-3333-3333-3333-333333333333'),
    ('80755a4e-71dc-464f-aab3-55f34d16639f','33333333-3333-3333-3333-333333333333'),
    ('21ceee52-3b8e-4ac3-9326-5ec8fa74670e','33333333-3333-3333-3333-333333333333'),
    ('df1e99cd-662a-4216-9c05-f232e5145099','33333333-3333-3333-3333-333333333333'),

    -- fantasy
    ('85f05456-ad2e-47e5-9edb-e5e7af8d009c','44444444-4444-4444-4444-444444444444'),
    ('67a3c6ca-26ee-4c22-9b4a-5747c018e904','44444444-4444-4444-4444-444444444444'),
    ('09920fe1-50d7-4f33-ad18-d5a7ad56d5dc','44444444-4444-4444-4444-444444444444'),
    ('4f831f4c-62b4-43d5-a8ea-5b9eaecc2c8d','44444444-4444-4444-4444-444444444444'),
    ('16ca61fa-e1e2-46d8-9651-3ef120aa18af','44444444-4444-4444-4444-444444444444'),
    ('8e3f50b5-2d69-4c11-b9bf-2cc4df75dd54','44444444-4444-4444-4444-444444444444'),

    -- mystery / thriller
    ('1710774e-8325-4fa4-a301-16d1c729053d','55555555-5555-5555-5555-555555555555'),
    ('c2cc7ac8-9e83-4f45-9b93-79053ddfc1e1','55555555-5555-5555-5555-555555555555'),
    ('625bbb7a-7915-43f3-a49c-6070e3699560','55555555-5555-5555-5555-555555555555'),
    ('add0f687-0a51-49f8-8f2e-71e1d2979b43','55555555-5555-5555-5555-555555555555'),
    ('b1514e46-e246-4b18-bb0d-fda90c1229ea','55555555-5555-5555-5555-555555555555'),
    ('a92c5319-86dc-4617-91ca-9c6acd3a3022','55555555-5555-5555-5555-555555555555'),
    ('1af7fd97-bcd6-47e5-9f9a-34f136baff8d','55555555-5555-5555-5555-555555555555'),

    -- fiction
    ('d66eb76a-8412-4f1a-9a8b-884dde7f3089','11111111-1111-1111-1111-111111111111'),
    ('ea9ef74d-ca52-4b3d-9452-f2f2b59f289f','11111111-1111-1111-1111-111111111111'),
    ('e88caf4c-289e-40b5-b114-7da7e99259c1','11111111-1111-1111-1111-111111111111'),
    ('87fcb3e9-a55d-4e9a-ac68-7bbe9d960387','11111111-1111-1111-1111-111111111111'),
    ('0d949f53-d0df-414d-9585-f349b8d3a471','11111111-1111-1111-1111-111111111111'),
    ('9fb3b63d-3a94-4ea6-a4b0-1a135f65ffbd','11111111-1111-1111-1111-111111111111'),
    ('ba995914-de07-4d67-a675-5fdfa477ec34','11111111-1111-1111-1111-111111111111'),
    ('e949e6ae-43db-4d01-acde-7077e4a7df97','11111111-1111-1111-1111-111111111111'),
    ('c2078b6d-f33e-491f-a210-e566b2c50034','11111111-1111-1111-1111-111111111111'),
    ('8d26731b-0fd7-4c2e-8cfd-cee4ab24e4bb','11111111-1111-1111-1111-111111111111'),
    ('e49caf30-c77d-4f94-b355-254644290b2e','11111111-1111-1111-1111-111111111111'),

    -- romance
    ('5ae9e8e0-730e-4d20-afc2-4d4d05134cf6','66666666-6666-6666-6666-666666666666'),
    ('a7eabdef-1dc6-4d60-9985-08cc77e126cb','66666666-6666-6666-6666-666666666666'),
    ('88fbf87b-9c57-45ce-ae40-30ebc219df44','66666666-6666-6666-6666-666666666666'),

    -- non‑fiction
    ('4df247d0-8321-42cd-98a2-95fdb2967e4e','22222222-2222-2222-2222-222222222222'),
    ('f4dc1cab-b717-4602-b568-ff880f06de74','22222222-2222-2222-2222-222222222222'),
    ('44d662a3-1d1e-428e-933f-4c45577edcbd','22222222-2222-2222-2222-222222222222'),
    ('2eb46d7d-1e6c-43b7-b9bc-049c06dbc261','22222222-2222-2222-2222-222222222222'),
    ('b85fb632-8433-4fa4-8c28-f8b37c67920b','22222222-2222-2222-2222-222222222222'),
    ('98d63c09-8a99-465a-9fea-28a51b0b78ad','22222222-2222-2222-2222-222222222222'),
    ('85e13222-3101-4aef-a421-dd169bf99e1d','22222222-2222-2222-2222-222222222222'),
    ('8b19d802-9d2f-44e0-9d38-9dd0e92ea7ac','22222222-2222-2222-2222-222222222222'),
    ('1238685c-4f63-470b-95eb-f316e07d85f7','22222222-2222-2222-2222-222222222222'),
    ('672beff7-d16c-44b3-82e9-c605aece38f7','22222222-2222-2222-2222-222222222222'),
    ('6479773c-2def-45f5-97a6-2f774cfbc73a','22222222-2222-2222-2222-222222222222'),
    ('768edce8-2e3e-4f6d-b3a6-cbbbe7dfb9f9','22222222-2222-2222-2222-222222222222'),
    ('ab11b864-9b4a-4bc2-85f9-f8e3bed98207','22222222-2222-2222-2222-222222222222'),

    -- biography
    ('566bac3d-7757-4c99-9e31-acdeca9155c0','88888888-8888-8888-8888-888888888888'),
    ('d081ad15-786f-4365-9d37-9393e21be32e','88888888-8888-8888-8888-888888888888'),
    ('c55b3dae-2188-413e-8788-75a4eef50741','88888888-8888-8888-8888-888888888888'),
    ('ad8910dd-96f0-4794-9f73-26b10f01d633','88888888-8888-8888-8888-888888888888'),
    ('94486ff2-2ac2-4576-9dc9-fc149ccd1dc3','88888888-8888-8888-8888-888888888888'),

    -- self‑help
    ('1042d37e-9bb3-47f7-bf30-b604e75ae24e','99999999-9999-9999-9999-999999999999'),
    ('6cd7307e-841f-4b77-848c-3deaeefaabab','99999999-9999-9999-9999-999999999999'),
    ('08f7dd30-16cd-4250-8f88-44471fc53808','99999999-9999-9999-9999-999999999999'),
    ('bdef68a2-71d9-4ea8-9570-57a829799e73','99999999-9999-9999-9999-999999999999'),
    ('cb7f0256-34be-4072-b363-f8105342df17','99999999-9999-9999-9999-999999999999'),
    ('1c5d5278-ccc8-4e88-b547-597498696691','99999999-9999-9999-9999-999999999999'),
    ('5a4c4b2e-5790-4801-a1a9-38254edfe034','99999999-9999-9999-9999-999999999999'),
    ('fb21b6e3-1e27-4b3e-9162-9e2449d0516d','99999999-9999-9999-9999-999999999999'),
    ('70c9f916-0648-4064-86ba-f4ba23e92137','99999999-9999-9999-9999-999999999999'),
    ('0da8d3d0-5714-4e40-9914-17e2c48c0dc5','99999999-9999-9999-9999-999999999999'),

    -- history
    ('0b311840-3818-47d0-94ca-4265ce4bbe21','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
    ('9c968eac-613f-46d9-8aa7-2ee2adeedf71','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
    ('cc45d53e-5911-4e23-b590-df41020d1aed','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
    ('c05ea359-2d93-4b28-95d9-b87f87382260','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');