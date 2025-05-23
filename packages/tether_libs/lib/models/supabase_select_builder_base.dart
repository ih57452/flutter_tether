import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:tether_libs/schema/table_info.dart';
import '../client_manager/client_manager_models.dart';

// The generator will add the correct import to the generated
// supabase_select_builders.dart file.
// For SupabaseSelectBuilderBase itself, if it needs to run independently
// or in tests without full generation, this import might be tricky.
// However, since it's an abstract class used by generated code,
// the generated code will have the correct context.
// We assume `globalSupabaseSchema` will be accessible in the context
// where SupabaseSelectBuilderBase's constructor is called (i.e., from generated builders).

class RelatedBuilderLink {
  final SupabaseSelectBuilderBase builder;
  final String
  fkConstraintName; // The FK constraint name that establishes this link

  RelatedBuilderLink({required this.builder, required this.fkConstraintName});
}

/// Interface for column enums in generated Supabase builders
abstract class SupabaseColumn {
  /// The original column name in the database
  abstract final String originalName;

  /// The name used for the field in the Dart model (e.g., 'dateCreated').
  abstract final String localName;

  /// The name of the table this column belongs to.
  abstract final String tableName;

  /// An optional prefix used when this column is referenced through a relationship.
  abstract final String? relationshipPrefix;

  /// The database column name (alias for originalName).
  String get dbName;

  /// The Dart field name (alias for localName).
  String get dartName;

  /// The column name qualified with its base table name (e.g., 'users.id').
  String get qualified => '$tableName.$originalName';

  /// The fully qualified column name, potentially including a relationship prefix
  /// (e.g., 'user.id' or just 'id' if not related). Used in filters.
  String get fullyQualified =>
      relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  /// Creates a related column reference.
  SupabaseColumn related(String relationshipName);
}

/// Base class for Supabase/SQLite select builders. Provides common functionality.
abstract class SupabaseSelectBuilderBase {
  final Logger _logger = Logger('SupabaseSelectBuilderBase');
  final String
  primaryTableKey; // Can be derived from currentTableInfo.uniqueKey if preferred
  final SupabaseTableInfo currentTableInfo;

  // Stores related builders, keyed by the desired JSON key for the output
  final Map<String, RelatedBuilderLink> supabaseRelatedBuilders = {};

  final Set<String> selectedPrimaryColumns = {};
  bool selectAllPrimary = false;

  // Constructor now accepts SupabaseTableInfo directly
  SupabaseSelectBuilderBase({
    required this.primaryTableKey, // Or remove if deriving from currentTableInfo
    required this.currentTableInfo,
  }) {
    // Optional: Validate if primaryTableKey matches currentTableInfo.uniqueKey
    if (primaryTableKey != currentTableInfo.uniqueKey) {
      _logger.warning(
        "SupabaseSelectBuilderBase initialized with primaryTableKey '$primaryTableKey' that does not match currentTableInfo.uniqueKey '${currentTableInfo.uniqueKey}'. This might indicate an issue.",
      );
    }
  }

  // Getter for the original primary table name if needed elsewhere
  String get primaryTableName => currentTableInfo.originalName;

  T selectAll<T extends SupabaseSelectBuilderBase>() {
    selectAllPrimary = true;
    selectedPrimaryColumns.clear();
    return this as T;
  }

  T selectSupabaseColumns<T extends SupabaseSelectBuilderBase>(
    List<String> dbColumnNames,
  ) {
    selectedPrimaryColumns.clear();
    selectedPrimaryColumns.addAll(dbColumnNames);
    selectAllPrimary = false;
    return this as T;
  }

  // Modified addSupabaseRelated
  void addSupabaseRelated({
    required String
    jsonKey, // The key for this nested object/array in the parent JSON, e.g., "author", "books"
    required String
    fkConstraintName, // The name of the FK constraint that establishes this link
    required SupabaseSelectBuilderBase nestedBuilder,
  }) {
    if (supabaseRelatedBuilders.containsKey(jsonKey)) {
      _logger.warning(
        'Relationship for JSON key "$jsonKey" already configured for "$primaryTableName". Overwriting.',
      );
    }
    supabaseRelatedBuilders[jsonKey] = RelatedBuilderLink(
      builder: nestedBuilder,
      fkConstraintName: fkConstraintName,
    );
  }

  /// Builds the Supabase-specific select string.
  /// This needs careful review if it's intended to produce Supabase-compatible select strings,
  /// as its logic for handling related selectors is now different.
  String buildSupabase() {
    final List<String> parts = [];
    if (selectAllPrimary) {
      parts.add('*');
    } else if (selectedPrimaryColumns.isNotEmpty) {
      parts.addAll(selectedPrimaryColumns);
    } else {
      // PostgREST requires at least one column or '*' from the primary table
      // if you are embedding related resources.
      parts.add('*');
    }

    // Group related builders by their target table name to detect
    // if PostgREST needs disambiguation for the relationship_specifier part.
    final Map<String, List<MapEntry<String, RelatedBuilderLink>>>
    groupedByTargetTableForDisambiguation = {};

    for (final entry in supabaseRelatedBuilders.entries) {
      final targetTableName = entry.value.builder.currentTableInfo.originalName;
      (groupedByTargetTableForDisambiguation[targetTableName] ??= []).add(
        entry,
      );
    }

    // Now, iterate through the original supabaseRelatedBuilders to maintain order
    // and use the jsonKey as the alias.
    supabaseRelatedBuilders.forEach((jsonKey, relatedLink) {
      final targetTableName = relatedLink.builder.currentTableInfo.originalName;
      final fkConstraintName = relatedLink.fkConstraintName;
      final nestedSelect = relatedLink.builder.buildSupabase();

      String relationshipSpecifier = '$targetTableName!$fkConstraintName';

      // Format: jsonKey:relationship_specifier(nested_select)
      parts.add('$jsonKey:$relationshipSpecifier($nestedSelect)');
    });

    return parts.join(',');
  }

  /// Builds a SELECT SQL statement that returns a list of JSON objects
  /// with all the nested data from the related tables.
  SqlStatement buildSelectWithNestedData() {
    final mainTableAlias =
        't'; // Alias for the primary table of *this* builder instance

    final String topLevelJsonString = _buildRecursiveJson(mainTableAlias);

    return SqlStatement(
      operationType: SqlOperationType.select,
      tableName: primaryTableName,
      selectColumns: '$topLevelJsonString AS jsobjects',
      fromAlias: mainTableAlias,
      // WHERE, ORDER BY, LIMIT, OFFSET would be added by other builder methods
    );
  }

  // Helper method to recursively build the JSON string for this builder and its relations
  String _buildRecursiveJson(String tableAlias) {
    final List<String> jsonFields = [];

    // 1. Add direct columns of this builder's table
    List<SupabaseColumnInfo> columnsForThisLevelJson;
    if (selectAllPrimary) {
      columnsForThisLevelJson = currentTableInfo.columns;
    } else if (selectedPrimaryColumns.isNotEmpty) {
      columnsForThisLevelJson =
          currentTableInfo.columns
              .where((col) => selectedPrimaryColumns.contains(col.originalName))
              .toList();
      if (columnsForThisLevelJson.length != selectedPrimaryColumns.length) {
        final missing = selectedPrimaryColumns.where(
          (selCol) =>
              !columnsForThisLevelJson.any((ci) => ci.originalName == selCol),
        ); // Corrected whereNot
        _logger.warning(
          "Some selected primary columns were not found in table info for '${currentTableInfo.originalName}': ${missing.join(', ')}",
        );
      }
    } else {
      columnsForThisLevelJson = currentTableInfo.primaryKeys;
      if (columnsForThisLevelJson.isEmpty &&
          currentTableInfo.columns.isNotEmpty) {
        _logger.info(
          "No columns explicitly selected and no primary keys found for '${currentTableInfo.originalName}'. Defaulting to all columns for its JSON object.",
        );
        columnsForThisLevelJson = currentTableInfo.columns;
      } else if (columnsForThisLevelJson.isEmpty &&
          currentTableInfo.columns.isEmpty) {
        _logger.warning(
          "Table '${currentTableInfo.originalName}' (alias $tableAlias) has no columns to select for JSON object part.",
        );
        return "json_object('__error__', 'no columns for ${currentTableInfo.originalName}')"; // Return valid JSON error object
      }
    }

    if (columnsForThisLevelJson.isEmpty && supabaseRelatedBuilders.isEmpty) {
      _logger.warning(
        "Building JSON for '${currentTableInfo.originalName}' (alias $tableAlias) with no fields or relations. Will result in an empty JSON object if no PKs.",
      );
      // If truly empty, json_object() is invalid. Ensure at least one dummy field or handle upstream.
      // For now, if columnsForThisLevelJson is empty, it means no direct fields.
      // If supabaseRelatedBuilders is also empty, then jsonFields will be empty.
    }

    for (final column in columnsForThisLevelJson) {
      jsonFields.add("'${column.originalName}'");
      // Ensure the column name is quoted in the SQL
      jsonFields.add(
        "$tableAlias.\"${column.originalName}\"",
      ); // Corrected line
    }

    // 2. Process related builders for nested JSON
    supabaseRelatedBuilders.forEach((jsonKeyForOutput, relatedLink) {
      final nestedBuilder = relatedLink.builder;
      final fkConstraintNameToUse = relatedLink.fkConstraintName;
      final relatedTableInfo =
          nestedBuilder.currentTableInfo; // Schema of the related table

      SupabaseForeignKeyConstraint? fkConstraint;
      bool isForwardRelationship = true; // FK on current table -> related table
      String localJoinColumnOnThisLevel =
          ""; // Join column on 'tableAlias' (current level's table)
      String relatedTableJoinColumn = ""; // Join column on the related table

      // Alias for the related table in the subquery
      // Using a simple scheme, ensure it's distinct if multiple relations to the same table type exist.
      // For now, a simple alias based on related table name.
      String subQueryRelatedTableAlias =
          relatedTableInfo.originalName
              .substring(
                0,
                (relatedTableInfo.originalName.length > 3
                    ? 3
                    : relatedTableInfo.originalName.length),
              )
              .toLowerCase() +
          "Rel";

      // Attempt to find FK on currentTableInfo (this.currentTableInfo) that references relatedTableInfo
      fkConstraint = this.currentTableInfo.foreignKeys.firstWhereOrNull(
        (fk) =>
            fk.constraintName == fkConstraintNameToUse &&
            fk.originalForeignTableName == relatedTableInfo.originalName,
      );

      if (fkConstraint != null) {
        isForwardRelationship = true;
        localJoinColumnOnThisLevel = fkConstraint.originalColumns.first;
        relatedTableJoinColumn = fkConstraint.originalForeignColumns.first;
      } else {
        // If not found, attempt to find FK on relatedTableInfo that references this.currentTableInfo
        fkConstraint = relatedTableInfo.foreignKeys.firstWhereOrNull(
          (fk) =>
              fk.constraintName == fkConstraintNameToUse &&
              fk.originalForeignTableName == this.currentTableInfo.originalName,
        );

        if (fkConstraint != null) {
          isForwardRelationship = false;
          if (this.currentTableInfo.primaryKeys.isEmpty) {
            _logger.severe(
              "Cannot form reverse relationship for '$jsonKeyForOutput': Primary table '${this.currentTableInfo.originalName}' has no primary keys defined.",
            );
            return; // Skip this relation
          }
          localJoinColumnOnThisLevel =
              this
                  .currentTableInfo
                  .primaryKeys
                  .first
                  .originalName; // PK on current table
          relatedTableJoinColumn =
              fkConstraint.originalColumns.first; // FK column on related table
        }
      }

      if (fkConstraint == null) {
        _logger.warning(
          "Could not resolve FK constraint '$fkConstraintNameToUse' for relationship '$jsonKeyForOutput' between '${this.currentTableInfo.originalName}' and '${relatedTableInfo.originalName}'. Skipping.",
        );
        return; // Skip this relation
      }

      // Recursively get the JSON object string for the nested builder
      final String nestedJsonBody = nestedBuilder._buildRecursiveJson(
        subQueryRelatedTableAlias,
      );

      String subQuerySql;
      if (isForwardRelationship) {
        // Many-to-One or One-to-One
        subQuerySql = """
          (SELECT $nestedJsonBody
           FROM ${relatedTableInfo.originalName} AS $subQueryRelatedTableAlias
           WHERE $subQueryRelatedTableAlias.$relatedTableJoinColumn = $tableAlias.$localJoinColumnOnThisLevel
           LIMIT 1)
        """;
      } else {
        // One-to-Many
        subQuerySql = """
          (SELECT json_group_array($nestedJsonBody)
           FROM ${relatedTableInfo.originalName} AS $subQueryRelatedTableAlias
           WHERE $subQueryRelatedTableAlias.$relatedTableJoinColumn = $tableAlias.$localJoinColumnOnThisLevel)
        """;
      }
      jsonFields.add("'$jsonKeyForOutput'");
      jsonFields.add(subQuerySql);
    });

    if (jsonFields.isEmpty) {
      // If after all processing, jsonFields is empty, json_object() is invalid.
      // This can happen if a table has no columns selected and no relations.
      // Return a valid JSON representation of an empty object.
      return "json_object()"; // SQLite handles json_object() as an empty object {}
    }

    return "json_object(${jsonFields.join(', ')})";
  }
}

class RelatedColumnRef implements SupabaseColumn {
  @override
  final String originalName;
  @override
  final String localName;
  @override
  final String tableName;
  @override
  final String? relationshipPrefix;

  const RelatedColumnRef(
    this.originalName,
    this.localName,
    this.tableName,
    this.relationshipPrefix,
  );

  @override
  String get dbName => originalName;

  @override
  String get dartName => localName;

  @override
  String get qualified => '$tableName.$originalName';

  @override
  String get fullyQualified =>
      relationshipPrefix != null ? '$relationshipPrefix.$dbName' : dbName;

  @override
  SupabaseColumn related(String relationshipName) {
    return RelatedColumnRef(
      originalName,
      localName,
      tableName,
      relationshipName,
    );
  }
}
