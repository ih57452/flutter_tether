// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names, avoid_print

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import './database_interface.dart';

// Import generated migration SQL strings
import 'sqlite_migrations/migration_v0000_core_features.dart' as mig_v0000_coreFeatures;
import 'sqlite_migrations/migration_v0000_core_feed.dart' as mig_v0000_coreFeed;
import 'sqlite_migrations/migration_v0001.dart' as mig_v0001;

/// Native SQLite implementation using sqlite_async for AppDatabase.
class NativeSqliteDb implements AppDatabase {
  static const String _dbFileName = 'app_db.sqlite';
  SqliteDatabase? _db;

  @override
  dynamic get db {
    if (_db == null) throw StateError("Native database not initialized.");
    return _db!;
  }

  @override
  Future<void> initialize() async {
    if (_db != null) return; // Already initialized

    // --- Platform Specific Setup ---
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // --- Determine Database Path ---
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, _dbFileName);

    // --- Migration Setup ---
    final migrations = SqliteMigrations();
    migrations.add(SqliteMigration(1, (tx) async {
      for (final statement in mig_v0000_coreFeatures.migrationSqlStatementsV0000_core_features) {
        if (statement.trim().startsWith("--")) continue; // Skip comments
        await tx.execute(statement);
      }
    }));
    migrations.add(SqliteMigration(1, (tx) async {
      for (final statement in mig_v0000_coreFeed.migrationSqlStatementsV0000_core_feed) {
        if (statement.trim().startsWith("--")) continue; // Skip comments
        await tx.execute(statement);
      }
    }));
    migrations.add(SqliteMigration(2, (tx) async {
      for (final statement in mig_v0001.migrationSqlStatementsV1) {
        if (statement.trim().startsWith("--")) continue; // Skip comments
        await tx.execute(statement);
      }
    }));

    // --- Open Database ---
    final newDb = SqliteDatabase(path: dbPath, options: const SqliteOptions());
    await migrations.migrate(newDb);
    _db = newDb;
    print("INFO: Native database initialized at $dbPath");
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
    print("INFO: Native database closed.");
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (_db == null) throw StateError("Native database not initialized for rawQuery.");
    return _db!.getAll(sql, arguments ?? []);
  }

  @override
  Future<ResultSet> rawExecute(String sql, [List<Object?>? arguments]) async {
    if (_db == null) throw StateError("Native database not initialized for rawExecute.");
    return _db!.execute(sql, arguments ?? []);
  }

  @override
  Future<T> transaction<T>(Future<T> Function(dynamic tx) action) async {
    if (_db == null) throw StateError("Native database not initialized for transaction.");
    // Cast tx to SqliteWriteContext for sqlite_async specific operations if needed inside action
    return _db!.writeTransaction(action as Future<T> Function(SqliteWriteContext tx));
  }
}

/// Factory function to get the native database implementation.
AppDatabase getDatabase() => NativeSqliteDb();
