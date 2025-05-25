import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:tether_generators/config/config_model.dart';
import 'package:tether_generators/utils/schema_version_manager.dart'; // Keep for version tracking
import 'package:tether_libs/models/table_info.dart';
import 'package:tether_libs/utils/logger.dart';

/// Generates Dart files containing SQL migration strings.
class SqliteSchemaGenerator {
  final String outputDirectory; // e.g., lib/generated/sqlite_migrations
  final SchemaVersionManager schemaVersionManager;
  final SupabaseGenConfig config;
  final Logger _logger;

  SqliteSchemaGenerator({
    required this.schemaVersionManager,
    required this.config,
    Logger? logger,
  }) : outputDirectory = p.join(
         config.outputDirectory,
         config.sqliteMigrationsDirectory,
       ),
       // Use config path directly
       _logger = logger ?? Logger('SqliteSchemaGenerator');

  /// Generates Dart migration files based on schema changes.
  /// Returns the highest migration version number generated.
  Future<int> generate(List<SupabaseTableInfo> currentTables) async {
    if (!config.generateSqliteMigrations) {
      _logger.info('SQLite migration generation is disabled. Skipping.');
      return schemaVersionManager
          .currentSchemaVersion; // Return current known version
    }

    await schemaVersionManager.loadPreviousSchemas();
    final previousVersion = schemaVersionManager.currentSchemaVersion;
    final List<SupabaseTableInfo>? previousTables =
        schemaVersionManager.previousSchemaStates[previousVersion];

    int latestVersionGenerated = previousVersion;

    if (previousVersion == 1 || previousTables == null) {
      _logger.info('No previous schema found. Generating initial schema...');
      final sqlStatements = _generateInitialSchemaSql(currentTables); // Changed
      await _writeDartMigrationFile(1, sqlStatements); // Changed
      await schemaVersionManager.saveSchemaVersion(
        1,
        currentTables,
      ); // Save state
      latestVersionGenerated = 1;
      _logger.info('Initial schema generated as migration_v0001.dart.');
    } else {
      _logger.info('Comparing current schema with version $previousVersion...');
      final diff = _diffSchemas(previousTables, currentTables);

      if (!diff.hasChanges) {
        _logger.info('No schema changes detected.');
        return previousVersion; // No new version generated
      }

      final nextVersion = previousVersion + 1;
      _logger.info(
        'Schema changes detected. Generating migration for version $nextVersion...',
      );
      final sqlStatements = _generateMigrationSql(nextVersion, diff); // Changed
      await _writeDartMigrationFile(nextVersion, sqlStatements); // Changed
      await schemaVersionManager.saveSchemaVersion(
        nextVersion,
        currentTables,
      ); // Save state
      latestVersionGenerated = nextVersion;
      _logger.info(
        'Migration file generated as migration_v${nextVersion.toString().padLeft(4, '0')}.dart.',
      );
      _logUnsupportedChanges(diff);
    }
    return latestVersionGenerated;
  }

  /// Generates the SQL statements for the initial schema.
  List<String> _generateInitialSchemaSql(List<SupabaseTableInfo> tables) {
    // Changed return type
    final statements = <String>[];
    statements.add('-- Initial Schema (Version 1)');
    statements.add('-- Generated on ${DateTime.now()}');

    for (final table in tables) {
      statements.addAll(_generateCreateTableStatements(table)); // Changed
    }
    return statements;
  }

  /// Generates the SQL statements for a migration based on diff.
  List<String> _generateMigrationSql(int version, _SchemaDiff diff) {
    // Changed return type
    final statements = <String>[];
    statements.add('-- Schema Migration (Version $version)');
    statements.add('-- Generated on ${DateTime.now()}');
    statements.add('-- Changes from version ${version - 1}');

    // --- Handle Removals First ---
    if (diff.removedIndexes.isNotEmpty) {
      statements.add('-- Removed Indexes --');
      diff.removedIndexes.forEach((tableName, indexes) {
        for (final index in indexes) {
          statements.add('DROP INDEX IF EXISTS "${index.originalName}";');
        }
      });
    }
    if (diff.removedColumns.isNotEmpty) {
      statements.add('-- Removed Columns --');
      diff.removedColumns.forEach((tableName, columns) {
        for (final column in columns) {
          statements.add(
            'ALTER TABLE "$tableName" DROP COLUMN "${column.originalName}";',
          );
        }
      });
    }
    if (diff.removedTables.isNotEmpty) {
      statements.add('-- Removed Tables --');
      for (final table in diff.removedTables) {
        statements.add('DROP TABLE IF EXISTS "${table.originalName}";');
      }
    }

    // --- Handle Additions ---
    if (diff.addedTables.isNotEmpty) {
      statements.add('-- Added Tables --');
      for (final table in diff.addedTables) {
        statements.addAll(_generateCreateTableStatements(table)); // Changed
      }
    }
    if (diff.addedColumns.isNotEmpty) {
      statements.add('-- Added Columns --');
      diff.addedColumns.forEach((tableName, columns) {
        for (final column in columns) {
          final alterSql = _generateAddColumnSql(tableName, column);
          if (alterSql != null) {
            statements.add(alterSql);
          }
        }
      });
    }
    if (diff.addedIndexes.isNotEmpty) {
      statements.add('-- Added Indexes --');
      diff.addedIndexes.forEach((tableName, indexes) {
        final tableInfo =
            diff.modifiedTables[tableName]?.current ??
            diff.currentTablesMap[tableName];
        if (tableInfo != null) {
          statements.addAll(
            _generateCreateIndexStatements(tableInfo, indexes),
          ); // Changed
        }
      });
    }

    // --- Handle Modifications (Comments Only) ---
    if (diff.modifiedColumns.isNotEmpty) {
      statements.add('-- Modified Columns (Manual Action Likely Required) --');
      diff.modifiedColumns.forEach((tableName, colDiffs) {
        colDiffs.forEach((colName, colDiff) {
          statements.add(
            '-- WARNING: Column "$tableName"."$colName" modified. SQLite ALTER TABLE has limitations.',
          );
          statements.add('-- Previous: ${_columnToString(colDiff.previous)}');
          statements.add('-- Current:  ${_columnToString(colDiff.current)}');
          statements.add('-- Manual migration steps may be required.');
        });
      });
    }

    return statements;
  }

  /// Writes the generated SQL statements into a Dart file.
  Future<void> _writeDartMigrationFile(
    int version,
    List<String> sqlStatements,
  ) async {
    _logger.info('Writing migration file for version $version...');
    // Changed parameter type
    if (sqlStatements.where((s) => !s.trim().startsWith('--')).isEmpty) {
      // Check if only comments
      _logger.warning(
        'Skipping empty migration (only comments) for version $version.',
      );
      return;
    }

    final versionStr = version.toString().padLeft(4, '0');
    final fileName = 'migration_v$versionStr.dart';
    final filePath = p.join(outputDirectory, fileName);
    final variableName =
        'migrationSqlStatementsV$version'; // Adjusted variable name

    final StringBuffer listContentBuffer = StringBuffer();
    for (final statement in sqlStatements) {
      if (statement.trim().startsWith('--')) {
        listContentBuffer.writeln("  '''$statement''',");
      } else {
        // Escape backticks and dollar signs within raw strings if they are not part of interpolation
        final escapedStatement = statement
            .replaceAll(r'\', r'\\') // Escape backslashes first
            .replaceAll(r'`', r'\`') // Escape backticks
            .replaceAll(r'$', r'\$'); // Escape dollar signs
        listContentBuffer.writeln("  r'''\n$escapedStatement\n''',");
      }
    }

    final String dartContent = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// Migration version: $version
// Generated on ${DateTime.now()}

const List<String> $variableName = [
${listContentBuffer.toString().trimRight()}
];
''';

    try {
      final file = File(filePath);
      await file.parent.create(recursive: true); // Ensure directory exists
      await file.writeAsString(dartContent);
      _logger.info('Generated Dart migration: $filePath');
    } catch (e) {
      _logger.severe('Error writing Dart migration file $filePath: $e');
    }
  }

  /// Generates the `CREATE TABLE` SQL statement and associated index statements.
  List<String> _generateCreateTableStatements(SupabaseTableInfo tableInfo) {
    // Changed return type
    final statements = <String>[];
    if (tableInfo.columns.isEmpty) {
      _logger.warning(
        'Skipping CREATE TABLE for "${tableInfo.originalName}": No columns defined.',
      );
      return statements;
    }

    final buffer = StringBuffer();
    final quotedTableName = '"${tableInfo.originalName}"';
    buffer.writeln('CREATE TABLE IF NOT EXISTS $quotedTableName (');

    final columnDefinitions = <String>[];
    final primaryKeyColumns = <String>[];
    final constraints = <String>[];

    for (final column in tableInfo.columns) {
      final sqliteType = _mapPostgresToSqliteType(column.type);
      final columnDef = StringBuffer();
      final quotedColumnName = '"${column.originalName}"';

      columnDef.write('  $quotedColumnName $sqliteType');

      if (column.isPrimaryKey) {
        primaryKeyColumns.add(quotedColumnName);
        // SQLite implicitly handles AUTOINCREMENT for single INTEGER PRIMARY KEY
        // Add explicit PK constraint later if needed (multi-column or non-integer)
        if (sqliteType == 'INTEGER' && tableInfo.primaryKeys.length == 1) {
          columnDef.write(' PRIMARY KEY');
          // Add AUTOINCREMENT if it's a serial type from Postgres
          if (column.type.toLowerCase().contains('serial')) {
            columnDef.write(' AUTOINCREMENT');
          }
        }
      }

      if (!column.isNullable) {
        columnDef.write(' NOT NULL');
      }

      // Handle DEFAULT values
      if (column.defaultValue != null) {
        String? sqliteDefault = _translateDefaultValue(
          column.defaultValue!,
          sqliteType,
        );
        if (sqliteDefault != null) {
          columnDef.write(' DEFAULT $sqliteDefault');
        } else {
          _logger.warning(
            'Could not translate default value "${column.defaultValue}" for column "$quotedColumnName" in table "$quotedTableName". Omitting DEFAULT clause.',
          );
        }
      }

      // Add UNIQUE constraint inline if it's not also a PK
      // (PK implies unique) and not part of a multi-column UNIQUE constraint (handled later)
      if (column.isUnique && !column.isPrimaryKey) {
        // Check if this column is part of a multi-column unique index
        bool isMultiColumnUnique = tableInfo.indexes.any(
          (idx) =>
              idx.isUnique &&
              idx.originalColumns.contains(column.originalName) &&
              idx.originalColumns.length > 1,
        );
        if (!isMultiColumnUnique) {
          columnDef.write(' UNIQUE');
        }
      }
      columnDefinitions.add(columnDef.toString());
    }

    // Add multi-column primary key constraint if necessary
    if (primaryKeyColumns.length > 1) {
      constraints.add('  PRIMARY KEY (${primaryKeyColumns.join(', ')})');
    } else if (primaryKeyColumns.length == 1) {
      final pkColumn = tableInfo.primaryKeys.first;
      final pkSqliteType = _mapPostgresToSqliteType(pkColumn.type);
      // Add explicit PK constraint if it wasn't an INTEGER PK handled inline
      if (pkSqliteType != 'INTEGER') {
        constraints.add('  PRIMARY KEY (${primaryKeyColumns.join(', ')})');
      }
    }

    for (final fk in tableInfo.foreignKeys) {
      final localCols = fk.originalColumns.map((c) => '"$c"').join(', ');
      final foreignTable = '"${fk.originalForeignTableName}"';
      final foreignCols = fk.originalForeignColumns
          .map((c) => '"$c"')
          .join(', ');
      final onDelete = _translateForeignKeyAction(fk.deleteRule);
      final onUpdate = _translateForeignKeyAction(fk.updateRule);
      constraints.add(
        '  CONSTRAINT "${fk.constraintName}" FOREIGN KEY ($localCols) REFERENCES $foreignTable ($foreignCols) ON DELETE $onDelete ON UPDATE $onUpdate',
      );
    }

    for (final index in tableInfo.indexes) {
      if (index.isUnique && index.originalColumns.length > 1) {
        bool isPrimaryKey = const ListEquality().equals(
          index.originalColumns.sorted((a, b) => a.compareTo(b)),
          tableInfo.primaryKeys
              .map((pk) => pk.originalName)
              .sorted((a, b) => a.compareTo(b)),
        );
        if (!isPrimaryKey) {
          final uniqueCols = index.originalColumns
              .map((c) => '"$c"')
              .join(', ');
          constraints.add(
            '  CONSTRAINT "${index.originalName}_unique" UNIQUE ($uniqueCols)',
          );
        }
      }
    }

    buffer.write(columnDefinitions.join(',\n'));
    if (constraints.isNotEmpty) {
      buffer.writeln(',');
      buffer.write(constraints.join(',\n'));
    }
    buffer.writeln();
    buffer.write(');');
    statements.add(
      buffer.toString(),
    ); // Add the complete CREATE TABLE statement

    statements.addAll(
      _generateCreateIndexStatements(tableInfo),
    ); // Add separate CREATE INDEX statements
    return statements;
  }

  /// Generates `CREATE INDEX` statements.
  List<String> _generateCreateIndexStatements(
    SupabaseTableInfo tableInfo, [ // Changed return type
    List<SupabaseIndexInfo>? indexesToCreate,
  ]) {
    final statements = <String>[];
    final indexes = indexesToCreate ?? tableInfo.indexes;

    for (final index in indexes) {
      bool isHandledByConstraint =
          index.isUnique ||
          const ListEquality().equals(
            index.originalColumns.sorted((a, b) => a.compareTo(b)),
            tableInfo.primaryKeys
                .map((pk) => pk.originalName)
                .sorted((a, b) => a.compareTo(b)),
          );

      if (!isHandledByConstraint) {
        final quotedTableName = '"${tableInfo.originalName}"';
        final quotedIndexName = '"${index.originalName}"';
        final indexCols = index.originalColumns.map((c) => '"$c"').join(', ');
        statements.add(
          'CREATE INDEX IF NOT EXISTS $quotedIndexName ON $quotedTableName ($indexCols);',
        );
      }
    }
    return statements;
  }

  /// Generates an `ALTER TABLE ... ADD COLUMN ...` statement. Returns null if column info is invalid.
  String? _generateAddColumnSql(
    String originalTableName,
    SupabaseColumnInfo column,
  ) {
    final sqliteType = _mapPostgresToSqliteType(column.type);
    final quotedTableName = '"$originalTableName"';
    final quotedColumnName = '"${column.originalName}"';
    final buffer = StringBuffer();

    buffer.write(
      'ALTER TABLE $quotedTableName ADD COLUMN $quotedColumnName $sqliteType',
    );

    if (!column.isNullable) {
      // SQLite requires a DEFAULT value when adding a NOT NULL column
      // unless the table is empty. We must provide one.
      String? sqliteDefault =
          (column.defaultValue != null)
              ? _translateDefaultValue(column.defaultValue!, sqliteType)
              : _getDefaultValueForNotNull(
                sqliteType,
              ); // Get a sensible default

      if (sqliteDefault != null) {
        buffer.write(' NOT NULL DEFAULT $sqliteDefault');
      } else {
        // Cannot add NOT NULL column without a default in SQLite if table might have rows
        _logger.warning(
          'Cannot add NOT NULL column "$quotedColumnName" to table "$quotedTableName" without a translatable or default DEFAULT value. Adding as nullable instead.',
        );
        // Fallback to nullable if no default can be determined
        // buffer.write(' NULL'); // Implicitly nullable if NOT NULL is omitted
      }
    }
    // Add default value even if nullable
    else if (column.defaultValue != null) {
      String? sqliteDefault = _translateDefaultValue(
        column.defaultValue!,
        sqliteType,
      );
      if (sqliteDefault != null) {
        buffer.write(' DEFAULT $sqliteDefault');
      } else {
        _logger.warning(
          'Could not translate default value "${column.defaultValue}" for added column "$quotedColumnName" in table "$quotedTableName". Omitting DEFAULT clause.',
        );
      }
    }

    // Note: Adding UNIQUE or FOREIGN KEY constraints via ALTER TABLE ADD COLUMN
    // is generally NOT supported directly in older SQLite versions.
    // UNIQUE might work in newer versions. FKs usually require table recreation.
    if (column.isUnique) {
      _logger.warning(
        'UNIQUE constraint on added column "$quotedColumnName" in table "$quotedTableName" might not be supported by all SQLite versions via ALTER TABLE. Add manually if needed.',
      );
      // buffer.write(' UNIQUE'); // Add if targeting newer SQLite
    }

    buffer.write(';');
    return buffer.toString();
  }

  /// Provides a sensible SQLite default literal for a type when adding a NOT NULL column.
  String? _getDefaultValueForNotNull(String sqliteType) {
    switch (sqliteType) {
      case 'INTEGER':
        return '0';
      case 'REAL':
        return '0.0';
      case 'TEXT':
        return "''"; // Empty string
      case 'BLOB':
        return "X''"; // Empty blob literal
      default:
        return null; // Unknown type
    }
  }

  /// Maps PostgreSQL type names to SQLite compatible type names.
  String _mapPostgresToSqliteType(String postgresType) {
    final lowerType = postgresType.toLowerCase().trim();

    if (lowerType.endsWith('[]')) return 'TEXT'; // Store arrays as JSON strings
    if (lowerType.startsWith('_'))
      return 'TEXT'; // Alternative array notation like _text

    final typeBase =
        lowerType
            .split('(')
            .first
            .split(' ')
            .first; // Handle 'double precision'

    switch (typeBase) {
      case 'int':
      case 'int2':
      case 'int4':
      case 'int8':
      case 'integer':
      case 'smallint':
      case 'bigint':
      case 'serial':
      case 'smallserial':
      case 'bigserial':
      case 'oid': // Object Identifier Type
        return 'INTEGER';
      case 'text':
      case 'varchar':
      case 'char':
      case 'bpchar':
      case 'name':
      case 'citext':
      case 'uuid':
      case 'xml':
      case 'tsvector': // Full-text search vector
        return 'TEXT';
      case 'bool':
      case 'boolean':
        return 'INTEGER'; // 0 or 1
      case 'float4':
      case 'float8':
      case 'real':
      case 'double': // Handle 'double precision'
      case 'numeric':
      case 'decimal':
      case 'money':
        return 'REAL';
      case 'timestamp':
      case 'timestamptz':
      case 'date':
      case 'time':
      case 'timetz':
      case 'interval':
        return 'TEXT'; // ISO8601 strings recommended
      case 'json':
      case 'jsonb':
        return 'TEXT'; // Use json1 extension
      case 'bytea':
        return 'BLOB';
      case 'point':
      case 'line':
      case 'lseg':
      case 'box':
      case 'path':
      case 'polygon':
      case 'circle':
        return 'TEXT'; // Or BLOB
      case 'cidr':
      case 'inet':
      case 'macaddr':
      case 'macaddr8':
        return 'TEXT';
      // Add mappings for other PG types as needed
      // case 'geometry': // PostGIS type
      // case 'geography': // PostGIS type
      //   return 'BLOB'; // Or TEXT depending on storage format (WKT, WKB)
      default:
        _logger.warning(
          'Unmapped PostgreSQL type "$postgresType" -> defaulting to TEXT',
        );
        return 'TEXT';
    }
  }

  /// Attempts to translate simple PostgreSQL default values to SQLite literals.
  String? _translateDefaultValue(String pgDefault, String sqliteType) {
    final lowerDefault = pgDefault.toLowerCase().trim();

    // Handle common function calls
    if (lowerDefault == 'now()' ||
        lowerDefault == 'current_timestamp' ||
        lowerDefault == 'transaction_timestamp()') {
      // SQLite CURRENT_TIMESTAMP returns 'YYYY-MM-DD HH:MM:SS'
      // SQLite CURRENT_TIME returns 'HH:MM:SS'
      // SQLite CURRENT_DATE returns 'YYYY-MM-DD'
      // Choose based on target SQLite type (usually TEXT for timestamps)
      return (sqliteType == 'TEXT' || sqliteType == 'INTEGER')
          ? 'CURRENT_TIMESTAMP'
          : null;
    }
    if (lowerDefault.contains('uuid_generate_v4()') ||
        lowerDefault.contains('gen_random_uuid()')) {
      return null; // No direct SQLite default equivalent, handle in app
    }
    if (lowerDefault.startsWith('nextval(')) {
      return null; // Sequences aren't directly mapped, rely on AUTOINCREMENT
    }

    // Handle boolean literals
    if (sqliteType == 'INTEGER' &&
        (lowerDefault == 'true' || lowerDefault == 'false')) {
      return (lowerDefault == 'true') ? '1' : '0';
    }

    // Handle numeric literals
    if ((sqliteType == 'INTEGER' || sqliteType == 'REAL') &&
        num.tryParse(lowerDefault) != null) {
      return lowerDefault; // Assume it's a valid number literal
    }

    // Handle string literals (potentially with type casts like 'text'::text or empty array '{}'::text[])
    final stringLiteralMatch = RegExp(
      r"^'(.*)'(?:::[\w\s\[\]]+)?$",
    ).firstMatch(lowerDefault);
    if (stringLiteralMatch != null) {
      String literal = stringLiteralMatch.group(1)!;
      return "'${literal.replaceAll("'", "''")}'"; // Escape single quotes
    }
    // Handle empty array literal specifically if not caught above
    if (lowerDefault.startsWith("'{}'::")) {
      return "''"; // Map empty array default to empty string
    }

    // Handle potential NULL literal
    if (lowerDefault == 'null') {
      return 'NULL';
    }

    // Fallback for simple literals that might not be quoted in pg (less common for defaults)
    if (sqliteType == 'TEXT') {
      // Be cautious here, might misinterpret things. Only use if confident.
      // Example: DEFAULT some_enum_value
      // return "'${pgDefault.replaceAll("'", "''")}'";
      _logger.warning(
        'Default value "$pgDefault" for TEXT column could not be reliably translated. Omitting.',
      );
      return null;
    }

    // If none of the above, cannot safely translate
    _logger.warning(
      'Default value "$pgDefault" could not be translated to SQLite. Omitting.',
    );
    return null;
  }

  /// Translates PostgreSQL foreign key actions to SQLite equivalents.
  String _translateForeignKeyAction(String pgAction) {
    switch (pgAction.toUpperCase()) {
      case 'NO ACTION':
        return 'NO ACTION';
      case 'RESTRICT':
        return 'RESTRICT';
      case 'CASCADE':
        return 'CASCADE';
      case 'SET NULL':
        return 'SET NULL';
      case 'SET DEFAULT':
        return 'SET DEFAULT';
      default:
        _logger.warning(
          'Unknown foreign key action "$pgAction", defaulting to NO ACTION.',
        );
        return 'NO ACTION';
    }
  }

  /// Diffs two lists of SupabaseTableInfo to find changes.
  _SchemaDiff _diffSchemas(
    List<SupabaseTableInfo> previous,
    List<SupabaseTableInfo> current,
  ) {
    final previousMap = {for (var t in previous) t.uniqueKey: t};
    final currentMap = {for (var t in current) t.uniqueKey: t};
    final diff = _SchemaDiff(currentMap); // Pass current map for lookups

    // Find added and potentially modified tables
    for (final currentKey in currentMap.keys) {
      final currentTable = currentMap[currentKey]!;
      if (!previousMap.containsKey(currentKey)) {
        diff.addedTables.add(currentTable);
      } else {
        // Table exists in both, check for modifications
        final previousTable = previousMap[currentKey]!;
        final tableDiff = _diffTable(previousTable, currentTable);
        if (tableDiff.hasChanges) {
          diff.modifiedTables[currentTable.originalName] =
              tableDiff; // Use original name as key
          if (tableDiff.addedColumns.isNotEmpty) {
            diff.addedColumns[currentTable.originalName] =
                tableDiff.addedColumns;
          }
          if (tableDiff.removedColumns.isNotEmpty) {
            diff.removedColumns[currentTable.originalName] =
                tableDiff.removedColumns;
          }
          if (tableDiff.modifiedColumns.isNotEmpty) {
            diff.modifiedColumns[currentTable.originalName] =
                tableDiff.modifiedColumns;
          }
          if (tableDiff.addedIndexes.isNotEmpty) {
            diff.addedIndexes[currentTable.originalName] =
                tableDiff.addedIndexes;
          }
          if (tableDiff.removedIndexes.isNotEmpty) {
            diff.removedIndexes[currentTable.originalName] =
                tableDiff.removedIndexes;
          }
          // Could add FK diffing here too
        }
      }
    }

    // Find removed tables
    for (final previousKey in previousMap.keys) {
      if (!currentMap.containsKey(previousKey)) {
        diff.removedTables.add(previousMap[previousKey]!);
      }
    }

    return diff;
  }

  /// Diffs two versions of the same table.
  _TableDiff _diffTable(SupabaseTableInfo previous, SupabaseTableInfo current) {
    final diff = _TableDiff(previous, current);
    final prevColMap = {for (var c in previous.columns) c.originalName: c};
    final currColMap = {for (var c in current.columns) c.originalName: c};
    final prevIdxMap = {for (var i in previous.indexes) i.originalName: i};
    final currIdxMap = {for (var i in current.indexes) i.originalName: i};
    // Could add FK diffing maps here

    // Find added/modified columns
    for (final colName in currColMap.keys) {
      if (!prevColMap.containsKey(colName)) {
        diff.addedColumns.add(currColMap[colName]!);
      } else {
        // Check if column definition changed (basic check)
        final prevCol = prevColMap[colName]!;
        final currCol = currColMap[colName]!;
        // Simple JSON comparison for modification detection
        if (jsonEncode(prevCol.toJson()) != jsonEncode(currCol.toJson())) {
          diff.modifiedColumns[colName] = _ColumnDiff(prevCol, currCol);
        }
      }
    }
    // Find removed columns
    for (final colName in prevColMap.keys) {
      if (!currColMap.containsKey(colName)) {
        diff.removedColumns.add(prevColMap[colName]!);
      }
    }

    // Find added/modified indexes
    for (final indexName in currIdxMap.keys) {
      if (!prevIdxMap.containsKey(indexName)) {
        diff.addedIndexes.add(currIdxMap[indexName]!);
      } else {
        // Could add check for index modification (e.g., columns changed)
        final prevIdx = prevIdxMap[indexName]!;
        final currIdx = currIdxMap[indexName]!;
        if (jsonEncode(prevIdx.toJson()) != jsonEncode(currIdx.toJson())) {
          // Mark as modified (though we might only care about added/removed for generation)
          // diff.modifiedIndexes[indexName] = _IndexDiff(prevIdx, currIdx);
        }
      }
    }
    // Find removed indexes
    for (final indexName in prevIdxMap.keys) {
      if (!currIdxMap.containsKey(indexName)) {
        diff.removedIndexes.add(prevIdxMap[indexName]!);
      }
    }

    // Add FK diffing logic here if needed

    return diff;
  }

  // Add helper to format column info for warnings
  String _columnToString(SupabaseColumnInfo col) {
    final pk = col.isPrimaryKey ? ' PK' : '';
    final nn = !col.isNullable ? ' NOT NULL' : '';
    final uq = col.isUnique ? ' UNIQUE' : '';
    final def = col.defaultValue != null ? ' DEFAULT ${col.defaultValue}' : '';
    return '"${col.originalName}" ${col.type}$pk$nn$uq$def';
  }

  /// Logs warnings for changes that are not automatically handled by the generated SQL.
  void _logUnsupportedChanges(_SchemaDiff diff) {
    // Warnings for removed elements are no longer needed as they are handled in _generateMigrationFile

    // Keep warnings for modified columns as these often require manual intervention
    if (diff.modifiedColumns.isNotEmpty) {
      diff.modifiedColumns.forEach((tableName, colDiffs) {
        colDiffs.forEach((colName, colDiff) {
          // Log specific modification types if needed (e.g., type change, nullability change)
          _logger.warning(
            "Detected modified column '$colName' in table '$tableName'. Review migration file; manual action likely required in SQLite (e.g., for type/constraint changes).",
          );
        });
      });
    }
    // Add warnings for modified FKs etc. if diffing is implemented for them
  }
} // End SqliteSchemaGenerator

// --- Helper classes for schema diffing (Keep these as they are) ---
class _SchemaDiff {
  final Map<String, SupabaseTableInfo> currentTablesMap; // For easy lookup
  final List<SupabaseTableInfo> addedTables = [];
  final List<SupabaseTableInfo> removedTables = [];
  final Map<String, _TableDiff> modifiedTables = {}; // Key: original table name

  // Convenience maps for easier access in generator
  final Map<String, List<SupabaseColumnInfo>> addedColumns =
      {}; // Key: original table name
  final Map<String, List<SupabaseColumnInfo>> removedColumns =
      {}; // Key: original table name
  final Map<String, Map<String, _ColumnDiff>> modifiedColumns =
      {}; // Key: original table name, Inner Key: original column name
  final Map<String, List<SupabaseIndexInfo>> addedIndexes =
      {}; // Key: original table name
  final Map<String, List<SupabaseIndexInfo>> removedIndexes =
      {}; // Key: original table name
  // Add maps for FKs if needed

  _SchemaDiff(this.currentTablesMap);

  bool get hasChanges =>
      addedTables.isNotEmpty ||
      removedTables.isNotEmpty ||
      modifiedTables.isNotEmpty;
}

class _TableDiff {
  final SupabaseTableInfo previous;
  final SupabaseTableInfo current;
  final List<SupabaseColumnInfo> addedColumns = [];
  final List<SupabaseColumnInfo> removedColumns = [];
  final Map<String, _ColumnDiff> modifiedColumns =
      {}; // Key: original column name
  final List<SupabaseIndexInfo> addedIndexes = [];
  final List<SupabaseIndexInfo> removedIndexes = [];
  // Add lists/maps for FKs, modified indexes if needed

  _TableDiff(this.previous, this.current);

  bool get hasChanges =>
      addedColumns.isNotEmpty ||
      removedColumns.isNotEmpty ||
      modifiedColumns.isNotEmpty ||
      addedIndexes.isNotEmpty ||
      removedIndexes.isNotEmpty;
  // Add FK checks etc.
}

class _ColumnDiff {
  final SupabaseColumnInfo previous;
  final SupabaseColumnInfo current;
  // Add specific flags for detected changes if needed (e.g., typeChanged, nullabilityChanged)
  _ColumnDiff(this.previous, this.current);
}
