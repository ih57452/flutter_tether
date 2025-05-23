// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:sqlite_async/sqlite3_common.dart';
/// Abstract interface for database operations, allowing for different
/// implementations on native and web platforms.
abstract class AppDatabase {
  /// Initializes the database.
  Future<void> initialize();

  /// Closes the database connection.
  Future<void> close();

  /// Provides access to the underlying database object.
  /// The type of this object will vary depending on the platform implementation.
  dynamic get db;

  // Common database methods
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]);
  Future<ResultSet> rawExecute(String sql, [List<Object?>? arguments]);
  Future<T> transaction<T>(Future<T> Function(dynamic tx) action); // tx type is dynamic due to platform differences
}
