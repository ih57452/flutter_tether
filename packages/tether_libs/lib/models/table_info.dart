import 'package:collection/collection.dart';
import 'package:tether_libs/utils/string_utils.dart';
import 'package:tether_libs/utils/to_camel_case.dart';

/// Dart keywords that can't be used as identifiers without modification
final Set<String> _dartKeywords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
};

/// Dart built-in types/classes that we shouldn't use as table class names
final Set<String> _dartBuiltInTypes = {
  'List',
  'Map',
  'Set',
  'String',
  'Object',
  'Future',
  'Stream',
  'Function',
  'Type',
  'Null',
  'Bool',
  'Int',
  'Double',
  'Num',
  'Runes',
  'Symbol',
  'DateTime',
  'Duration',
  'Iterable',
  'Uri',
};

/// Represents information about a database index.
class SupabaseIndexInfo {
  /// The name of the index (converted to camelCase).
  final String name;

  /// The original database name of the index.
  final String originalName;

  /// A Dart-safe name for the index, avoiding keyword conflicts.
  final String localName;

  /// Whether the index enforces uniqueness.
  final bool isUnique;

  // Column names covered by the index (converted to camelCase).
  final List<String> columns;

  // Original database names of columns covered by the index.
  final List<String> originalColumns;

  SupabaseIndexInfo({
    required this.name,
    required this.originalName,
    String? localName,
    required this.isUnique,
    required this.columns,
    required this.originalColumns,
  }) : localName = localName ?? _makeSafeDartIdentifier(name);

  /// Helper function to make a safe Dart identifier
  static String _makeSafeDartIdentifier(String name) {
    return _dartKeywords.contains(name) ? '${name}Index' : name;
  }

  /// Factory to create an IndexInfo object from a raw SQL query result row.
  /// Expects row format: [original_index_name, is_unique, indexed_columns_text]
  factory SupabaseIndexInfo.fromRow(
    List<dynamic> row,
    String Function(String) nameConverter,
  ) {
    final originalIndexName = row[0] as String;
    final convertedName = nameConverter(originalIndexName);
    final isUnique = row[1] as bool? ?? false;
    // Index 2 is now the text representation of the array (e.g., {"col1","col2"})
    final columnsText = row[2] as String?;
    final originalColumnNames = _parsePgTextArray(
      columnsText,
    ); // Parse the string

    return SupabaseIndexInfo(
      name: convertedName, // Convert index name
      originalName: originalIndexName,
      localName: _makeSafeDartIdentifier(convertedName),
      isUnique: isUnique,
      columns:
          originalColumnNames
              .map(nameConverter)
              .toList(), // Convert column names
      originalColumns: originalColumnNames,
    );
  }

  /// Converts this object to a JSON map for serialization.
  Map<String, dynamic> toJson() => {
    'name': name,
    'originalName': originalName,
    'localName': localName,
    'isUnique': isUnique,
    'columns': columns,
    'originalColumns': originalColumns,
  };

  /// Creates an IndexInfo object from a JSON map.
  factory SupabaseIndexInfo.fromJson(Map<String, dynamic> json) {
    // Handle potential missing original names in older delta files
    final cols = List<String>.from(json['columns'] as List? ?? []);
    final origCols = List<String>.from(
      json['originalColumns'] as List? ?? cols,
    );
    final name = json['name'] as String? ?? ''; // Provide default if missing
    final origName = json['originalName'] as String? ?? name;

    return SupabaseIndexInfo(
      name: name,
      originalName: origName,
      localName: json['localName'] as String? ?? _makeSafeDartIdentifier(name),
      isUnique: json['isUnique'] as bool? ?? false,
      columns: cols,
      originalColumns: origCols,
    );
  }

  @override
  String toString() =>
      'Index $name (Unique: $isUnique, Columns: [${columns.join(', ')}])';
}

// Represents details about a specific foreign key constraint on a table
class SupabaseForeignKeyConstraint {
  final String constraintName; // Keep original constraint name
  final List<String> columns; // Local columns (camelCase)
  final List<String> originalColumns; // Local columns (original DB names)
  final List<String> localColumns; // Safe Dart identifier names
  final String foreignTableSchema; // Keep original schema name
  final String foreignTableName; // Foreign table name (camelCase)
  final String originalForeignTableName; // Foreign table name (original)
  final String localForeignTableName; // Safe Dart class name
  final List<String> foreignColumns; // Foreign columns (camelCase)
  final List<String> originalForeignColumns; // Foreign columns (original)
  final List<String> localForeignColumns; // Safe Dart identifier names
  final String updateRule;
  final String deleteRule;
  final String matchOption;
  final bool isDeferrable;
  final bool initiallyDeferred;
  String? joinTableName; // New property for join table name

  SupabaseForeignKeyConstraint({
    required this.constraintName,
    required this.columns,
    required this.originalColumns,
    List<String>? localColumns,
    required this.foreignTableSchema,
    required this.foreignTableName,
    required this.originalForeignTableName,
    String? localForeignTableName,
    required this.foreignColumns,
    required this.originalForeignColumns,
    List<String>? localForeignColumns,
    required this.updateRule,
    required this.deleteRule,
    required this.matchOption,
    required this.isDeferrable,
    required this.initiallyDeferred,
    this.joinTableName, // Initialize the new property
  }) : localColumns =
           localColumns ??
           originalColumns.map((col) => _makeSafeDartIdentifier(col)).toList(),
       localForeignTableName =
           localForeignTableName ??
           _makeSafeDartClassName(originalForeignTableName),
       localForeignColumns =
           localForeignColumns ??
           originalForeignColumns
               .map((col) => _makeSafeDartIdentifier(col))
               .toList();

  // Helper function to make a safe Dart identifier
  static String _makeSafeDartIdentifier(String name) {
    return _dartKeywords.contains(name) ? '${name}Field' : name;
  }

  // Helper function to make a safe Dart class name
  static String _makeSafeDartClassName(String name) {
    return _dartBuiltInTypes.contains(name) ? '${name}Table' : name;
  }

  // Update fromRawRows method
  static SupabaseForeignKeyConstraint fromRawRows(
    String name,
    List<List<dynamic>> rows,
    String Function(String) nameConverter, {
    String? joinTableName,
  }) {
    if (rows.isEmpty) {
      throw ArgumentError(
        'Cannot create ForeignKeyConstraint from empty rows.',
      );
    }
    final firstRow = rows.first;
    final originalLocalColumns =
        rows.map<String>((row) => row[1] as String).toList();
    final originalForeignTblName = firstRow[3] as String;
    final originalForeignCols =
        rows.map<String>((row) => row[4] as String).toList();

    return SupabaseForeignKeyConstraint(
      constraintName: name,
      columns: originalLocalColumns.map(nameConverter).toList(),
      originalColumns: originalLocalColumns,
      localColumns: originalLocalColumns.map(_makeSafeDartIdentifier).toList(),
      foreignTableSchema: firstRow[2] as String,
      foreignTableName: nameConverter(originalForeignTblName),
      originalForeignTableName: originalForeignTblName,
      localForeignTableName: _makeSafeDartClassName(originalForeignTblName),
      foreignColumns: originalForeignCols.map(nameConverter).toList(),
      originalForeignColumns: originalForeignCols,
      localForeignColumns:
          originalForeignCols.map(_makeSafeDartIdentifier).toList(),
      updateRule: firstRow[5] as String,
      deleteRule: firstRow[6] as String,
      matchOption: firstRow[7] as String,
      isDeferrable: (firstRow[8] as String? ?? 'NO') == 'YES',
      initiallyDeferred: (firstRow[9] as String? ?? 'NO') == 'YES',
      joinTableName: joinTableName, // Set the join table name
    );
  }

  // Update toJson method
  Map<String, dynamic> toJson() => {
    'constraintName': constraintName,
    'columns': columns,
    'originalColumns': originalColumns,
    'localColumns': localColumns,
    'foreignTableSchema': foreignTableSchema,
    'foreignTableName': foreignTableName,
    'originalForeignTableName': originalForeignTableName,
    'localForeignTableName': localForeignTableName,
    'foreignColumns': foreignColumns,
    'originalForeignColumns': originalForeignColumns,
    'localForeignColumns': localForeignColumns,
    'updateRule': updateRule,
    'deleteRule': deleteRule,
    'matchOption': matchOption,
    'isDeferrable': isDeferrable,
    'initiallyDeferred': initiallyDeferred,
    'joinTableName': joinTableName, // Serialize the join table name
  };

  // Update fromJson method
  factory SupabaseForeignKeyConstraint.fromJson(Map<String, dynamic> json) {
    final cols = List<String>.from(json['columns'] as List);
    final origCols = List<String>.from(
      json['originalColumns'] as List? ?? cols,
    );
    final localCols =
        json['localColumns'] != null
            ? List<String>.from(json['localColumns'] as List)
            : origCols.map(_makeSafeDartIdentifier).toList();

    final fTblName = json['foreignTableName'] as String;
    final origFTblName =
        json['originalForeignTableName'] as String? ?? fTblName;
    final localFTblName =
        json['localForeignTableName'] as String? ??
        _makeSafeDartClassName(origFTblName);

    final fCols = List<String>.from(json['foreignColumns'] as List);
    final origFCols = List<String>.from(
      json['originalForeignColumns'] as List? ?? fCols,
    );
    final localFCols =
        json['localForeignColumns'] != null
            ? List<String>.from(json['localForeignColumns'] as List)
            : origFCols.map(_makeSafeDartIdentifier).toList();

    return SupabaseForeignKeyConstraint(
      constraintName: json['constraintName'] as String,
      columns: cols,
      originalColumns: origCols,
      localColumns: localCols,
      foreignTableSchema: json['foreignTableSchema'] as String,
      foreignTableName: fTblName,
      originalForeignTableName: origFTblName,
      localForeignTableName: localFTblName,
      foreignColumns: fCols,
      originalForeignColumns: origFCols,
      localForeignColumns: localFCols,
      updateRule: json['updateRule'] as String,
      deleteRule: json['deleteRule'] as String,
      matchOption: json['matchOption'] as String,
      isDeferrable: json['isDeferrable'] as bool,
      initiallyDeferred: json['initiallyDeferred'] as bool,
      joinTableName:
          json['joinTableName'] as String?, // Deserialize the join table name
    );
  }

  /// Generates a sanitized key for the foreign key relationship.
  /// Removes configured endings from the column name and ensures uniqueness by appending the foreign table name if necessary.
  String sanitizedKey(List<String> endings) {
    String baseName = originalColumns.first;

    // Remove any matching ending from the column name
    for (final ending in endings) {
      if (baseName.toLowerCase().endsWith(ending.toLowerCase())) {
        baseName = baseName.substring(0, baseName.length - ending.length);
        break; // Stop after the first match
      }
    }

    // Convert the base name to camelCase
    baseName = toCamelCase(baseName);

    // If the base name matches the foreign table name, return the pluralized table name
    if (baseName.toLowerCase() == originalForeignTableName.toLowerCase()) {
      return StringUtils.pluralize(baseName);
    }

    // Combine the base name with the foreign table name to ensure uniqueness
    return '${baseName}${StringUtils.capitalize(toCamelCase(originalForeignTableName))}';
  }

  @override
  String toString() =>
      'FK $constraintName (${localColumns.join(', ')}) -> $foreignTableSchema.$localForeignTableName (${localForeignColumns.join(', ')}) ON DELETE $deleteRule ON UPDATE $updateRule${joinTableName != null ? ', Join Table: $joinTableName' : ''}';
}

// Represents details about a single column within a table
class SupabaseColumnInfo {
  final String name; // Will store camelCase name
  final String originalName; // Keep original for lookups if needed
  final String localName; // Safe Dart identifier name for local use
  final String type;
  final bool isNullable;
  final bool isPrimaryKey;
  final bool isUnique;
  final String? defaultValue;
  final String? comment;
  final bool isIdentity; // <<< ADDED PROPERTY

  SupabaseColumnInfo({
    required this.name,
    required this.originalName,
    String? localName,
    required this.type,
    required this.isNullable,
    required this.isPrimaryKey,
    required this.isUnique,
    this.defaultValue,
    this.comment,
    this.isIdentity = false, // <<< ADDED TO CONSTRUCTOR with default
  }) : localName = localName ?? _makeSafeDartIdentifier(originalName);

  // Helper function to make a safe Dart identifier
  static String _makeSafeDartIdentifier(String name) {
    return _dartKeywords.contains(name) ? '${name}Field' : name;
  }

  // Update factory method
  factory SupabaseColumnInfo.fromRow(
    List<dynamic> row,
    String Function(String) nameConverter,
  ) {
    final originalDbName = row[0] as String;

    // --- Determine the correct index for 'is_identity' ---
    // This index MUST match the position of 'is_identity' in the SELECT list
    // of your database schema introspection query.
    // For this example, let's assume it's at index 7.
    const int indexOfIsIdentity = 7; // <<< ADJUST THIS INDEX

    bool isIdentityValue = false;
    if (row.length > indexOfIsIdentity && row[indexOfIsIdentity] is String) {
      // PostgreSQL's information_schema.columns.is_identity is 'YES' or 'NO'
      isIdentityValue =
          (row[indexOfIsIdentity] as String).toUpperCase() == 'YES';
    } else if (row.length > indexOfIsIdentity &&
        row[indexOfIsIdentity] is bool) {
      // In case your query somehow pre-converts it to a boolean
      isIdentityValue = row[indexOfIsIdentity] as bool;
    }
    // Add more checks if other representations are possible

    return SupabaseColumnInfo(
      name: nameConverter(originalDbName),
      originalName: originalDbName,
      localName: _makeSafeDartIdentifier(originalDbName),
      type: row[1] as String, // Assuming type is at index 1
      isNullable:
          (row[2] as String? ?? 'NO').toUpperCase() ==
          'YES', // Assuming is_nullable is at index 2
      defaultValue: row[3] as String?, // Assuming column_default is at index 3
      comment:
          row[4] as String?, // Assuming comment is at index 4 (if you fetch it)
      isPrimaryKey:
          row[5] as bool? ??
          false, // Assuming is_primary_key is at index 5 (you'd need to join to get this)
      isUnique:
          row[6] as bool? ??
          false, // Assuming is_unique is at index 6 (you'd need to join to get this)
      isIdentity: isIdentityValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'originalName': originalName,
    'localName': localName,
    'type': type,
    'isNullable': isNullable,
    'isPrimaryKey': isPrimaryKey,
    'isUnique': isUnique,
    'defaultValue': defaultValue,
    'comment': comment,
    'isIdentity': isIdentity, // <<< ADDED TO toJson
  };

  factory SupabaseColumnInfo.fromJson(Map<String, dynamic> json) {
    final originalName =
        json['originalName'] as String? ?? json['name'] as String;
    return SupabaseColumnInfo(
      name: json['name'] as String,
      originalName: originalName,
      localName:
          json['localName'] as String? ?? _makeSafeDartIdentifier(originalName),
      type: json['type'] as String,
      isNullable: json['isNullable'] as bool,
      isPrimaryKey: json['isPrimaryKey'] as bool,
      isUnique: json['isUnique'] as bool,
      defaultValue: json['defaultValue'] as String?,
      comment: json['comment'] as String?,
      isIdentity:
          json['isIdentity'] as bool? ??
          false, // <<< ADDED TO fromJson with default
    );
  }

  // ... (toString remains the same or update to show name) ...
  @override
  String toString() =>
      'Column $name ($type, Nullable: $isNullable, PK: $isPrimaryKey, Unique: $isUnique, Identity: $isIdentity${defaultValue != null ? ', Default: $defaultValue' : ''}${comment != null ? ', Comment: "$comment"' : ''})'; // <<< ADDED isIdentity to toString
}

/// Represents information about a reverse relationship from another table to this one.
class ModelReverseRelationInfo {
  /// The name of the field in this model that holds the list of related items.
  /// e.g., if AuthorModel has `List<BookModel>? books;`, this would be "books".
  final String fieldNameInThisModel;

  /// The original name of the table that references this model.
  /// e.g., for AuthorModel's `books` list, this would be "books" (the table name of BookModel).
  final String referencingTableOriginalName;

  /// The name of the foreign key column in the `referencingTableOriginalName`
  /// that points back to this model's table.
  /// e.g., for AuthorModel's `books` list, this would be "author_id" from the "books" table.
  final String foreignKeyColumnInReferencingTable;

  ModelReverseRelationInfo({
    required this.fieldNameInThisModel,
    required this.referencingTableOriginalName,
    required this.foreignKeyColumnInReferencingTable,
  });

  Map<String, dynamic> toJson() => {
    'fieldNameInThisModel': fieldNameInThisModel,
    'referencingTableOriginalName': referencingTableOriginalName,
    'foreignKeyColumnInReferencingTable': foreignKeyColumnInReferencingTable,
  };

  factory ModelReverseRelationInfo.fromJson(Map<String, dynamic> json) {
    return ModelReverseRelationInfo(
      fieldNameInThisModel: json['fieldNameInThisModel'] as String,
      referencingTableOriginalName:
          json['referencingTableOriginalName'] as String,
      foreignKeyColumnInReferencingTable:
          json['foreignKeyColumnInReferencingTable'] as String,
    );
  }

  @override
  String toString() =>
      'ReverseRelation: $fieldNameInThisModel (from $referencingTableOriginalName via $foreignKeyColumnInReferencingTable)';
}

// Represents details about a database table, including its columns and constraints
class SupabaseTableInfo {
  final String name;
  final String originalName;
  final String localName; // Safe Dart class name for local use
  final String schema;
  final List<SupabaseColumnInfo> columns;
  final List<SupabaseForeignKeyConstraint> foreignKeys;
  final List<SupabaseIndexInfo> indexes;
  final String? comment;
  final List<ModelReverseRelationInfo> reverseRelations; // <<< ADDED FIELD

  SupabaseTableInfo({
    required this.name,
    required this.originalName,
    String? localName,
    required this.schema,
    required this.columns,
    required this.foreignKeys,
    required this.indexes,
    this.comment,
    this.reverseRelations = const [], // <<< ADDED TO CONSTRUCTOR with default
  }) : localName = localName ?? _makeSafeDartClassName(originalName) {
    _setJoinTableNames();
  }

  // Helper function to make a safe Dart class name
  static String _makeSafeDartClassName(String name) {
    // Check if the name conflicts with a built-in Dart type
    // If so, append 'Table' suffix
    return _dartBuiltInTypes.contains(name) ? '${name}Table' : name;
  }

  /// Sets the `joinTableName` for foreign keys if the table is a join table.
  void _setJoinTableNames() {
    // A table is considered a join table if it has exactly two foreign keys
    if (foreignKeys.length == 2) {
      for (final fk in foreignKeys) {
        fk.joinTableName = originalName; // Set the join table name
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'originalName': originalName,
    'localName': localName,
    'schema': schema,
    'columns': columns.map((c) => c.toJson()).toList(),
    'foreignKeys': foreignKeys.map((fk) => fk.toJson()).toList(),
    'indexes': indexes.map((idx) => idx.toJson()).toList(),
    'comment': comment,
    'reverseRelations':
        reverseRelations
            .map((rr) => rr.toJson())
            .toList(), // <<< ADDED TO toJson
  };

  factory SupabaseTableInfo.fromJson(Map<String, dynamic> json) {
    final originalName =
        json['originalName'] as String? ?? json['name'] as String? ?? '';
    return SupabaseTableInfo(
      name: json['name'] as String? ?? '',
      originalName: originalName,
      localName:
          json['localName'] as String? ?? _makeSafeDartClassName(originalName),
      schema: json['schema'] as String? ?? '',
      columns:
          (json['columns'] as List?)
              ?.map(
                (c) => SupabaseColumnInfo.fromJson(c as Map<String, dynamic>),
              )
              .toList() ??
          [],
      foreignKeys:
          (json['foreignKeys'] as List?)
              ?.map(
                (fk) => SupabaseForeignKeyConstraint.fromJson(
                  fk as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      indexes:
          (json['indexes'] as List?)
              ?.map(
                (idx) =>
                    SupabaseIndexInfo.fromJson(idx as Map<String, dynamic>),
              )
              .toList() ??
          [],
      comment: json['comment'] as String?,
      reverseRelations:
          (json['reverseRelations'] as List?) // <<< ADDED TO fromJson
              ?.map(
                (rr) => ModelReverseRelationInfo.fromJson(
                  rr as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );
  }

  String get uniqueKey => '$schema.$originalName';

  /// Returns a map of sanitized keys for all foreign key relationships.
  /// The key is the sanitized key, and the value is the foreign key constraint.
  Map<String, SupabaseForeignKeyConstraint> sanitizedKeys(
    List<String> endings,
  ) {
    final Map<String, SupabaseForeignKeyConstraint> keys = {};
    for (final fk in foreignKeys) {
      keys[fk.sanitizedKey(endings)] = fk;
    }
    return keys;
  }

  // ... (getters like primaryKeys, getForeignKeysForColumn remain the same) ...
  List<SupabaseColumnInfo> get primaryKeys =>
      columns.where((col) => col.isPrimaryKey).toList();

  List<SupabaseForeignKeyConstraint> getForeignKeysForColumn(
    String columnName,
  ) {
    return foreignKeys.where((fk) => fk.columns.contains(columnName)).toList();
  }

  SupabaseForeignKeyConstraint? getForeignKeyByName(String constraintName) {
    return foreignKeys.firstWhereOrNull(
      (fk) => fk.constraintName == constraintName,
    );
  }

  @override
  String toString() =>
      'Table $schema.$name (${columns.length} cols, ${foreignKeys.length} FKs, ${indexes.length} Idxs, ${reverseRelations.length} RevRels)${comment != null ? ' Comment: "$comment"' : ''}';
}

// --- Add this helper function (can be top-level or static private) ---

/// Parses a PostgreSQL text array representation (e.g., `{"col1","col2"}`) into a List<String>.
/// Handles basic cases, assumes column names don't contain commas, quotes, or braces.
List<String> _parsePgTextArray(String? arrayText) {
  if (arrayText == null ||
      arrayText.length < 2 ||
      !arrayText.startsWith('{') ||
      !arrayText.endsWith('}')) {
    return <String>[]; // Return empty list for null, empty, or invalid format
  }
  // Remove braces
  final content = arrayText.substring(1, arrayText.length - 1);
  if (content.isEmpty) {
    return <String>[]; // Handle empty array "{}"
  }
  // Split by comma and trim whitespace (basic parsing)
  // This assumes simple column names without quotes or escaped commas.
  return content.split(',').map((s) => s.trim()).toList();
}
