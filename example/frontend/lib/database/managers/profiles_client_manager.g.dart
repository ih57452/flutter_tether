// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/client_manager/client_manager.dart';
import '../models.g.dart'; // Assumes models.dart is in outputDirectory
import '../database.dart'; // Assumes database.dart is in outputDirectory
import '../supabase_schema.dart'; // Corrected relative import for schema file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';

class ProfilesManager extends ClientManager<ProfileModel> {
  ProfilesManager({
    required super.localDb,
    required super.client,
    required super.tableSchemas,
    required super.fromJsonFactory,
    required super.fromSqliteFactory,
  }) : super(
          tableName: 'profiles',
          localTableName: 'profiles',
        );
}

final profilesManagerProvider = Provider<ProfilesManager>((ref) {
  final database = ref.watch(databaseProvider).requireValue;

  return ProfilesManager(
    localDb: database.db,
    client: Supabase.instance.client,
    tableSchemas: globalSupabaseSchema,
    fromJsonFactory: (json) => ProfileModel.fromJson(json),
    fromSqliteFactory: (json) => ProfileModel.fromSqlite(json),
  );
});

final profilesFeedProvider = StreamNotifierProvider.autoDispose.family<
  FeedStreamNotifier<ProfileModel>, // NotifierT: Your notifier class
  List<ProfileModel>, // StateT: The type of data the stream emits
  FeedStreamNotifierSettings<
    ProfileModel
  > // ArgT: The type of the settings argument
>(() {
  // Instantiate the notifier and return it
  return FeedStreamNotifier<ProfileModel>();
});

