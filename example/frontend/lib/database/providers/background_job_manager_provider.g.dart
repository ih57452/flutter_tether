// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, unnecessary_import, lines_longer_than_80_chars

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_async/sqlite_async.dart'; // For SqliteConnection type
import 'package:tether_libs/background_service/background_service_manager.dart';
import '../database.dart'; // Provides 'databaseProvider'

/// Riverpod provider for accessing the [BackgroundJobManager].
///
/// This manager is used to interact with the `background_service_jobs` table
/// from the main UI isolate (e.g., for enqueuing jobs or querying their status).
///
/// It requires an active [SqliteConnection] for the UI isolate, which is
/// obtained from the `databaseProvider`.
final backgroundJobManagerProvider = Provider<BackgroundJobManager>((ref) {
  // Assuming 'databaseProvider' is a FutureProvider<YourAppDbClass>
  // and YourAppDbClass has a 'db' getter of type SqliteConnection.
  final appDatabase = ref.watch(databaseProvider).requireValue;
  final dbConnection = appDatabase.db;
  return BackgroundJobManager(db: dbConnection);
});

