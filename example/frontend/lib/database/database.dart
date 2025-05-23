// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names, avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';

import './database_interface.dart';
import './database_native.dart' if (dart.library.html) './database_web.dart' as platform_db;

/// Riverpod provider for accessing the application's database.
/// Returns an instance of [AppDatabase], implemented differently for native and web.
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final dbInstance = platform_db.getDatabase(); // Resolved by conditional import
  await dbInstance.initialize();

  ref.onDispose(() async { // Ensure database is closed when provider is disposed
    print("INFO: Disposing databaseProvider, closing database connection...");
    await dbInstance.close();
  });

  return dbInstance;
});

// Optional: Helper to access the specific underlying database objects.
/*
// For native, if you need the raw sqlite_async.SqliteDatabase:
// final nativeSqliteDatabaseProvider = Provider<sqlite_async.SqliteDatabase?>((ref) {
//   final appDbAsyncValue = ref.watch(databaseProvider);
//   final appDb = appDbAsyncValue.asData?.value;
//   if (appDb != null && appDb.db is sqlite_async.SqliteDatabase) {
//     return appDb.db as sqlite_async.SqliteDatabase;
//   }
//   return null;
// });
// For web, if you need the raw sqflite_common Database:
// final webSqfliteDatabaseProvider = Provider<Database?>((ref) { // From sqflite_common.sqlite_api
//   final appDbAsyncValue = ref.watch(databaseProvider);
//   final appDb = appDbAsyncValue.asData?.value;
//   if (appDb != null && appDb.db is Database) {
//     return appDb.db as Database;
//   }
//   return null;
// });
*/
