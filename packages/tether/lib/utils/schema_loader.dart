import 'dart:convert';
import 'dart:io';

import 'package:tether_libs/models/table_info.dart';

Map<String, SupabaseTableInfo> loadTableSchemasSync(String schemaDirectory) {
  final schemaFiles = Directory(
    schemaDirectory,
  ).listSync().where((file) => file.path.endsWith('.json'));
  final Map<String, SupabaseTableInfo> tableMap = {};

  for (final file in schemaFiles) {
    final content = File(file.path).readAsStringSync(); // Synchronous file read
    final List<dynamic> tablesJson = jsonDecode(content);

    for (final tableJson in tablesJson) {
      final tableInfo = SupabaseTableInfo.fromJson(
        tableJson as Map<String, dynamic>,
      );
      tableMap[tableInfo.uniqueKey] =
          tableInfo; // Use `schema.tableName` as the key
    }
  }

  return tableMap;
}
