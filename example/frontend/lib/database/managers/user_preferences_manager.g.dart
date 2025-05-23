// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart'; // Assuming database.dart is at the root of outputDirectory

/// Defines the valid string constants for user preference types stored in the database.
class UserPreferenceValueTypes {
  static const String text = 'TEXT';
  static const String integer = 'INTEGER';
  static const String real = 'REAL';
  static const String boolean = 'BOOLEAN';
  static const String textArray = 'TEXT_ARRAY';
  static const String jsonObject = 'JSON_OBJECT';
  static const String jsonArray = 'JSON_ARRAY';

  /// A list of all valid preference type strings.
  static List<String> get all => [
    text,
    integer,
    real,
    boolean,
    textArray,
    jsonObject,
    jsonArray,
  ];
}

/// Manages storing, retrieving, and streaming user preferences from the SQLite database.
class UserPreferencesManager {
  final SqliteDatabase db;
  static const String _tableName = 'user_preferences';

  UserPreferencesManager(this.db);

  /// Sets or updates a user preference.
  /// [key]: The unique key for the preference.
  /// [value]: The value to store. It will be JSON encoded.
  /// [valueType]: The type of the value, must be one of [UserPreferenceValueTypes].
  Future<void> setPreference<T>(
    String key,
    T value, {
    required String valueType,
  }) async {
    assert(
      UserPreferenceValueTypes.all.contains(valueType),
      "Invalid valueType: $valueType. Must be one of UserPreferenceValueTypes.all",
    );
    final String jsonValue = jsonEncode(value);
    await db.execute(
      '''INSERT INTO $_tableName (preference_key, preference_value, value_type)
         VALUES (?, ?, ?)
         ON CONFLICT(preference_key) DO UPDATE SET
           preference_value = excluded.preference_value,
           value_type = excluded.value_type;''',
      [key, jsonValue, valueType],
    );
  }

  /// Retrieves a user preference and deserializes its JSON value.
  /// Returns `null` if the key is not found or if deserialization fails.
  /// [key]: The key of the preference to retrieve.
  /// [fromJson]: A function to convert the decoded JSON (dynamic) to type [T].
  Future<T?> getPreference<T>(
    String key, {
    required T Function(dynamic jsonData) fromJson,
  }) async {
    final row = await db.get(
      'SELECT preference_value FROM $_tableName WHERE preference_key = ?',
      [key],
    );
    final rawValue = row['preference_value'] as String?;
    if (rawValue == null) {
      // This case implies that null was explicitly stored and jsonEncode(null) resulted in "null" which was then stored.
      // Or, if preference_value can be truly NULL in DB for a key, this handles it.
      try {
        return fromJson(null);
      } catch (_) {
        return null;
      } // Allow fromJson to handle null if it wants
    }
    try {
      final jsonData = jsonDecode(rawValue);
      return fromJson(jsonData);
    } catch (e, s) {
      // Consider logging this error more formally if a logger is available here
      print('Error decoding preference for key "$key": $e$s');
      return null;
    }
  }

  /// Watches for changes to a specific user preference and streams its deserialized JSON value.
  /// Emits `null` if the key is not found, deleted, or if deserialization fails.
  /// [key]: The key of the preference to watch.
  /// [fromJson]: A function to convert the decoded JSON (dynamic) to type [T].
  Stream<T?> watchPreference<T>(
    String key, {
    required T Function(dynamic jsonData) fromJson,
  }) {
    return db
        .watch(
          'SELECT preference_value FROM $_tableName WHERE preference_key = ?',
          parameters: [key],
        )
        .map((result) {
          if (result.isEmpty) return null; // No rows found
          final row = result.first;
          final rawValue = row['preference_value'] as String?;
          if (rawValue == null) {
            try {
              return fromJson(null);
            } catch (_) {
              return null;
            }
          }
          try {
            final jsonData = jsonDecode(rawValue);
            return fromJson(jsonData);
          } catch (e, s) {
            print('Error decoding preference for key "$key" in stream: $e$s');
            return null;
          }
        });
  }

  /// Retrieves the raw preference data (key, JSON value, value_type) as a map.
  /// Returns `null` if the key is not found.
  Future<Map<String, dynamic>?> getRawPreference(String key) async {
    return db.get(
      'SELECT preference_key, preference_value, value_type FROM $_tableName WHERE preference_key = ?',
      [key],
    );
  }

  /// Watches for changes to a specific user preference and streams its raw data as a map.
  /// Emits `null` if the key is not found or deleted.
  Stream<Map<String, dynamic>?> watchRawPreference(String key) {
    return db
        .watch(
          'SELECT preference_key, preference_value, value_type FROM $_tableName WHERE preference_key = ?',
          parameters: [key],
        )
        .map((result) {
          if (result.isEmpty) return null; // No rows found
          final row = result.first;
          return {
            'preference_key': row['preference_key'],
            'preference_value': row['preference_value'],
            'value_type': row['value_type'],
          };
        });
  }

  /// Deletes a user preference by its key.
  Future<void> deletePreference(String key) async {
    await db.execute('DELETE FROM $_tableName WHERE preference_key = ?', [key]);
  }
}


/// Riverpod provider for [UserPreferencesManager].
final userPreferencesManagerProvider = Provider<UserPreferencesManager>((ref) {
  final database = ref.watch(databaseProvider).requireValue;
  return UserPreferencesManager(database.db);
});
