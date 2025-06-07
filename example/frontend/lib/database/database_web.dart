// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names, avoid_print

import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:path/path.dart' as p;

import './database_interface.dart';

// Import generated migration SQL strings
import 'sqlite_migrations/migration_v0000_core_features.dart' as mig_v0000_coreFeatures;
import 'sqlite_migrations/migration_v0000_core_feed.dart' as mig_v0000_coreFeed;
import 'sqlite_migrations/migration_v0001.dart' as mig_v0001;

/// Web SQLite implementation using sqlite_async for AppDatabase.
class WebSqliteDb implements AppDatabase {
  static const String _dbFileName = 'app_db.sqlite_web.sqlite'; // Filename for sqlite_async on web (uses VFS)
  SqliteDatabase? _db;

  @override
  dynamic get db {
    if (_db == null) throw StateError("Web sqlite_async database not initialized.");
    return _db!;
  }

  @override
  Future<void> initialize() async {
    if (_db != null) return; // Already initialized

    print("INFO: Initializing sqlite_async database for web...");
    // Ensure sqlite3.wasm is available in your web/ directory and loaded.
    // This setup is usually done in main.dart for web projects.

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
    // For web, sqlite_async uses a virtual file system (e.g., IndexedDB).
    // The path provided is typically used as a name/key for the database.
    _db = SqliteDatabase(path: _dbFileName);
    await migrations.migrate(_db!);
    print("INFO: Web sqlite_async database initialized: $_dbFileName");
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
    print("INFO: Web sqlite_async database closed.");
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (_db == null) throw StateError("Web sqlite_async database not initialized for rawQuery.");
    return _db!.getAll(sql, arguments ?? []);
  }

  @override
  Future<ResultSet> rawExecute(String sql, [List<Object?>? arguments]) async {
    if (_db == null) throw StateError("Web sqlite_async database not initialized for rawExecute.");
    return _db!.execute(sql, arguments ?? []);
  }

  @override
  Future<T> transaction<T>(Future<T> Function(dynamic tx) action) async {
    if (_db == null) throw StateError("Web sqlite_async database not initialized for transaction.");
    // Cast tx to SqliteWriteContext for sqlite_async specific operations if needed inside action
    return _db!.writeTransaction(action as Future<T> Function(SqliteWriteContext tx));
  }
}

/// Factory function to get the web database implementation using sqlite_async.
AppDatabase getDatabase() => WebSqliteDb();
