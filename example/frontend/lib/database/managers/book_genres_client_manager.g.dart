// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/client_manager/client_manager.dart';
import '../models.g.dart'; // Assumes models.dart is in outputDirectory
import '../database.dart'; // Assumes database.dart is in outputDirectory
import '../supabase_schema.dart'; // Corrected relative import for schema file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';

class BookGenresManager extends ClientManager<BookGenreModel> {
  BookGenresManager({
    required super.localDb,
    required super.client,
    required super.tableSchemas,
    required super.fromJsonFactory,
    required super.fromSqliteFactory,
  }) : super(
          tableName: 'book_genres',
          localTableName: 'book_genres',
        );
}

final bookGenresManagerProvider = Provider<BookGenresManager>((ref) {
  final database = ref.watch(databaseProvider).requireValue;

  return BookGenresManager(
    localDb: database.db,
    client: Supabase.instance.client,
    tableSchemas: globalSupabaseSchema,
    fromJsonFactory: (json) => BookGenreModel.fromJson(json),
    fromSqliteFactory: (json) => BookGenreModel.fromSqlite(json),
  );
});

final bookGenresFeedProvider = StreamNotifierProvider.autoDispose.family<
  FeedStreamNotifier<BookGenreModel>, // NotifierT: Your notifier class
  List<BookGenreModel>, // StateT: The type of data the stream emits
  FeedStreamNotifierSettings<
    BookGenreModel
  > // ArgT: The type of the settings argument
>(() {
  // Instantiate the notifier and return it
  return FeedStreamNotifier<BookGenreModel>();
});

