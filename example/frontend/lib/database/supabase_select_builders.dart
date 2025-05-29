// GENERATED CODE - DO NOT MODIFY BY HAND
// Generator for Supabase/SQLite select query strings with type-safe builders.

// ignore_for_file: type_init_formals

import 'package:tether_libs/models/supabase_select_builder_base.dart';
import 'supabase_schema.dart'; // Import the generated schema

enum BookstoresColumn implements SupabaseColumn {
  address('address', 'address', 'bookstores', null),
  createdAt('created_at', 'created_at', 'bookstores', null),
  establishedDate('established_date', 'established_date', 'bookstores', null),
  id('id', 'id', 'bookstores', null),
  isOpen('is_open', 'is_open', 'bookstores', null),
  name('name', 'name', 'bookstores', null),
  updatedAt('updated_at', 'updated_at', 'bookstores', null),
;
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const BookstoresColumn(this.originalName, this.localName, this.tableName, this.relationshipPrefix);

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => 'bookstores.$originalName';

  @override
  String get fullyQualified => relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);
}


class BookstoresSelectBuilder extends SupabaseSelectBuilderBase {

  BookstoresSelectBuilder() : super(primaryTableKey: 'public.bookstores', currentTableInfo: globalSupabaseSchema['public.bookstores']!);

  BookstoresSelectBuilder select([List<BookstoresColumn>? columns]) {
    if (columns == null || columns.isEmpty) {
      selectAll();
    } else {
      final dbColumnNames = columns.map((e) => e.dbName).toList();
      selectSupabaseColumns(dbColumnNames);
    }
    return this;
  }

  BookstoresSelectBuilder withBookstoreBooks(BookstoreBooksSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BookstoreBooksSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'bookstore_books',
        fkConstraintName: 'bookstore_books_bookstore_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

}


enum AuthorsColumn implements SupabaseColumn {
  bio('bio', 'bio', 'authors', null),
  birthDate('birth_date', 'birth_date', 'authors', null),
  createdAt('created_at', 'created_at', 'authors', null),
  deathDate('death_date', 'death_date', 'authors', null),
  document('document', 'document', 'authors', null),
  firstName('first_name', 'first_name', 'authors', null),
  id('id', 'id', 'authors', null),
  lastName('last_name', 'last_name', 'authors', null),
  updatedAt('updated_at', 'updated_at', 'authors', null),
;
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const AuthorsColumn(this.originalName, this.localName, this.tableName, this.relationshipPrefix);

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => 'authors.$originalName';

  @override
  String get fullyQualified => relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);
}


class AuthorsSelectBuilder extends SupabaseSelectBuilderBase {

  AuthorsSelectBuilder() : super(primaryTableKey: 'public.authors', currentTableInfo: globalSupabaseSchema['public.authors']!);

  AuthorsSelectBuilder select([List<AuthorsColumn>? columns]) {
    if (columns == null || columns.isEmpty) {
      selectAll();
    } else {
      final dbColumnNames = columns.map((e) => e.dbName).toList();
      selectSupabaseColumns(dbColumnNames);
    }
    return this;
  }

  AuthorsSelectBuilder withBooks(BooksSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BooksSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'books',
        fkConstraintName: 'books_author_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

}


enum GenresColumn implements SupabaseColumn {
  createdAt('created_at', 'created_at', 'genres', null),
  description('description', 'description', 'genres', null),
  id('id', 'id', 'genres', null),
  name('name', 'name', 'genres', null),
  updatedAt('updated_at', 'updated_at', 'genres', null),
;
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const GenresColumn(this.originalName, this.localName, this.tableName, this.relationshipPrefix);

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => 'genres.$originalName';

  @override
  String get fullyQualified => relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);
}


class GenresSelectBuilder extends SupabaseSelectBuilderBase {

  GenresSelectBuilder() : super(primaryTableKey: 'public.genres', currentTableInfo: globalSupabaseSchema['public.genres']!);

  GenresSelectBuilder select([List<GenresColumn>? columns]) {
    if (columns == null || columns.isEmpty) {
      selectAll();
    } else {
      final dbColumnNames = columns.map((e) => e.dbName).toList();
      selectSupabaseColumns(dbColumnNames);
    }
    return this;
  }

  GenresSelectBuilder withBookGenres(BookGenresSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BookGenresSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'book_genres',
        fkConstraintName: 'book_genres_genre_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

}


enum ImagesColumn implements SupabaseColumn {
  altText('alt_text', 'alt_text', 'images', null),
  createdAt('created_at', 'created_at', 'images', null),
  id('id', 'id', 'images', null),
  updatedAt('updated_at', 'updated_at', 'images', null),
  url('url', 'url', 'images', null),
;
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const ImagesColumn(this.originalName, this.localName, this.tableName, this.relationshipPrefix);

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => 'images.$originalName';

  @override
  String get fullyQualified => relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);
}


class ImagesSelectBuilder extends SupabaseSelectBuilderBase {

  ImagesSelectBuilder() : super(primaryTableKey: 'public.images', currentTableInfo: globalSupabaseSchema['public.images']!);

  ImagesSelectBuilder select([List<ImagesColumn>? columns]) {
    if (columns == null || columns.isEmpty) {
      selectAll();
    } else {
      final dbColumnNames = columns.map((e) => e.dbName).toList();
      selectSupabaseColumns(dbColumnNames);
    }
    return this;
  }

  ImagesSelectBuilder withBannerImages(BooksSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BooksSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'banner_images',
        fkConstraintName: 'books_banner_image_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

  ImagesSelectBuilder withCoverImages(BooksSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BooksSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'cover_images',
        fkConstraintName: 'books_cover_image_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

}


enum BooksColumn implements SupabaseColumn {
  authorId('author_id', 'author_id', 'books', null),
  bannerImageId('banner_image_id', 'banner_image_id', 'books', null),
  coverImageId('cover_image_id', 'cover_image_id', 'books', null),
  createdAt('created_at', 'created_at', 'books', null),
  description('description', 'description', 'books', null),
  document('document', 'document', 'books', null),
  id('id', 'id', 'books', null),
  metadata('metadata', 'metadata', 'books', null),
  price('price', 'price', 'books', null),
  publicationDate('publication_date', 'publication_date', 'books', null),
  stockCount('stock_count', 'stock_count', 'books', null),
  tags('tags', 'tags', 'books', null),
  title('title', 'title', 'books', null),
  updatedAt('updated_at', 'updated_at', 'books', null),
;
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const BooksColumn(this.originalName, this.localName, this.tableName, this.relationshipPrefix);

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => 'books.$originalName';

  @override
  String get fullyQualified => relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);
}


class BooksSelectBuilder extends SupabaseSelectBuilderBase {

  BooksSelectBuilder() : super(primaryTableKey: 'public.books', currentTableInfo: globalSupabaseSchema['public.books']!);

  BooksSelectBuilder select([List<BooksColumn>? columns]) {
    if (columns == null || columns.isEmpty) {
      selectAll();
    } else {
      final dbColumnNames = columns.map((e) => e.dbName).toList();
      selectSupabaseColumns(dbColumnNames);
    }
    return this;
  }

  BooksSelectBuilder withAuthor(AuthorsSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? AuthorsSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'author',
        fkConstraintName: 'books_author_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

  BooksSelectBuilder withBannerImage(ImagesSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? ImagesSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'banner_image',
        fkConstraintName: 'books_banner_image_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

  BooksSelectBuilder withCoverImage(ImagesSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? ImagesSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'cover_image',
        fkConstraintName: 'books_cover_image_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

  BooksSelectBuilder withBookGenres(BookGenresSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BookGenresSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'book_genres',
        fkConstraintName: 'book_genres_book_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

  BooksSelectBuilder withBookstoreBooks(BookstoreBooksSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BookstoreBooksSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'bookstore_books',
        fkConstraintName: 'bookstore_books_book_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

}


enum BookGenresColumn implements SupabaseColumn {
  bookId('book_id', 'book_id', 'book_genres', null),
  genreId('genre_id', 'genre_id', 'book_genres', null),
  id('id', 'id', 'book_genres', null),
;
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const BookGenresColumn(this.originalName, this.localName, this.tableName, this.relationshipPrefix);

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => 'book_genres.$originalName';

  @override
  String get fullyQualified => relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);
}


class BookGenresSelectBuilder extends SupabaseSelectBuilderBase {

  BookGenresSelectBuilder() : super(primaryTableKey: 'public.book_genres', currentTableInfo: globalSupabaseSchema['public.book_genres']!);

  BookGenresSelectBuilder select([List<BookGenresColumn>? columns]) {
    if (columns == null || columns.isEmpty) {
      selectAll();
    } else {
      final dbColumnNames = columns.map((e) => e.dbName).toList();
      selectSupabaseColumns(dbColumnNames);
    }
    return this;
  }

  BookGenresSelectBuilder withBook(BooksSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BooksSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'book',
        fkConstraintName: 'book_genres_book_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

  BookGenresSelectBuilder withGenre(GenresSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? GenresSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'genre',
        fkConstraintName: 'book_genres_genre_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

}


enum BookstoreBooksColumn implements SupabaseColumn {
  bookId('book_id', 'book_id', 'bookstore_books', null),
  bookstoreId('bookstore_id', 'bookstore_id', 'bookstore_books', null),
  id('id', 'id', 'bookstore_books', null),
;
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const BookstoreBooksColumn(this.originalName, this.localName, this.tableName, this.relationshipPrefix);

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => 'bookstore_books.$originalName';

  @override
  String get fullyQualified => relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);
}


class BookstoreBooksSelectBuilder extends SupabaseSelectBuilderBase {

  BookstoreBooksSelectBuilder() : super(primaryTableKey: 'public.bookstore_books', currentTableInfo: globalSupabaseSchema['public.bookstore_books']!);

  BookstoreBooksSelectBuilder select([List<BookstoreBooksColumn>? columns]) {
    if (columns == null || columns.isEmpty) {
      selectAll();
    } else {
      final dbColumnNames = columns.map((e) => e.dbName).toList();
      selectSupabaseColumns(dbColumnNames);
    }
    return this;
  }

  BookstoreBooksSelectBuilder withBook(BooksSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BooksSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'book',
        fkConstraintName: 'bookstore_books_book_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

  BookstoreBooksSelectBuilder withBookstore(BookstoresSelectBuilder? builder, {bool innerJoin = false}) {
    final finalBuilder = builder ?? BookstoresSelectBuilder();
    if (builder == null) {
      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder
    }
    addSupabaseRelated(
        jsonKey: 'bookstore',
        fkConstraintName: 'bookstore_books_bookstore_id_fkey',
        nestedBuilder: finalBuilder,
        innerJoin: innerJoin);
    return this;
  }

}


enum ProfilesColumn implements SupabaseColumn {
  avatarUrl('avatar_url', 'avatar_url', 'profiles', null),
  createdAt('created_at', 'created_at', 'profiles', null),
  fullName('full_name', 'full_name', 'profiles', null),
  id('id', 'id', 'profiles', null),
  updatedAt('updated_at', 'updated_at', 'profiles', null),
  username('username', 'username', 'profiles', null),
  website('website', 'website', 'profiles', null),
;
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const ProfilesColumn(this.originalName, this.localName, this.tableName, this.relationshipPrefix);

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => 'profiles.$originalName';

  @override
  String get fullyQualified => relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);
}


class ProfilesSelectBuilder extends SupabaseSelectBuilderBase {

  ProfilesSelectBuilder() : super(primaryTableKey: 'public.profiles', currentTableInfo: globalSupabaseSchema['public.profiles']!);

  ProfilesSelectBuilder select([List<ProfilesColumn>? columns]) {
    if (columns == null || columns.isEmpty) {
      selectAll();
    } else {
      final dbColumnNames = columns.map((e) => e.dbName).toList();
      selectSupabaseColumns(dbColumnNames);
    }
    return this;
  }

}


