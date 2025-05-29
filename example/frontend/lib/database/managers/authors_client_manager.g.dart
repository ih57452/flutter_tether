// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/client_manager/client_manager.dart';
import '../models.g.dart'; // Assumes models.dart is in outputDirectory
import '../database.dart'; // Assumes database.dart is in outputDirectory
import '../supabase_schema.dart'; // Corrected relative import for schema file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';

class AuthorsManager extends ClientManager<AuthorModel> {
  AuthorsManager({
    required super.localDb,
    required super.client,
    required super.tableSchemas,
    required super.fromJsonFactory,
    required super.fromSqliteFactory,
  }) : super(
          tableName: 'authors',
          localTableName: 'authors',
        );
}

final authorsManagerProvider = Provider<AuthorsManager>((ref) {
  final database = ref.watch(databaseProvider).requireValue;

  return AuthorsManager(
    localDb: database.db,
    client: Supabase.instance.client,
    tableSchemas: globalSupabaseSchema,
    fromJsonFactory: (json) => AuthorModel.fromJson(json),
    fromSqliteFactory: (json) => AuthorModel.fromSqlite(json),
  );
});

final authorsFeedProvider = StreamNotifierProvider.autoDispose.family<
  FeedStreamNotifier<AuthorModel>, // NotifierT: Your notifier class
  List<AuthorModel>, // StateT: The type of data the stream emits
  FeedStreamNotifierSettings<
    AuthorModel
  > // ArgT: The type of the settings argument
>(() {
  // Instantiate the notifier and return it
  return FeedStreamNotifier<AuthorModel>();
});

