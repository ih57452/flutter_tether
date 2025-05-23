import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:clock/clock.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SqliteAsyncStorage implements Storage<String, String> {
  final SqliteDatabase _db;
  static const String _tableName = 'riverpod';

  SqliteAsyncStorage._(this._db);

  /// Opens the SQLite database and initializes the storage table.
  static Future<SqliteAsyncStorage> open(String path) async {
    final db = SqliteDatabase(path: path);

    // Create the table if it doesn't exist
    await db.execute('''
CREATE TABLE IF NOT EXISTS $_tableName(
  key TEXT PRIMARY KEY NOT NULL,
  json TEXT,
  expireAt INTEGER,
  destroyKey TEXT
) WITHOUT ROWID
''');

    // Clean up expired entries
    await db.execute(
      '''
DELETE FROM $_tableName WHERE expireAt IS NOT NULL AND expireAt < ?
''',
      [clock.now().toUtc().millisecondsSinceEpoch],
    );

    return SqliteAsyncStorage._(db);
  }

  /// Closes the database.
  Future<void> close() async {
    await _db.close();
  }

  @override
  Future<void> delete(String key) async {
    await _db.execute('DELETE FROM $_tableName WHERE key = ?', [key]);
  }

  @override
  Future<PersistedData<String>?> read(String key) async {
    final result = await _db.get(
      'SELECT * FROM $_tableName WHERE key = ? LIMIT 1',
      [key],
    );

    if (result.isEmpty) return null;

    final row = result;
    return PersistedData(
      row['json'] as String,
      expireAt:
          row['expireAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(row['expireAt'] as int)
              : null,
      destroyKey: row['destroyKey'] as String?,
    );
  }

  @override
  Future<void> write(String key, String value, StorageOptions options) async {
    final expireAt =
        options.cacheTime.duration != null
            ? clock.now().toUtc().millisecondsSinceEpoch +
                options.cacheTime.duration!.inMilliseconds
            : null;

    await _db.execute(
      '''
INSERT OR REPLACE INTO $_tableName (key, json, expireAt, destroyKey)
VALUES (?, ?, ?, ?)
''',
      [key, value, expireAt, options.destroyKey],
    );
  }
}

final storageProvider = FutureProvider<SqliteAsyncStorage>((ref) async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(documentsDir.path, 'riverpod_storage.db');
  return SqliteAsyncStorage.open(dbPath);
});
