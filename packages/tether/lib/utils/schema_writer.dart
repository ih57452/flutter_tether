import 'dart:io';

import 'package:flutter_tether/config/config_model.dart';
import 'package:tether_libs/models/table_info.dart';
import 'package:tether_libs/utils/logger.dart';

class SchemaWriter {
  final SupabaseGenConfig config;
  final Logger _logger;
  final List<SupabaseTableInfo>
  tables; // This should be populated with actual table info

  SchemaWriter(this.config, this.tables) : _logger = Logger('SchemaWriter');

  /// Generates the content for the supabase_schema.dart file containing the globalSupabaseSchema variable.
  String _generateSchemaDartFileContent() {
    final buffer = StringBuffer();

    // File header and imports
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: constant_identifier_names');
    buffer.writeln();
    buffer.writeln("import 'package:tether_libs/models/table_info.dart';");
    buffer.writeln();

    // Generate the globalSupabaseSchema List
    buffer.writeln('/// Global schema information for all Supabase tables.');
    buffer.writeln(
      '/// This list contains detailed metadata about each table including',
    );
    buffer.writeln('/// columns, foreign keys, indexes, and relationships.');
    buffer.writeln('final List<SupabaseTableInfo> globalSupabaseSchema = [');

    // Generate entries for each table
    for (final table in tables) {
      buffer.writeln('  SupabaseTableInfo(');
      buffer.writeln('    name: \'${table.name}\',');
      buffer.writeln('    originalName: \'${table.originalName}\',');
      buffer.writeln('    localName: \'${table.localName}\',');
      buffer.writeln('    schema: \'${table.schema}\',');

      // Generate columns list
      buffer.writeln('    columns: [');
      for (final column in table.columns) {
        buffer.writeln('      TetherColumnInfo(');
        buffer.writeln('        name: \'${column.name}\',');
        buffer.writeln('        originalName: \'${column.originalName}\',');
        buffer.writeln('        localName: \'${column.localName}\',');
        buffer.writeln('        type: \'${column.type}\',');
        buffer.writeln('        isNullable: ${column.isNullable},');
        buffer.writeln('        isPrimaryKey: ${column.isPrimaryKey},');
        buffer.writeln('        isUnique: ${column.isUnique},');
        if (column.defaultValue != null) {
          buffer.writeln(
            '        defaultValue: \'${_escapeSingleQuotes(column.defaultValue!)}\',',
          );
        }
        if (column.comment != null) {
          buffer.writeln(
            '        comment: \'${_escapeSingleQuotes(column.comment!)}\',',
          );
        }
        buffer.writeln('        isIdentity: ${column.isIdentity},');
        buffer.writeln('      ),');
      }
      buffer.writeln('    ],');

      // Generate foreign keys list
      buffer.writeln('    foreignKeys: [');
      for (final fk in table.foreignKeys) {
        buffer.writeln('      SupabaseForeignKeyConstraint(');
        buffer.writeln('        constraintName: \'${fk.constraintName}\',');
        buffer.writeln(
          '        columns: [${fk.columns.map((c) => '\'$c\'').join(', ')}],',
        );
        buffer.writeln(
          '        originalColumns: [${fk.originalColumns.map((c) => '\'$c\'').join(', ')}],',
        );
        buffer.writeln(
          '        localColumns: [${fk.localColumns.map((c) => '\'$c\'').join(', ')}],',
        );
        buffer.writeln(
          '        foreignTableSchema: \'${fk.foreignTableSchema}\',',
        );
        buffer.writeln('        foreignTableName: \'${fk.foreignTableName}\',');
        buffer.writeln(
          '        originalForeignTableName: \'${fk.originalForeignTableName}\',',
        );
        buffer.writeln(
          '        localForeignTableName: \'${fk.localForeignTableName}\',',
        );
        buffer.writeln(
          '        foreignColumns: [${fk.foreignColumns.map((c) => '\'$c\'').join(', ')}],',
        );
        buffer.writeln(
          '        originalForeignColumns: [${fk.originalForeignColumns.map((c) => '\'$c\'').join(', ')}],',
        );
        buffer.writeln(
          '        localForeignColumns: [${fk.localForeignColumns.map((c) => '\'$c\'').join(', ')}],',
        );
        buffer.writeln('        updateRule: \'${fk.updateRule}\',');
        buffer.writeln('        deleteRule: \'${fk.deleteRule}\',');
        buffer.writeln('        matchOption: \'${fk.matchOption}\',');
        buffer.writeln('        isDeferrable: ${fk.isDeferrable},');
        buffer.writeln('        initiallyDeferred: ${fk.initiallyDeferred},');
        if (fk.joinTableName != null) {
          buffer.writeln('        joinTableName: \'${fk.joinTableName}\',');
        }
        buffer.writeln('      ),');
      }
      buffer.writeln('    ],');

      // Generate indexes list
      buffer.writeln('    indexes: [');
      for (final index in table.indexes) {
        buffer.writeln('      SupabaseIndexInfo(');
        buffer.writeln('        name: \'${index.name}\',');
        buffer.writeln('        originalName: \'${index.originalName}\',');
        buffer.writeln('        localName: \'${index.localName}\',');
        buffer.writeln('        isUnique: ${index.isUnique},');
        buffer.writeln(
          '        columns: [${index.columns.map((c) => '\'$c\'').join(', ')}],',
        );
        buffer.writeln(
          '        originalColumns: [${index.originalColumns.map((c) => '\'$c\'').join(', ')}],',
        );
        buffer.writeln('      ),');
      }
      buffer.writeln('    ],');

      // Generate comment
      if (table.comment != null) {
        buffer.writeln(
          '    comment: \'${_escapeSingleQuotes(table.comment!)}\',',
        );
      }

      // Generate reverse relations list
      buffer.writeln('    reverseRelations: [');
      for (final rel in table.reverseRelations) {
        buffer.writeln('      ModelReverseRelationInfo(');
        buffer.writeln(
          '        fieldNameInThisModel: \'${rel.fieldNameInThisModel}\',',
        );
        buffer.writeln(
          '        referencingTableOriginalName: \'${rel.referencingTableOriginalName}\',',
        );
        buffer.writeln(
          '        foreignKeyColumnInReferencingTable: \'${rel.foreignKeyColumnInReferencingTable}\',',
        );
        buffer.writeln('      ),');
      }
      buffer.writeln('    ],');

      buffer.writeln('  ),');
    }

    buffer.writeln('];');
    buffer.writeln();

    return buffer.toString();
  }

  /// Helper method to escape single quotes in strings for code generation.
  String _escapeSingleQuotes(String input) {
    return input.replaceAll('\'', '\\\'');
  }

  /// Writes the schema Dart file containing the globalSupabaseSchema variable.
  Future<void> writeGlobalSchemaFile() async {
    final schemaContent = _generateSchemaDartFileContent();
    final filePath = '${config.generatedSupabaseSchemaDartFilePath}';

    try {
      await _writeFile(filePath, schemaContent);
      _logger.info('Successfully generated global schema file: $filePath');
    } catch (e) {
      _logger.severe('Failed to write global schema file: $e');
      rethrow;
    }
  }

  Future<void> _writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      await file.writeAsString(content);
    } catch (e, s) {
      _logger.severe('Failed to write file to $filePath: $e, $s');
      throw Exception('Failed to write file $filePath: $e');
    }
  }
}
