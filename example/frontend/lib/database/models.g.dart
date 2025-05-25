// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'dart:convert';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:tether_libs/models/tether_model.dart';

/// Represents the `bookstores` table.
class BookstoreModel extends TetherModel<BookstoreModel> {
  final Map<String, dynamic>? address;
  final DateTime? createdAt;
  final DateTime? establishedDate;
  final String id;
  final bool? isOpen;
  final String name;
  final DateTime? updatedAt;
  final List<BookstoreBookModel>? bookstoreBooks;

  BookstoreModel({
    this.address,
    this.createdAt,
    this.establishedDate,
    required this.id,
    this.isOpen,
    required this.name,
    this.updatedAt,
    this.bookstoreBooks,
  }) : super({
         'address': address,
         'created_at': createdAt,
         'established_date': establishedDate,
         'id': id,
         'is_open': isOpen,
         'name': name,
         'updated_at': updatedAt,
         'bookstoreBooks': bookstoreBooks,
       });

  /// The primary key for this model instance.
  @override
  String get localId => id;

  /// Creates an instance from a JSON map (e.g., from Supabase).
  factory BookstoreModel.fromJson(Map<String, dynamic> json) {
    return BookstoreModel(
      address: json['address'] == null ? null : (json['address'] is Map<String, dynamic> ? json['address'] : jsonDecode(json['address'] as String) as Map<String, dynamic>),
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      establishedDate: json['established_date'] == null ? null : DateTime.parse(json['established_date'] as String),
      id: json['id']! as String,
      isOpen: json['is_open'] == null ? null : json['is_open'] as bool,
      name: json['name']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      bookstoreBooks: (json['bookstoreBooks'] as List<dynamic>?)?.map((e) => BookstoreBookModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Creates an instance from a map (e.g., from SQLite row containing nested JSON in 'jsobjects' column).
  factory BookstoreModel.fromSqlite(Row row) {
    final String? jsonDataString = row['jsobjects'] as String?;
    if (jsonDataString == null) {
      // Or handle as an error, depending on expected data integrity. This might lead to issues if fields are required.
      // For example, you could throw an exception: 
      // throw ArgumentError('SQLite row is missing 'jsobjects' column for BookstoreModel deserialization.');
      // Alternatively, if a model can be validly empty or with all nulls (if fields allow):
      // return BookstoreModel(/* pass all nulls or default values if constructor allows */);
      // For now, we'll create an empty map, and let constructor validation handle missing required fields.
    }
    final Map<String, dynamic> json = jsonDataString == null ? <String, dynamic>{} : jsonDecode(jsonDataString) as Map<String, dynamic>;

    return BookstoreModel(
      address: json['address'] == null ? null : (json['address'] is Map<String, dynamic> ? json['address'] : jsonDecode(json['address'] as String) as Map<String, dynamic>),
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      establishedDate: json['established_date'] == null ? null : DateTime.parse(json['established_date'] as String),
      id: json['id']! as String,
      isOpen: json['is_open'] == null ? null : json['is_open'] as bool,
      name: json['name']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      bookstoreBooks: null, // Reverse relations not populated from jsobjects
    );
  }

  /// Converts the instance to a JSON map (for Supabase).
  @override
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'established_date': establishedDate?.toIso8601String(),
      'id': id,
      'is_open': isOpen,
      'name': name,
      'updated_at': updatedAt?.toIso8601String(),
      'bookstoreBooks': bookstoreBooks?.map((e) => e.toJson()).toList(),
    };
  }

  /// Converts the instance to a map suitable for SQLite insertion/update.
  @override
  Map<String, dynamic> toSqlite() {
    return {
      'address': address == null ? null : jsonEncode(address),
      'created_at': createdAt?.toIso8601String(),
      'established_date': establishedDate?.toIso8601String(),
      'id': id,
      'is_open': isOpen == null ? null : (isOpen! ? 1 : 0),
      'name': name,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this instance with potentially modified fields.
  @override
  BookstoreModel copyWith({
    Map<String, dynamic>? address,
    DateTime? createdAt,
    DateTime? establishedDate,
    String? id,
    bool? isOpen,
    String? name,
    DateTime? updatedAt,
    List<BookstoreBookModel>? bookstoreBooks,
  }) {
    return BookstoreModel(
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      establishedDate: establishedDate ?? this.establishedDate,
      id: id ?? this.id,
      isOpen: isOpen ?? this.isOpen,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      bookstoreBooks: bookstoreBooks ?? this.bookstoreBooks,
    );
  }

  @override
  String toString() {
    return 'BookstoreModel(address: $address, createdAt: $createdAt, establishedDate: $establishedDate, id: $id, isOpen: $isOpen, name: $name, updatedAt: $updatedAt, bookstoreBooks: $bookstoreBooks)';
  }
}

/// Represents the `authors` table.
class AuthorModel extends TetherModel<AuthorModel> {
  final String? bio;
  final DateTime? birthDate;
  final DateTime? createdAt;
  final DateTime? deathDate;
  final String? document;
  final String firstName;
  final String id;
  final String lastName;
  final DateTime? updatedAt;
  final List<BookModel>? books;

  AuthorModel({
    this.bio,
    this.birthDate,
    this.createdAt,
    this.deathDate,
    this.document,
    required this.firstName,
    required this.id,
    required this.lastName,
    this.updatedAt,
    this.books,
  }) : super({
         'bio': bio,
         'birth_date': birthDate,
         'created_at': createdAt,
         'death_date': deathDate,
         'document': document,
         'first_name': firstName,
         'id': id,
         'last_name': lastName,
         'updated_at': updatedAt,
         'books': books,
       });

  /// The primary key for this model instance.
  @override
  String get localId => id;

  /// Creates an instance from a JSON map (e.g., from Supabase).
  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      bio: json['bio'] == null ? null : json['bio'] as String,
      birthDate: json['birth_date'] == null ? null : DateTime.parse(json['birth_date'] as String),
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      deathDate: json['death_date'] == null ? null : DateTime.parse(json['death_date'] as String),
      document: json['document'] == null ? null : json['document'] as String,
      firstName: json['first_name']! as String,
      id: json['id']! as String,
      lastName: json['last_name']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      books: (json['books'] as List<dynamic>?)?.map((e) => BookModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Creates an instance from a map (e.g., from SQLite row containing nested JSON in 'jsobjects' column).
  factory AuthorModel.fromSqlite(Row row) {
    final String? jsonDataString = row['jsobjects'] as String?;
    if (jsonDataString == null) {
      // Or handle as an error, depending on expected data integrity. This might lead to issues if fields are required.
      // For example, you could throw an exception: 
      // throw ArgumentError('SQLite row is missing 'jsobjects' column for AuthorModel deserialization.');
      // Alternatively, if a model can be validly empty or with all nulls (if fields allow):
      // return AuthorModel(/* pass all nulls or default values if constructor allows */);
      // For now, we'll create an empty map, and let constructor validation handle missing required fields.
    }
    final Map<String, dynamic> json = jsonDataString == null ? <String, dynamic>{} : jsonDecode(jsonDataString) as Map<String, dynamic>;

    return AuthorModel(
      bio: json['bio'] == null ? null : json['bio'] as String,
      birthDate: json['birth_date'] == null ? null : DateTime.parse(json['birth_date'] as String),
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      deathDate: json['death_date'] == null ? null : DateTime.parse(json['death_date'] as String),
      document: json['document'] == null ? null : json['document'] as String,
      firstName: json['first_name']! as String,
      id: json['id']! as String,
      lastName: json['last_name']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      books: null, // Reverse relations not populated from jsobjects
    );
  }

  /// Converts the instance to a JSON map (for Supabase).
  @override
  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'birth_date': birthDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'death_date': deathDate?.toIso8601String(),
      'document': document,
      'first_name': firstName,
      'id': id,
      'last_name': lastName,
      'updated_at': updatedAt?.toIso8601String(),
      'books': books?.map((e) => e.toJson()).toList(),
    };
  }

  /// Converts the instance to a map suitable for SQLite insertion/update.
  @override
  Map<String, dynamic> toSqlite() {
    return {
      'bio': bio,
      'birth_date': birthDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'death_date': deathDate?.toIso8601String(),
      'document': document,
      'first_name': firstName,
      'id': id,
      'last_name': lastName,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this instance with potentially modified fields.
  @override
  AuthorModel copyWith({
    String? bio,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? deathDate,
    String? document,
    String? firstName,
    String? id,
    String? lastName,
    DateTime? updatedAt,
    List<BookModel>? books,
  }) {
    return AuthorModel(
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      deathDate: deathDate ?? this.deathDate,
      document: document ?? this.document,
      firstName: firstName ?? this.firstName,
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      updatedAt: updatedAt ?? this.updatedAt,
      books: books ?? this.books,
    );
  }

  @override
  String toString() {
    return 'AuthorModel(bio: $bio, birthDate: $birthDate, createdAt: $createdAt, deathDate: $deathDate, document: $document, firstName: $firstName, id: $id, lastName: $lastName, updatedAt: $updatedAt, books: $books)';
  }
}

/// Represents the `genres` table.
class GenreModel extends TetherModel<GenreModel> {
  final DateTime? createdAt;
  final String? description;
  final String id;
  final String name;
  final DateTime? updatedAt;
  final List<BookGenreModel>? bookGenres;

  GenreModel({
    this.createdAt,
    this.description,
    required this.id,
    required this.name,
    this.updatedAt,
    this.bookGenres,
  }) : super({
         'created_at': createdAt,
         'description': description,
         'id': id,
         'name': name,
         'updated_at': updatedAt,
         'bookGenres': bookGenres,
       });

  /// The primary key for this model instance.
  @override
  String get localId => id;

  /// Creates an instance from a JSON map (e.g., from Supabase).
  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      description: json['description'] == null ? null : json['description'] as String,
      id: json['id']! as String,
      name: json['name']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      bookGenres: (json['bookGenres'] as List<dynamic>?)?.map((e) => BookGenreModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Creates an instance from a map (e.g., from SQLite row containing nested JSON in 'jsobjects' column).
  factory GenreModel.fromSqlite(Row row) {
    final String? jsonDataString = row['jsobjects'] as String?;
    if (jsonDataString == null) {
      // Or handle as an error, depending on expected data integrity. This might lead to issues if fields are required.
      // For example, you could throw an exception: 
      // throw ArgumentError('SQLite row is missing 'jsobjects' column for GenreModel deserialization.');
      // Alternatively, if a model can be validly empty or with all nulls (if fields allow):
      // return GenreModel(/* pass all nulls or default values if constructor allows */);
      // For now, we'll create an empty map, and let constructor validation handle missing required fields.
    }
    final Map<String, dynamic> json = jsonDataString == null ? <String, dynamic>{} : jsonDecode(jsonDataString) as Map<String, dynamic>;

    return GenreModel(
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      description: json['description'] == null ? null : json['description'] as String,
      id: json['id']! as String,
      name: json['name']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      bookGenres: null, // Reverse relations not populated from jsobjects
    );
  }

  /// Converts the instance to a JSON map (for Supabase).
  @override
  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt?.toIso8601String(),
      'description': description,
      'id': id,
      'name': name,
      'updated_at': updatedAt?.toIso8601String(),
      'bookGenres': bookGenres?.map((e) => e.toJson()).toList(),
    };
  }

  /// Converts the instance to a map suitable for SQLite insertion/update.
  @override
  Map<String, dynamic> toSqlite() {
    return {
      'created_at': createdAt?.toIso8601String(),
      'description': description,
      'id': id,
      'name': name,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this instance with potentially modified fields.
  @override
  GenreModel copyWith({
    DateTime? createdAt,
    String? description,
    String? id,
    String? name,
    DateTime? updatedAt,
    List<BookGenreModel>? bookGenres,
  }) {
    return GenreModel(
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      bookGenres: bookGenres ?? this.bookGenres,
    );
  }

  @override
  String toString() {
    return 'GenreModel(createdAt: $createdAt, description: $description, id: $id, name: $name, updatedAt: $updatedAt, bookGenres: $bookGenres)';
  }
}

/// Represents the `images` table.
class ImageModel extends TetherModel<ImageModel> {
  final String? altText;
  final DateTime? createdAt;
  final String id;
  final DateTime? updatedAt;
  final String url;
  final List<BookModel>? books;

  ImageModel({
    this.altText,
    this.createdAt,
    required this.id,
    this.updatedAt,
    required this.url,
    this.books,
  }) : super({
         'alt_text': altText,
         'created_at': createdAt,
         'id': id,
         'updated_at': updatedAt,
         'url': url,
         'books': books,
       });

  /// The primary key for this model instance.
  @override
  String get localId => id;

  /// Creates an instance from a JSON map (e.g., from Supabase).
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      altText: json['alt_text'] == null ? null : json['alt_text'] as String,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      id: json['id']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      url: json['url']! as String,
      books: (json['books'] as List<dynamic>?)?.map((e) => BookModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Creates an instance from a map (e.g., from SQLite row containing nested JSON in 'jsobjects' column).
  factory ImageModel.fromSqlite(Row row) {
    final String? jsonDataString = row['jsobjects'] as String?;
    if (jsonDataString == null) {
      // Or handle as an error, depending on expected data integrity. This might lead to issues if fields are required.
      // For example, you could throw an exception: 
      // throw ArgumentError('SQLite row is missing 'jsobjects' column for ImageModel deserialization.');
      // Alternatively, if a model can be validly empty or with all nulls (if fields allow):
      // return ImageModel(/* pass all nulls or default values if constructor allows */);
      // For now, we'll create an empty map, and let constructor validation handle missing required fields.
    }
    final Map<String, dynamic> json = jsonDataString == null ? <String, dynamic>{} : jsonDecode(jsonDataString) as Map<String, dynamic>;

    return ImageModel(
      altText: json['alt_text'] == null ? null : json['alt_text'] as String,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      id: json['id']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      url: json['url']! as String,
      books: null, // Reverse relations not populated from jsobjects
    );
  }

  /// Converts the instance to a JSON map (for Supabase).
  @override
  Map<String, dynamic> toJson() {
    return {
      'alt_text': altText,
      'created_at': createdAt?.toIso8601String(),
      'id': id,
      'updated_at': updatedAt?.toIso8601String(),
      'url': url,
      'books': books?.map((e) => e.toJson()).toList(),
    };
  }

  /// Converts the instance to a map suitable for SQLite insertion/update.
  @override
  Map<String, dynamic> toSqlite() {
    return {
      'alt_text': altText,
      'created_at': createdAt?.toIso8601String(),
      'id': id,
      'updated_at': updatedAt?.toIso8601String(),
      'url': url,
    };
  }

  /// Creates a copy of this instance with potentially modified fields.
  @override
  ImageModel copyWith({
    String? altText,
    DateTime? createdAt,
    String? id,
    DateTime? updatedAt,
    String? url,
    List<BookModel>? books,
  }) {
    return ImageModel(
      altText: altText ?? this.altText,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      url: url ?? this.url,
      books: books ?? this.books,
    );
  }

  @override
  String toString() {
    return 'ImageModel(altText: $altText, createdAt: $createdAt, id: $id, updatedAt: $updatedAt, url: $url, books: $books)';
  }
}

/// Represents the `books` table.
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
    return BookModel(
      authorId: json['author_id'] == null ? null : json['author_id'] as String,
      bannerImageId: json['banner_image_id'] == null ? null : json['banner_image_id'] as String,
      coverImageId: json['cover_image_id'] == null ? null : json['cover_image_id'] as String,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      description: json['description'] == null ? null : json['description'] as String,
      document: json['document'] == null ? null : json['document'] as String,
      id: json['id']! as String,
      metadata: json['metadata'] == null ? null : (json['metadata'] is Map<String, dynamic> ? json['metadata'] : jsonDecode(json['metadata'] as String) as Map<String, dynamic>),
      price: json['price'] == null ? null : (json['price'] as num).toDouble(),
      publicationDate: json['publication_date'] == null ? null : DateTime.parse(json['publication_date'] as String),
      stockCount: json['stock_count'] == null ? null : json['stock_count'] as int,
      tags: json['tags'] == null ? null : (json['tags'] is List<dynamic> ? List<String>.from(json['tags'].map((e) => e as String)) : List<String>.from((jsonDecode(json['tags'] as String) as List<dynamic>).map((e) => e as String))),
      title: json['title']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      author: json['author'] == null ? null : AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      bannerImage: json['bannerImage'] == null ? null : ImageModel.fromJson(json['bannerImage'] as Map<String, dynamic>),
      coverImage: json['coverImage'] == null ? null : ImageModel.fromJson(json['coverImage'] as Map<String, dynamic>),
      bookGenres: (json['bookGenres'] as List<dynamic>?)?.map((e) => BookGenreModel.fromJson(e as Map<String, dynamic>)).toList(),
      bookstoreBooks: (json['bookstoreBooks'] as List<dynamic>?)?.map((e) => BookstoreBookModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Creates an instance from a map (e.g., from SQLite row containing nested JSON in 'jsobjects' column).
  factory BookModel.fromSqlite(Row row) {
    final String? jsonDataString = row['jsobjects'] as String?;
    if (jsonDataString == null) {
      // Or handle as an error, depending on expected data integrity. This might lead to issues if fields are required.
      // For example, you could throw an exception: 
      // throw ArgumentError('SQLite row is missing 'jsobjects' column for BookModel deserialization.');
      // Alternatively, if a model can be validly empty or with all nulls (if fields allow):
      // return BookModel(/* pass all nulls or default values if constructor allows */);
      // For now, we'll create an empty map, and let constructor validation handle missing required fields.
    }
    final Map<String, dynamic> json = jsonDataString == null ? <String, dynamic>{} : jsonDecode(jsonDataString) as Map<String, dynamic>;

    return BookModel(
      authorId: json['author_id'] == null ? null : json['author_id'] as String,
      bannerImageId: json['banner_image_id'] == null ? null : json['banner_image_id'] as String,
      coverImageId: json['cover_image_id'] == null ? null : json['cover_image_id'] as String,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      description: json['description'] == null ? null : json['description'] as String,
      document: json['document'] == null ? null : json['document'] as String,
      id: json['id']! as String,
      metadata: json['metadata'] == null ? null : (json['metadata'] is Map<String, dynamic> ? json['metadata'] : jsonDecode(json['metadata'] as String) as Map<String, dynamic>),
      price: json['price'] == null ? null : (json['price'] as num).toDouble(),
      publicationDate: json['publication_date'] == null ? null : DateTime.parse(json['publication_date'] as String),
      stockCount: json['stock_count'] == null ? null : json['stock_count'] as int,
      tags: json['tags'] == null ? null : (json['tags'] is List<dynamic> ? List<String>.from(json['tags'].map((e) => e as String)) : List<String>.from((jsonDecode(json['tags'] as String) as List<dynamic>).map((e) => e as String))),
      title: json['title']! as String,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      author: json['author'] == null ? null : AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      bannerImage: json['bannerImage'] == null ? null : ImageModel.fromJson(json['bannerImage'] as Map<String, dynamic>),
      coverImage: json['coverImage'] == null ? null : ImageModel.fromJson(json['coverImage'] as Map<String, dynamic>),
      bookGenres: null, // Reverse relations not populated from jsobjects
      bookstoreBooks: null, // Reverse relations not populated from jsobjects
    );
  }

  /// Converts the instance to a JSON map (for Supabase).
  @override
  Map<String, dynamic> toJson() {
    return {
      'author_id': authorId,
      'banner_image_id': bannerImageId,
      'cover_image_id': coverImageId,
      'created_at': createdAt?.toIso8601String(),
      'description': description,
      'document': document,
      'id': id,
      'metadata': metadata,
      'price': price,
      'publication_date': publicationDate?.toIso8601String(),
      'stock_count': stockCount,
      'tags': tags,
      'title': title,
      'updated_at': updatedAt?.toIso8601String(),
      'author': author?.toJson(),
      'bannerImage': bannerImage?.toJson(),
      'coverImage': coverImage?.toJson(),
      'bookGenres': bookGenres?.map((e) => e.toJson()).toList(),
      'bookstoreBooks': bookstoreBooks?.map((e) => e.toJson()).toList(),
    };
  }

  /// Converts the instance to a map suitable for SQLite insertion/update.
  @override
  Map<String, dynamic> toSqlite() {
    return {
      'author_id': authorId,
      'banner_image_id': bannerImageId,
      'cover_image_id': coverImageId,
      'created_at': createdAt?.toIso8601String(),
      'description': description,
      'document': document,
      'id': id,
      'metadata': metadata == null ? null : jsonEncode(metadata),
      'price': price,
      'publication_date': publicationDate?.toIso8601String(),
      'stock_count': stockCount,
      'tags': tags,
      'title': title,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this instance with potentially modified fields.
  @override
  BookModel copyWith({
    String? authorId,
    String? bannerImageId,
    String? coverImageId,
    DateTime? createdAt,
    String? description,
    String? document,
    String? id,
    Map<String, dynamic>? metadata,
    double? price,
    DateTime? publicationDate,
    int? stockCount,
    List<String>? tags,
    String? title,
    DateTime? updatedAt,
    AuthorModel? author,
    ImageModel? bannerImage,
    ImageModel? coverImage,
    List<BookGenreModel>? bookGenres,
    List<BookstoreBookModel>? bookstoreBooks,
  }) {
    return BookModel(
      authorId: authorId ?? this.authorId,
      bannerImageId: bannerImageId ?? this.bannerImageId,
      coverImageId: coverImageId ?? this.coverImageId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      document: document ?? this.document,
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      price: price ?? this.price,
      publicationDate: publicationDate ?? this.publicationDate,
      stockCount: stockCount ?? this.stockCount,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      bannerImage: bannerImage ?? this.bannerImage,
      coverImage: coverImage ?? this.coverImage,
      bookGenres: bookGenres ?? this.bookGenres,
      bookstoreBooks: bookstoreBooks ?? this.bookstoreBooks,
    );
  }

  @override
  String toString() {
    return 'BookModel(authorId: $authorId, bannerImageId: $bannerImageId, coverImageId: $coverImageId, createdAt: $createdAt, description: $description, document: $document, id: $id, metadata: $metadata, price: $price, publicationDate: $publicationDate, stockCount: $stockCount, tags: $tags, title: $title, updatedAt: $updatedAt, author: $author, bannerImage: $bannerImage, coverImage: $coverImage, bookGenres: $bookGenres, bookstoreBooks: $bookstoreBooks)';
  }
}

/// Represents the `book_genres` table.
class BookGenreModel extends TetherModel<BookGenreModel> {
  final String? bookId;
  final String? genreId;
  final int id;
  final BookModel? book;
  final GenreModel? genre;

  BookGenreModel({
    this.bookId,
    this.genreId,
    required this.id,
    this.book,
    this.genre,
  }) : super({
         'book_id': bookId,
         'genre_id': genreId,
         'id': id,
         'book': book,
         'genre': genre,
       });

  /// The primary key for this model instance.
  @override
  int get localId => id;

  /// Creates an instance from a JSON map (e.g., from Supabase).
  factory BookGenreModel.fromJson(Map<String, dynamic> json) {
    return BookGenreModel(
      bookId: json['book_id'] == null ? null : json['book_id'] as String,
      genreId: json['genre_id'] == null ? null : json['genre_id'] as String,
      id: json['id']! as int,
      book: json['book'] == null ? null : BookModel.fromJson(json['book'] as Map<String, dynamic>),
      genre: json['genre'] == null ? null : GenreModel.fromJson(json['genre'] as Map<String, dynamic>),
    );
  }

  /// Creates an instance from a map (e.g., from SQLite row containing nested JSON in 'jsobjects' column).
  factory BookGenreModel.fromSqlite(Row row) {
    final String? jsonDataString = row['jsobjects'] as String?;
    if (jsonDataString == null) {
      // Or handle as an error, depending on expected data integrity. This might lead to issues if fields are required.
      // For example, you could throw an exception: 
      // throw ArgumentError('SQLite row is missing 'jsobjects' column for BookGenreModel deserialization.');
      // Alternatively, if a model can be validly empty or with all nulls (if fields allow):
      // return BookGenreModel(/* pass all nulls or default values if constructor allows */);
      // For now, we'll create an empty map, and let constructor validation handle missing required fields.
    }
    final Map<String, dynamic> json = jsonDataString == null ? <String, dynamic>{} : jsonDecode(jsonDataString) as Map<String, dynamic>;

    return BookGenreModel(
      bookId: json['book_id'] == null ? null : json['book_id'] as String,
      genreId: json['genre_id'] == null ? null : json['genre_id'] as String,
      id: json['id']! as int,
      book: json['book'] == null ? null : BookModel.fromJson(json['book'] as Map<String, dynamic>),
      genre: json['genre'] == null ? null : GenreModel.fromJson(json['genre'] as Map<String, dynamic>),
    );
  }

  /// Converts the instance to a JSON map (for Supabase).
  @override
  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'genre_id': genreId,
      'id': id,
      'book': book?.toJson(),
      'genre': genre?.toJson(),
    };
  }

  /// Converts the instance to a map suitable for SQLite insertion/update.
  @override
  Map<String, dynamic> toSqlite() {
    return {
      'book_id': bookId,
      'genre_id': genreId,
      'id': id,
    };
  }

  /// Creates a copy of this instance with potentially modified fields.
  @override
  BookGenreModel copyWith({
    String? bookId,
    String? genreId,
    int? id,
    BookModel? book,
    GenreModel? genre,
  }) {
    return BookGenreModel(
      bookId: bookId ?? this.bookId,
      genreId: genreId ?? this.genreId,
      id: id ?? this.id,
      book: book ?? this.book,
      genre: genre ?? this.genre,
    );
  }

  @override
  String toString() {
    return 'BookGenreModel(bookId: $bookId, genreId: $genreId, id: $id, book: $book, genre: $genre)';
  }
}

/// Represents the `bookstore_books` table.
class BookstoreBookModel extends TetherModel<BookstoreBookModel> {
  final String? bookId;
  final String? bookstoreId;
  final int id;
  final BookModel? book;
  final BookstoreModel? bookstore;

  BookstoreBookModel({
    this.bookId,
    this.bookstoreId,
    required this.id,
    this.book,
    this.bookstore,
  }) : super({
         'book_id': bookId,
         'bookstore_id': bookstoreId,
         'id': id,
         'book': book,
         'bookstore': bookstore,
       });

  /// The primary key for this model instance.
  @override
  int get localId => id;

  /// Creates an instance from a JSON map (e.g., from Supabase).
  factory BookstoreBookModel.fromJson(Map<String, dynamic> json) {
    return BookstoreBookModel(
      bookId: json['book_id'] == null ? null : json['book_id'] as String,
      bookstoreId: json['bookstore_id'] == null ? null : json['bookstore_id'] as String,
      id: json['id']! as int,
      book: json['book'] == null ? null : BookModel.fromJson(json['book'] as Map<String, dynamic>),
      bookstore: json['bookstore'] == null ? null : BookstoreModel.fromJson(json['bookstore'] as Map<String, dynamic>),
    );
  }

  /// Creates an instance from a map (e.g., from SQLite row containing nested JSON in 'jsobjects' column).
  factory BookstoreBookModel.fromSqlite(Row row) {
    final String? jsonDataString = row['jsobjects'] as String?;
    if (jsonDataString == null) {
      // Or handle as an error, depending on expected data integrity. This might lead to issues if fields are required.
      // For example, you could throw an exception: 
      // throw ArgumentError('SQLite row is missing 'jsobjects' column for BookstoreBookModel deserialization.');
      // Alternatively, if a model can be validly empty or with all nulls (if fields allow):
      // return BookstoreBookModel(/* pass all nulls or default values if constructor allows */);
      // For now, we'll create an empty map, and let constructor validation handle missing required fields.
    }
    final Map<String, dynamic> json = jsonDataString == null ? <String, dynamic>{} : jsonDecode(jsonDataString) as Map<String, dynamic>;

    return BookstoreBookModel(
      bookId: json['book_id'] == null ? null : json['book_id'] as String,
      bookstoreId: json['bookstore_id'] == null ? null : json['bookstore_id'] as String,
      id: json['id']! as int,
      book: json['book'] == null ? null : BookModel.fromJson(json['book'] as Map<String, dynamic>),
      bookstore: json['bookstore'] == null ? null : BookstoreModel.fromJson(json['bookstore'] as Map<String, dynamic>),
    );
  }

  /// Converts the instance to a JSON map (for Supabase).
  @override
  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'bookstore_id': bookstoreId,
      'id': id,
      'book': book?.toJson(),
      'bookstore': bookstore?.toJson(),
    };
  }

  /// Converts the instance to a map suitable for SQLite insertion/update.
  @override
  Map<String, dynamic> toSqlite() {
    return {
      'book_id': bookId,
      'bookstore_id': bookstoreId,
      'id': id,
    };
  }

  /// Creates a copy of this instance with potentially modified fields.
  @override
  BookstoreBookModel copyWith({
    String? bookId,
    String? bookstoreId,
    int? id,
    BookModel? book,
    BookstoreModel? bookstore,
  }) {
    return BookstoreBookModel(
      bookId: bookId ?? this.bookId,
      bookstoreId: bookstoreId ?? this.bookstoreId,
      id: id ?? this.id,
      book: book ?? this.book,
      bookstore: bookstore ?? this.bookstore,
    );
  }

  @override
  String toString() {
    return 'BookstoreBookModel(bookId: $bookId, bookstoreId: $bookstoreId, id: $id, book: $book, bookstore: $bookstore)';
  }
}

