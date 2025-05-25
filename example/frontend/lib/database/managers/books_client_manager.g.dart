// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/client_manager/client_manager.dart';
import '../models.g.dart'; // Assumes models.dart is in outputDirectory
import '../database.dart'; // Assumes database.dart is in outputDirectory
import '../supabase_schema.dart'; // Corrected relative import for schema file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';

class BooksManager extends ClientManager<BookModel> {
  BooksManager({
    required super.localDb,
    required super.client,
    required super.tableSchemas,
    required super.fromJsonFactory,
    required super.fromSqliteFactory,
  }) : super(
          tableName: 'books',
          localTableName: 'books_local',
        );
}

final booksManagerProvider = Provider<BooksManager>((ref) {
  final database = ref.watch(databaseProvider).requireValue;

  return BooksManager(
    localDb: database.db,
    client: Supabase.instance.client,
    tableSchemas: globalSupabaseSchema,
    fromJsonFactory: (json) => BookModel.fromJson(json),
    fromSqliteFactory: (json) => BookModel.fromSqlite(json),
  );
});

final booksFeedProvider = StreamNotifierProvider.autoDispose.family<
  FeedStreamNotifier<BookModel>, // NotifierT: Your notifier class
  List<BookModel>, // StateT: The type of data the stream emits
  FeedStreamNotifierSettings<
    BookModel
  > // ArgT: The type of the settings argument
>(() {
  // Instantiate the notifier and return it
  return FeedStreamNotifier<BookModel>();
});

