// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/client_manager/client_manager.dart';
import '../models.g.dart'; // Assumes models.dart is in outputDirectory
import '../database.dart'; // Assumes database.dart is in outputDirectory
import '../supabase_schema.dart'; // Corrected relative import for schema file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';

class BookstoreBooksManager extends ClientManager<BookstoreBookModel> {
  BookstoreBooksManager({
    required super.localDb,
    required super.client,
    required super.tableSchemas,
    required super.fromJsonFactory,
    required super.fromSqliteFactory,
  }) : super(
          tableName: 'bookstore_books',
          localTableName: 'bookstore_books_local',
        );
}

final bookstoreBooksManagerProvider = Provider<BookstoreBooksManager>((ref) {
  final database = ref.watch(databaseProvider).requireValue;

  return BookstoreBooksManager(
    localDb: database.db,
    client: Supabase.instance.client,
    tableSchemas: globalSupabaseSchema,
    fromJsonFactory: (json) => BookstoreBookModel.fromJson(json),
    fromSqliteFactory: (json) => BookstoreBookModel.fromSqlite(json),
  );
});

final bookstoreBooksFeedProvider = StreamNotifierProvider.autoDispose.family<
  FeedStreamNotifier<BookstoreBookModel>, // NotifierT: Your notifier class
  List<BookstoreBookModel>, // StateT: The type of data the stream emits
  FeedStreamNotifierSettings<
    BookstoreBookModel
  > // ArgT: The type of the settings argument
>(() {
  // Instantiate the notifier and return it
  return FeedStreamNotifier<BookstoreBookModel>();
});

