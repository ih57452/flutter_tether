// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/client_manager/client_manager.dart';
import '../models.g.dart'; // Assumes models.dart is in outputDirectory
import '../database.dart'; // Assumes database.dart is in outputDirectory
import '../supabase_schema.dart'; // Corrected relative import for schema file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';

class GenresManager extends ClientManager<GenreModel> {
  GenresManager({
    required super.localDb,
    required super.client,
    required super.tableSchemas,
    required super.fromJsonFactory,
    required super.fromSqliteFactory,
  }) : super(
          tableName: 'genres',
          localTableName: 'genres',
        );
}

final genresManagerProvider = Provider<GenresManager>((ref) {
  final database = ref.watch(databaseProvider).requireValue;

  return GenresManager(
    localDb: database.db,
    client: Supabase.instance.client,
    tableSchemas: globalSupabaseSchema,
    fromJsonFactory: (json) => GenreModel.fromJson(json),
    fromSqliteFactory: (json) => GenreModel.fromSqlite(json),
  );
});

final genresFeedProvider = StreamNotifierProvider.autoDispose.family<
  FeedStreamNotifier<GenreModel>, // NotifierT: Your notifier class
  List<GenreModel>, // StateT: The type of data the stream emits
  FeedStreamNotifierSettings<
    GenreModel
  > // ArgT: The type of the settings argument
>(() {
  // Instantiate the notifier and return it
  return FeedStreamNotifier<GenreModel>();
});

