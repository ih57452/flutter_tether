// Generated by tether. Do not modify manually.
// Generator for Supabase/SQLite select query strings with type-safe builders.

import 'dart:io';
import 'package:inflection3/inflection3.dart';
import 'package:path/path.dart' as p; // For path joining
import 'package:recase/recase.dart';
import 'package:flutter_tether/config/config_model.dart';

// Import config and schema classes
import 'package:tether_libs/models/table_info.dart';
import 'package:tether_libs/utils/string_utils.dart';
import 'package:tether_libs/utils/logger.dart';

class SupabaseSelectBuilderGenerator {
  final SupabaseGenConfig config;
  final Logger _logger;
  final List<SupabaseTableInfo> _allTables;
  final Map<String, SupabaseTableInfo> _tableMap = {};
  final Map<String, List<_ReverseFKInfo>> _reverseForeignKeyMap = {};

  SupabaseSelectBuilderGenerator({
    required this.config,
    required List<SupabaseTableInfo> allTables,
    Logger? logger,
  }) : _allTables = allTables,
       _logger = logger ?? Logger('SupabaseSelectBuilderGenerator') {
    for (final table in _allTables) {
      _tableMap[table.uniqueKey] = table;
    }
    _buildReverseForeignKeyMap();
  }

  void _buildReverseForeignKeyMap() {
    for (final referencingTable in _allTables) {
      for (final fk in referencingTable.foreignKeys) {
        final targetTableKey =
            '${fk.foreignTableSchema}.${fk.originalForeignTableName}';
        (_reverseForeignKeyMap[targetTableKey] ??= []).add(
          _ReverseFKInfo(referencingTable, fk),
        );
      }
    }
  }

  Future<void> generate() async {
    if (!config.generateSupabaseSelectBuilders) {
      _logger.info('Supabase select builder generation is disabled. Skipping.');
      return;
    }
    if (_allTables.isEmpty) {
      _logger.warning(
        'No table information provided. Skipping select builder generation.',
      );
      return;
    }

    _logger.info('Starting Supabase select builder class generation...');

    // Generate and write the schema Dart file
    final schemaDartFileContent = _generateSchemaDartFileContent();
    final schemaDartFilePath = '${config.generatedSupabaseSchemaDartFilePath}';
    _logger.info('Writing Supabase schema Dart file to $schemaDartFilePath');
    try {
      await _writeFile(schemaDartFilePath, schemaDartFileContent);
      _logger.info(
        'Successfully generated Supabase schema Dart file: $schemaDartFilePath',
      );
    } catch (e, s) {
      _logger.severe(
        'Failed to write Supabase schema Dart file to $schemaDartFilePath: $e, $s',
      );
      // Optionally rethrow or handle if this is critical
    }

    // Generate and write the select builders file
    final builderFileContent = _generateBuilderFileContent();
    final builderFilePath = config.supabaseSelectBuildersFilePath;

    try {
      await _writeFile(builderFilePath, builderFileContent);
      _logger.info(
        'Successfully generated Supabase select builders file: $builderFilePath',
      );
    } catch (e, s) {
      _logger.severe(
        'Failed to write Supabase select builders file to $builderFilePath: $e, $s',
      );
    }
  }

  String _generateSchemaDartFileContent() {
    final sb = StringBuffer();
    sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    sb.writeln('// Contains the static schema definition for Supabase tables.');
    sb.writeln();
    sb.writeln("import 'package:tether_libs/models/table_info.dart';");
    sb.writeln();
    sb.writeln(
      '// ignore_for_file: prefer_single_quotes, unnecessary_brace_in_string_interps, unnecessary_string_interpolations',
    );
    sb.writeln();
    sb.writeln('final Map<String, SupabaseTableInfo> globalSupabaseSchema = {');

    for (final table in _allTables) {
      sb.writeln(
        "  '${table.schema}.${table.originalName}': SupabaseTableInfo(",
      );
      sb.writeln("    name: ${_escapeStringForDart(table.name)},");
      sb.writeln(
        "    originalName: ${_escapeStringForDart(table.originalName)},",
      );
      sb.writeln("    localName: ${_escapeStringForDart(table.localName)},");
      sb.writeln("    schema: ${_escapeStringForDart(table.schema)},");
      sb.writeln("    columns: [");
      for (final col in table.columns) {
        sb.writeln("      TetherColumnInfo(");
        sb.writeln("        name: ${_escapeStringForDart(col.name)},");
        sb.writeln(
          "        originalName: ${_escapeStringForDart(col.originalName)},",
        );
        sb.writeln(
          "        localName: ${_escapeStringForDart(col.localName)},",
        );
        sb.writeln("        type: ${_escapeStringForDart(col.type)},");
        sb.writeln("        isNullable: ${col.isNullable},");
        sb.writeln("        isPrimaryKey: ${col.isPrimaryKey},");
        sb.writeln("        isUnique: ${col.isUnique},");
        sb.writeln(
          "        defaultValue: ${_escapeStringForDart(col.defaultValue)},",
        );
        sb.writeln("        comment: ${_escapeStringForDart(col.comment)},");
        sb.writeln("      ),");
      }
      sb.writeln("    ],");
      sb.writeln("    foreignKeys: [");
      for (final fk in table.foreignKeys) {
        sb.writeln("      SupabaseForeignKeyConstraint(");
        sb.writeln(
          "        constraintName: ${_escapeStringForDart(fk.constraintName)},",
        );
        sb.writeln(
          "        columns: [${fk.columns.map((c) => _escapeStringForDart(c)).join(', ')}],",
        );
        sb.writeln(
          "        originalColumns: [${fk.originalColumns.map((c) => _escapeStringForDart(c)).join(', ')}],",
        );
        sb.writeln(
          "        localColumns: [${fk.localColumns.map((c) => _escapeStringForDart(c)).join(', ')}],",
        );
        sb.writeln(
          "        foreignTableSchema: ${_escapeStringForDart(fk.foreignTableSchema)},",
        );
        sb.writeln(
          "        foreignTableName: ${_escapeStringForDart(fk.foreignTableName)},",
        );
        sb.writeln(
          "        originalForeignTableName: ${_escapeStringForDart(fk.originalForeignTableName)},",
        );
        sb.writeln(
          "        localForeignTableName: ${_escapeStringForDart(fk.localForeignTableName)},",
        );
        sb.writeln(
          "        foreignColumns: [${fk.foreignColumns.map((c) => _escapeStringForDart(c)).join(', ')}],",
        );
        sb.writeln(
          "        originalForeignColumns: [${fk.originalForeignColumns.map((c) => _escapeStringForDart(c)).join(', ')}],",
        );
        sb.writeln(
          "        localForeignColumns: [${fk.localForeignColumns.map((c) => _escapeStringForDart(c)).join(', ')}],",
        );
        sb.writeln(
          "        updateRule: ${_escapeStringForDart(fk.updateRule)},",
        );
        sb.writeln(
          "        deleteRule: ${_escapeStringForDart(fk.deleteRule)},",
        );
        sb.writeln(
          "        matchOption: ${_escapeStringForDart(fk.matchOption)},",
        );
        sb.writeln("        isDeferrable: ${fk.isDeferrable},");
        sb.writeln("        initiallyDeferred: ${fk.initiallyDeferred},");
        sb.writeln(
          "        joinTableName: ${_escapeStringForDart(fk.joinTableName)},",
        );
        sb.writeln("      ),");
      }
      sb.writeln("    ],");
      sb.writeln("    indexes: [");
      for (final idx in table.indexes) {
        sb.writeln("      SupabaseIndexInfo(");
        sb.writeln("        name: ${_escapeStringForDart(idx.name)},");
        sb.writeln(
          "        originalName: ${_escapeStringForDart(idx.originalName)},",
        );
        sb.writeln(
          "        localName: ${_escapeStringForDart(idx.localName)},",
        );
        sb.writeln("        isUnique: ${idx.isUnique},");
        sb.writeln(
          "        columns: [${idx.columns.map((c) => _escapeStringForDart(c)).join(', ')}],",
        );
        sb.writeln(
          "        originalColumns: [${idx.originalColumns.map((c) => _escapeStringForDart(c)).join(', ')}],",
        );
        sb.writeln("      ),");
      }
      sb.writeln("    ],");
      // --- ADDED SECTION FOR REVERSE RELATIONS ---
      sb.writeln("    reverseRelations: [");
      for (final rr in table.reverseRelations) {
        sb.writeln("      ModelReverseRelationInfo(");
        sb.writeln(
          "        fieldNameInThisModel: ${_escapeStringForDart(rr.fieldNameInThisModel)},",
        );
        sb.writeln(
          "        referencingTableOriginalName: ${_escapeStringForDart(rr.referencingTableOriginalName)},",
        );
        sb.writeln(
          "        foreignKeyColumnInReferencingTable: ${_escapeStringForDart(rr.foreignKeyColumnInReferencingTable)},",
        );
        sb.writeln("      ),");
      }
      sb.writeln("    ],");
      // --- END OF ADDED SECTION ---
      sb.writeln("    comment: ${_escapeStringForDart(table.comment)},");
      sb.writeln("  ),");
    }
    sb.writeln('};');
    return sb.toString();
  }

  String _generateBuilderFileContent() {
    final sb = StringBuffer();

    // Use p.basename to get just the filename for the import.
    final schemaFileName = p.basename(
      config.generatedSupabaseSchemaDartFilePath,
    );

    final Set<String> imports = {
      "import 'package:tether_libs/models/supabase_select_builder_base.dart';",
      "import '$schemaFileName'; // Import the generated schema",
    };

    sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    sb.writeln(
      '// Generator for Supabase/SQLite select query strings with type-safe builders.',
    );
    sb.writeln();
    sb.writeln(
      '// ignore_for_file: type_init_formals',
    ); // To allow SupabaseTableInfo? currentTableInfo;
    sb.writeln();

    for (final import in imports) {
      sb.writeln(import);
    }
    sb.writeln();

    for (final table in _allTables) {
      sb.writeln(_generateTableColumnEnum(table));
      sb.writeln();
      sb.writeln(_generateConcreteBuilderClass(table));
      sb.writeln();
    }

    return sb.toString();
  }

  String _generateTableColumnEnum(SupabaseTableInfo table) {
    final sb = StringBuffer();
    final enumName = StringUtils.toClassName(table.name, suffix: 'Column');
    final tableName = table.originalName;

    sb.writeln('enum $enumName implements TetherColumn {');

    for (final column in table.columns) {
      final enumValueName = StringUtils.toCamelCase(column.localName);
      sb.writeln(
        "  $enumValueName('${column.originalName}', '${column.localName}', '$tableName', null),",
      );
    }

    sb.writeln(';');
    sb.writeln('  @override');
    sb.writeln('  final String originalName;');
    sb.writeln('  @override');
    sb.writeln('  final String localName;');
    sb.writeln('  @override');
    sb.writeln('  final String tableName;');
    sb.writeln('  @override');
    sb.writeln('  final String? relationshipPrefix;');
    sb.writeln();
    sb.writeln(
      '  const $enumName(this.originalName, this.localName, this.tableName, this.relationshipPrefix);',
    );
    sb.writeln();
    sb.writeln('  @override');
    sb.writeln('  String get dbName => originalName;');
    sb.writeln();
    sb.writeln('  @override');
    sb.writeln('  String get dartName => localName;');
    sb.writeln();
    sb.writeln('  @override');
    sb.writeln('  String get qualified => \'$tableName.\$originalName\';');
    sb.writeln();
    sb.writeln('  @override');
    sb.writeln(
      '  String get fullyQualified => relationshipPrefix != null ? \'\$relationshipPrefix.\$dbName\' : dbName;',
    );
    sb.writeln();
    sb.writeln('  @override');
    sb.writeln(
      '  TetherColumn related(String relationshipName) => RelatedColumnRef(originalName, localName, tableName, relationshipName);',
    );
    sb.writeln('}');
    return sb.toString();
  }

  String _generateConcreteBuilderClass(SupabaseTableInfo table) {
    final sb = StringBuffer();
    final className = StringUtils.toClassName(
      table.name,
      suffix: 'SelectBuilder',
    );
    final enumName = StringUtils.toClassName(table.name, suffix: 'Column');
    final tableUniqueKey =
        '${table.schema}.${table.originalName}'; // Use originalName for consistency

    sb.writeln('class $className extends SelectBuilderBase {');
    sb.writeln();
    // Constructor looks up its SupabaseTableInfo from globalSupabaseSchema
    // and passes it to the super constructor.
    sb.writeln(
      "  $className() : super(primaryTableKey: '$tableUniqueKey', currentTableInfo: globalSupabaseSchema['$tableUniqueKey']!);",
    );
    sb.writeln();

    // Simplified select method
    sb.writeln('  $className select([List<$enumName>? columns]) {');
    sb.writeln('    if (columns == null || columns.isEmpty) {');
    sb.writeln('      selectAll();');
    sb.writeln('    } else {');
    sb.writeln(
      '      final dbColumnNames = columns.map((e) => e.dbName).toList();',
    );
    sb.writeln('      selectSupabaseColumns(dbColumnNames);');
    sb.writeln('    }');
    sb.writeln('    return this;');
    sb.writeln('  }');
    sb.writeln();

    final Set<String> generatedMethodNames = {};

    // Generate methods for forward relationships
    for (final fk in table.foreignKeys) {
      // Check if the foreign table is in the 'public' schema
      final relatedTableInfo =
          _tableMap['public.${fk.originalForeignTableName}'];
      if (relatedTableInfo == null || relatedTableInfo.schema != 'public') {
        _logger.fine(
          'Skipping forward relationship for FK ${fk.constraintName} on table ${table.originalName} because related table ${fk.originalForeignTableName} is not in public schema.',
        );
        continue;
      }

      final relatedTableName = fk.originalForeignTableName;
      final relatedBuilderClassName = StringUtils.toClassName(
        relatedTableName,
        suffix: 'SelectBuilder',
      );
      var relationshipName = _deriveRelationshipName(fk);
      final methodName = StringUtils.capitalize(relationshipName);

      // Add innerJoin parameter to the method signature
      sb.writeln(
        '  $className with$methodName($relatedBuilderClassName? builder, {bool innerJoin = false}) {', // Renamed parameter
      );
      // Nested builder instantiation remains the same
      sb.writeln(
        '    final finalBuilder = builder ?? $relatedBuilderClassName();',
      );
      sb.writeln('    if (builder == null) {');
      sb.writeln(
        '      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder',
      );
      sb.writeln('    }');
      sb.writeln('    addSupabaseRelated(');
      sb.writeln('        jsonKey: \'${relationshipName.snakeCase}\',');
      sb.writeln('        fkConstraintName: \'${fk.constraintName}\',');
      sb.writeln('        nestedBuilder: finalBuilder,');
      sb.writeln('        innerJoin: innerJoin);'); // Pass the renamed flag
      sb.writeln('    return this;');
      sb.writeln('  }');
      sb.writeln();
    }

    // Generate methods for reverse relationships
    final reverseFkInfos = _reverseForeignKeyMap[table.uniqueKey] ?? [];
    for (final reverseInfo in reverseFkInfos) {
      final referencingTable = reverseInfo.referencingTable;

      // Check if the referencing table is in the 'public' schema
      if (referencingTable.schema != 'public') {
        _logger.fine(
          'Skipping reverse relationship from ${referencingTable.originalName} to ${table.originalName} via FK ${reverseInfo.fk.constraintName} because referencing table is not in public schema.',
        );
        continue;
      }

      // Skip if this FK is already handled as a forward relationship on the same table (self-reference)
      if (referencingTable.uniqueKey == table.uniqueKey &&
          table.foreignKeys.any(
            (fk) => fk.constraintName == reverseInfo.fk.constraintName,
          )) {
        continue;
      }

      final relatedBuilderClassName = StringUtils.toClassName(
        referencingTable.originalName,
        suffix: 'SelectBuilder',
      );

      String relationshipName;
      // String relationshipKey; // This variable is no longer the primary source for jsonKey
      final bool isReferencingTableAJoinTableForThisFk =
          reverseInfo.fk.joinTableName != null &&
          reverseInfo.fk.joinTableName == referencingTable.originalName;

      if (isReferencingTableAJoinTableForThisFk) {
        // For M-M relationships where the 'referencingTable' is the join table itself,
        // the relationshipName for the method often reflects the join table.
        relationshipName = StringUtils.toCamelCase(
          referencingTable.originalName,
        );
        // relationshipKey = referencingTable.originalName; // Original logic for relationshipKey
      } else {
        // For 1-M or other reverse relationships
        int fkCountFromReferencingToCurrent = 0;
        for (final fkOnReferencingTable in referencingTable.foreignKeys) {
          if (fkOnReferencingTable.foreignTableSchema == table.schema &&
              fkOnReferencingTable.originalForeignTableName ==
                  table.originalName) {
            fkCountFromReferencingToCurrent++;
          }
        }

        if (fkCountFromReferencingToCurrent > 1) {
          // If current table is referenced multiple times by the same 'referencingTable'
          // (e.g., images referenced by books.cover_image_id and books.banner_image_id)
          // use the role derived from the FK column on the referencing table for disambiguation.
          final roleName = _deriveRelationshipName(
            reverseInfo.fk, // This is the FK on the referencingTable
            referencingTableName: referencingTable.originalName,
            isReverseRelationship: true,
          );
          relationshipName = pluralize(
            roleName,
          ); // e.g. "coverImagesBooks", "bannerImagesBooks" or similar
        } else {
          // Default: pluralized name of the referencing table
          relationshipName = pluralize(
            StringUtils.toCamelCase(referencingTable.originalName),
          );
        }
        // relationshipKey = referencingTable.originalName; // Original logic for relationshipKey
      }

      String methodName = StringUtils.capitalize(relationshipName);

      // Disambiguation logic for methodName (if different paths still lead to same name)
      if (generatedMethodNames.contains(methodName)) {
        final fkColumnPart =
            reverseInfo.fk.originalColumns.isNotEmpty
                ? StringUtils.toPascalCase(
                  reverseInfo.fk.originalColumns.first
                      .replaceAll('_id', '')
                      .replaceAll('_fkey', ''),
                )
                : '';
        String disambiguatedMethodName =
            '${methodName}Via${fkColumnPart.isNotEmpty ? fkColumnPart : StringUtils.toPascalCase(reverseInfo.fk.constraintName)}';
        if (!generatedMethodNames.contains(disambiguatedMethodName)) {
          methodName = disambiguatedMethodName;
        } else {
          int counter = 2;
          String finalAttemptName = disambiguatedMethodName;
          while (generatedMethodNames.contains(finalAttemptName)) {
            finalAttemptName = '${disambiguatedMethodName}${counter++}';
          }
          methodName = finalAttemptName;
          _logger.warning(
            "Had to use counter to disambiguate method name for $className.$methodName based on reverse FK ${reverseInfo.fk.constraintName}",
          );
        }
      }
      generatedMethodNames.add(methodName);

      // Add innerJoin parameter to the method signature
      sb.writeln(
        '  $className with$methodName($relatedBuilderClassName? builder, {bool innerJoin = false}) {', // Renamed parameter
      );
      sb.writeln(
        '    final finalBuilder = builder ?? $relatedBuilderClassName();',
      );
      sb.writeln('    if (builder == null) {');
      sb.writeln(
        '      finalBuilder.selectAll(); // Default to selecting all columns for the nested builder',
      );
      sb.writeln('    }');
      sb.writeln('    addSupabaseRelated(');
      // Use the snake_case version of the (potentially disambiguated) relationshipName as the jsonKey.
      // This aligns with how jsonKeys are handled for forward relationships and ensures uniqueness
      // if relationshipName (and thus methodName) is unique.
      sb.writeln('        jsonKey: \'${relationshipName.snakeCase}\',');
      sb.writeln(
        '        fkConstraintName: \'${reverseInfo.fk.constraintName}\',',
      ); // This is the FK on referencingTable
      sb.writeln('        nestedBuilder: finalBuilder,');
      sb.writeln('        innerJoin: innerJoin);'); // Pass the renamed flag
      sb.writeln('    return this;');
      sb.writeln('  }');
      sb.writeln();
    }

    sb.writeln('}');
    return sb.toString();
  }

  String _deriveRelationshipName(
    SupabaseForeignKeyConstraint fk, {
    String? referencingTableName,
    bool isReverseRelationship = false,
  }) {
    if (fk.columns.length == 1) {
      String name;
      if (isReverseRelationship) {
        // For a reverse relationship, the name is derived from the FK column
        // on the referencing table (e.g., books.cover_image_id).
        name = fk.originalColumns.first; // e.g., "cover_image_id"
        const suffixes = ['_id', '_uuid', '_fkey']; // Use same suffixes
        for (final suffix in suffixes) {
          if (name.toLowerCase().endsWith(suffix) &&
              name.length > suffix.length) {
            name = name.substring(
              0,
              name.length - suffix.length,
            ); // e.g., "cover_image"
            break;
          }
        }
      } else {
        // This is for FORWARD relationships
        // For a forward relationship, the name is derived from the FK column on the current table.
        name =
            fk.originalColumns.first; // e.g., "cover_image_id" on books table
        const suffixes = ['_id', '_uuid', '_fkey'];
        for (final suffix in suffixes) {
          if (name.toLowerCase().endsWith(suffix) &&
              name.length > suffix.length) {
            name = name.substring(
              0,
              name.length - suffix.length,
            ); // e.g., "cover_image"
            break;
          }
        }
      }
      name = StringUtils.toCamelCase(name); // e.g., "coverImage"
      return name;
    } else {
      // For composite keys or if a more generic name is needed.
      if (isReverseRelationship) {
        if (referencingTableName == null) {
          _logger.warning(
            "deriveRelationshipName called for reverse composite relationship without 'referencingTableName'. Falling back to FK constraint name.",
          );
          return StringUtils.toCamelCase(fk.constraintName); // Fallback
        }
        // For composite reverse, using the referencing table's name is often a good default.
        return StringUtils.toCamelCase(referencingTableName);
      } else {
        // If forward composite, use the name of the table it points to.
        return StringUtils.toCamelCase(fk.originalForeignTableName);
      }
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

class _ReverseFKInfo {
  final SupabaseTableInfo referencingTable;
  final SupabaseForeignKeyConstraint fk;
  _ReverseFKInfo(this.referencingTable, this.fk);
}

// Helper function to escape strings for Dart code generation
String _escapeStringForDart(String? s) {
  if (s == null) return 'null';
  // More robust escaping for Dart string literals
  return '"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\t', '\\t').replaceAll('\$', '\\\$')}"';
}
