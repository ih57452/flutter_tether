// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/client_manager/client_manager.dart';
import '../models.g.dart'; // Assumes models.dart is in outputDirectory
import '../database.dart'; // Assumes database.dart is in outputDirectory
import '../supabase_schema.dart'; // Corrected relative import for schema file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';

class ImagesManager extends ClientManager<ImageModel> {
  ImagesManager({
    required super.localDb,
    required super.client,
    required super.tableSchemas,
    required super.fromJsonFactory,
    required super.fromSqliteFactory,
  }) : super(
          tableName: 'images',
          localTableName: 'images_local',
        );
}

final imagesManagerProvider = Provider<ImagesManager>((ref) {
  final database = ref.watch(databaseProvider).requireValue;

  return ImagesManager(
    localDb: database.db,
    client: Supabase.instance.client,
    tableSchemas: globalSupabaseSchema,
    fromJsonFactory: (json) => ImageModel.fromJson(json),
    fromSqliteFactory: (json) => ImageModel.fromSqlite(json),
  );
});

final imagesFeedProvider = StreamNotifierProvider.autoDispose.family<
  FeedStreamNotifier<ImageModel>, // NotifierT: Your notifier class
  List<ImageModel>, // StateT: The type of data the stream emits
  FeedStreamNotifierSettings<
    ImageModel
  > // ArgT: The type of the settings argument
>(() {
  // Instantiate the notifier and return it
  return FeedStreamNotifier<ImageModel>();
});

