import 'dart:io';
import 'package:tether/config/config_model.dart';
import 'package:tether_libs/models/table_info.dart';
import 'package:tether_libs/utils/logger.dart';

class SchemaRegistryGenerator {
  final SupabaseGenConfig config;
  final Logger _logger;
  final List<SupabaseTableInfo> _allTables;

  SchemaRegistryGenerator({
    required this.config,
    required List<SupabaseTableInfo> allTables,
    Logger? logger,
  }) : _allTables = allTables,
       _logger = logger ?? Logger('SchemaRegistryGenerator');

  Future<void> generate() async {
    if (_allTables.isEmpty) {
      _logger.warning(
        'No table information provided. Skipping schema registry generation.',
      );
      return;
    }

    _logger.info('Starting schema registry generation...');

    final fileContent = _generateRegistryFileContent();
    final filePath = config.schemaRegistryFilePath;

    try {
      await _writeFile(filePath, fileContent);
      _logger.info('Successfully generated schema registry file: $filePath');
    } catch (e, s) {
      _logger.severe(
        'Failed to write schema registry file to $filePath: $e, $s',
      );
    }
  }

  String _generateRegistryFileContent() {
    final sb = StringBuffer();

    // File Header & Imports
    sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    sb.writeln('// ignore_for_file: constant_identifier_names');
    sb.writeln();
    sb.writeln("import 'package:drift/drift.dart';");
    sb.writeln("import 'package:tether_libs/models/schema_registry.dart';");
    sb.writeln(
      "import 'package:tether_libs/models/schema_registry_base.dart';",
    );
    sb.writeln("import 'package:tether_libs/models/select_statement.dart';");
    sb.writeln(
      "import 'package:tether_libs/models/supabase_select_builder_base.dart';",
    );

    // Import your database class
    sb.writeln("import '${config.databaseImportPath}';");

    // Import the generated select builders
    sb.writeln("import '${config.supabaseSelectBuildersImportPath}';");
    sb.writeln();

    // Create schema registry class that extends the abstract base
    sb.writeln(
      '/// Generated schema registry for Drift and Supabase integration',
    );
    sb.writeln('class GeneratedSchemaRegistry extends SchemaRegistryBase {');

    // Modify to use your actual database class name from config
    String dbClassName = config.dbClassName;
    sb.writeln('  final $dbClassName db;');

    // Constructor
    sb.writeln('  GeneratedSchemaRegistry(this.db) {');
    sb.writeln('    registerTables();');
    sb.writeln('  }');
    sb.writeln();

    // Override the registerTables method (no longer private)
    sb.writeln('  @override');
    sb.writeln('  void registerTables() {');

    // Register each table
    for (final table in _allTables) {
      sb.writeln('    // Register ${table.name} table');
      sb.writeln('    registry.registerTable(');
      sb.writeln('      db.${_toCamelCase(table.name)},');
      sb.writeln('      {');

      // Register each column
      for (final column in table.columns) {
        final columnName = column.originalName;
        final driftColumnName = _toCamelCase(column.name);
        sb.writeln(
          '        \'$columnName\': () => db.${_toCamelCase(table.name)}.$driftColumnName,',
        );
      }
      sb.writeln('      },');

      // Register join relations
      sb.writeln('      {');
      for (final fk in table.foreignKeys) {
        final relationName = _deriveRelationshipName(fk);
        final foreignTableName = fk.originalForeignTableName;

        sb.writeln('        \'$relationName\': JoinRelation(');
        sb.writeln('          relatedTableName: \'$foreignTableName\',');
        sb.writeln(
          '          baseColumnName: \'${fk.originalColumns.first}\',',
        );
        sb.writeln(
          '          relatedColumnName: \'${fk.originalForeignColumns.first}\',',
        );
        sb.writeln('          joinType: JoinType.leftOuterJoin,');
        sb.writeln('        ),');
      }
      sb.writeln('      },');
      sb.writeln('    );');
      sb.writeln();
    }

    sb.writeln('  }');

    // Override getExpression method from base class
    sb.writeln('''
  @override
  Expression? getExpression(SupabaseColumn column) {
    return registry.getColumnExpression(column);
  }
  
  @override
  TableInfo<Table, dynamic>? getTableByName(String tableName) {
    return registry.getTableInfo(tableName);
  }
  
  @override
  List<String> get registeredTableNames => registry.getAllTableNames();
  
  @override
  JoinRelation? getJoinRelation(String baseTableName, String relationName) {
    return registry.getJoinRelation(baseTableName, relationName);
  }
  
  @override
  SelectStatement<HasResultSet, dynamic> createSelectWithJoins(
    TableInfo<Table, dynamic> table,
    SupabaseColumn? column,
  ) {
    final driftSelect = db.select(table);
    final selectStatement = SelectStatement<HasResultSet, dynamic>(driftSelect);
    
    // Add joins if needed
    if (column != null && column.relationshipPrefix != null) {
      final relation = registry.getJoinRelation(
        column.tableName,
        column.relationshipPrefix!,
      );
      
      if (relation != null) {
        final relatedTable = registry.getTableInfo(relation.relatedTableName);
        if (relatedTable != null) {
          final joinPredicate = relatedTable
              .createAlias(column.relationshipPrefix!)
              .c[relation.relatedColumnName]
              .equalsExp(table.c[relation.baseColumnName]);
          
          selectStatement.addJoin(
            relatedTable,
            column.relationshipPrefix!,
            joinPredicate,
            relation.joinType
          );
        }
      }
    }
    
    return selectStatement;
  }
  
  @override
  T? convertToDataClass<T>(String tableName, dynamic driftRow) {
    switch (tableName) {
''');

    // Add conversion cases for each table
    for (final table in _allTables) {
      final tableName = table.originalName;
      final dataClassName = _toClassName(table.name);
      sb.writeln('      case \'$tableName\':');
      sb.writeln('        if (driftRow is ${dataClassName}Data) {');
      sb.writeln('          return $dataClassName.fromData(driftRow) as T;');
      sb.writeln('        }');
      sb.writeln('        break;');
    }

    sb.writeln('''
    }
    return null;
  }
''');

    sb.writeln('}'); // End class

    return sb.toString();
  }

  // Utility methods
  String _toClassName(String text) {
    if (text.isEmpty) return '';
    final safeText = text.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    List<String> parts =
        safeText.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    String result = '';
    for (String part in parts) {
      if (part.isNotEmpty) {
        result += part[0].toUpperCase() + part.substring(1).toLowerCase();
      }
    }
    return result;
  }

  String _toCamelCase(String text) {
    final className = _toClassName(text);
    if (className.isEmpty) return '';
    return className[0].toLowerCase() + className.substring(1);
  }

  String _deriveRelationshipName(SupabaseForeignKeyConstraint fk) {
    if (fk.columns.length == 1) {
      String name = fk.originalColumns.first;
      const suffixes = ['_fkey', '_uuid', '_id'];
      for (final suffix in suffixes) {
        if (name.toLowerCase().endsWith(suffix) &&
            name.length > suffix.length) {
          name = name.substring(0, name.length - suffix.length);
          break;
        }
      }
      return _toCamelCase(name);
    } else {
      return _toCamelCase(fk.originalForeignTableName);
    }
  }

  Future<void> _writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        _logger.fine('Creating directory: ${parentDir.path}');
        await parentDir.create(recursive: true);
      }
      await file.writeAsString(content);
      _logger.fine('Successfully wrote file: $filePath');
    } catch (e, s) {
      _logger.severe('Failed to write file to $filePath: $e, $s');
      throw Exception('Failed to write file $filePath: $e');
    }
  }
}
