import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/models/supabase_select_builder_base.dart';
import 'package:tether_libs/models/tether_model.dart';
import 'client_manager_models.dart';
import 'client_manager_transform_builder.dart';

class ClientManagerFilterBuilder<TModel extends TetherModel<TModel>>
    extends ClientManagerTransformBuilder<TModel> {
  @override
  final PostgrestFilterBuilder<dynamic> supabase;

  // Assuming _logger is inherited or defined in ClientManagerBase
  // If not, add: final Logger _logger = Logger('ClientManagerFilterBuilder');

  final Logger _logger;

  ClientManagerFilterBuilder({
    required super.tableName,
    required super.localDb,
    required super.client,
    required this.supabase,
    required super.localTableName,
    required super.tableSchemas,
    required super.fromJsonFactory,
    required super.fromSqliteFactory,
    super.type,
    super.selector,
    // --- Pass SqlStatement to super ---
    required super.localQuery, // Renamed in base class, adjust if needed
    super.selectorStatement,
  }) : _logger = Logger('filter_builder'),
       super(supabase: supabase);

  // Helper to create a new instance with updated state (immutable approach)
  ClientManagerFilterBuilder<TModel> _copyWithFilter({
    PostgrestFilterBuilder<dynamic>? supabaseBuilder,
    // --- MODIFIED: Accept updated SqlStatement ---
    SqlStatement? localQuery, // Renamed in base class, adjust if needed
  }) {
    return ClientManagerFilterBuilder(
      tableName: tableName,
      localTableName: localTableName,
      localDb: localDb,
      client: client,
      supabase: supabaseBuilder ?? this.supabase,
      type: type,
      selector: selector,
      selectorStatement: selectorStatement,
      fromJsonFactory: fromJsonFactory,
      fromSqliteFactory: fromSqliteFactory,
      tableSchemas: tableSchemas,
      // --- Pass updated state ---
      localQuery:
          localQuery ??
          this.localQuery, // Renamed in base class, adjust if needed
    );
  }

  // --- Filter Implementations using ClientManagerSqlUtils.applyWhere ---

  /// Finds all rows whose value on the stated [column] matches the specified [value].
  ClientManagerFilterBuilder<TModel> eq(TetherColumn column, Object value) {
    final newSupabaseBuilder = supabase.eq(column.fullyQualified, value);
    SqlStatement? newlocalQuery = localQuery; // Use correct field name
    // Check if localQuery is not null before applying WHERE
    // Note: If localQuery is required in constructor, this check might be redundant
    // but added as requested for safety.
    if (localQuery != null) {
      final clause = '${column.dbName} = ?';
      final args = [value];
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning(
        "Cannot apply 'eq' filter: localQuery is null.",
      ); // Use inherited logger
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose value on the stated [column] does not match the specified [value].
  ClientManagerFilterBuilder<TModel> neq(TetherColumn column, Object value) {
    final newSupabaseBuilder = supabase.neq(column.fullyQualified, value);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      final clause = '${column.dbName} != ?'; // Or <>
      final args = [value];
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'neq' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose value on the stated [column] is greater than the specified [value].
  ClientManagerFilterBuilder<TModel> gt(TetherColumn column, Object value) {
    final newSupabaseBuilder = supabase.gt(column.fullyQualified, value);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      final clause = '${column.dbName} > ?';
      final args = [value];
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'gt' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose value on the stated [column] is greater than or equal to the specified [value].
  ClientManagerFilterBuilder<TModel> gte(TetherColumn column, Object value) {
    final newSupabaseBuilder = supabase.gte(column.fullyQualified, value);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      final clause = '${column.dbName} >= ?';
      final args = [value];
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'gte' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose value on the stated [column] is less than the specified [value].
  ClientManagerFilterBuilder<TModel> lt(TetherColumn column, Object value) {
    final newSupabaseBuilder = supabase.lt(column.fullyQualified, value);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      final clause = '${column.dbName} < ?';
      final args = [value];
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'lt' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose value on the stated [column] is less than or equal to the specified [value].
  ClientManagerFilterBuilder<TModel> lte(TetherColumn column, Object value) {
    final newSupabaseBuilder = supabase.lte(column.fullyQualified, value);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      final clause = '${column.dbName} <= ?';
      final args = [value];
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'lte' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose value in the stated [column] matches the supplied [pattern].
  ClientManagerFilterBuilder<TModel> like(TetherColumn column, String pattern) {
    final newSupabaseBuilder = supabase.like(column.fullyQualified, pattern);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      final clause = '${column.dbName} LIKE ?';
      final args = [pattern];
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'like' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose value in the stated [column] matches the supplied [pattern] case-insensitively.
  ClientManagerFilterBuilder<TModel> ilike(
    TetherColumn column,
    String pattern,
  ) {
    final newSupabaseBuilder = supabase.ilike(column.fullyQualified, pattern);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      // SQLite LIKE is typically case-insensitive by default
      final clause = '${column.dbName} LIKE ?';
      final args = [pattern];
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'ilike' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// A check for exact equality (null, true, false).
  ClientManagerFilterBuilder<TModel> isFilter(
    TetherColumn column,
    bool? value,
  ) {
    final newSupabaseBuilder = supabase.isFilter(column.fullyQualified, value);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      String clause;
      List<Object?> args;
      if (value == null) {
        clause = '${column.dbName} IS NULL';
        args = [];
      } else {
        // SQLite stores booleans as 0 (false) or 1 (true)
        clause = '${column.dbName} = ?';
        args = [value ? 1 : 0];
      }
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'is' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose value on the stated [column] is found on the specified [values].
  ClientManagerFilterBuilder<TModel> inFilter(
    TetherColumn column,
    List values,
  ) {
    final newSupabaseBuilder = supabase.inFilter(column.fullyQualified, values);
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      String clause;
      List<Object?> args;
      if (values.isEmpty) {
        // Handle empty list case to avoid invalid SQL "IN ()" -> match nothing
        clause = '1 = 0'; // Always false
        args = [];
      } else {
        final placeholders = List.filled(values.length, '?').join(', ');
        clause = '${column.dbName} IN ($placeholders)';
        args = values;
      }
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'in' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  // --- Array/JSON/Range Filters (Basic Implementations/Placeholders) ---

  /// Finds all rows whose json/text value on the stated [column] contains the specified [value].
  ClientManagerFilterBuilder<TModel> contains(
    TetherColumn column,
    Object value,
  ) {
    final newSupabaseBuilder = supabase.contains(column.fullyQualified, value);
    SqlStatement? newlocalQuery = localQuery; // Start with current state
    if (localQuery != null) {
      // Basic string contains using LIKE
      if (value is String) {
        final clause = "${column.dbName} LIKE ?";
        final args = ['%$value%'];
        newlocalQuery = ClientManagerSqlUtils.applyWhere(
          localQuery!,
          clause,
          args,
        );
      } else {
        // TODO: Implement proper JSON contains using json_extract or json_each
        _logger.warning(
          "SQLite 'contains' filter not fully implemented for non-string types in $localTableName.${column.dbName}.",
        );
      }
    } else {
      _logger.warning("Cannot apply 'contains' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose json/text value on the stated [column] is contained by the specified [value].
  ClientManagerFilterBuilder<TModel> containedBy(
    TetherColumn column,
    Object value,
  ) {
    final newSupabaseBuilder = supabase.containedBy(
      column.fullyQualified,
      value,
    );
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      // Basic string contained by using LIKE
      if (value is String) {
        final clause = "? LIKE '%' || ${column.dbName} || '%'";
        final args = [value];
        newlocalQuery = ClientManagerSqlUtils.applyWhere(
          localQuery!,
          clause,
          args,
        );
      } else {
        // TODO: Implement proper JSON containedBy
        _logger.warning(
          "SQLite 'containedBy' filter not fully implemented for non-string types in $localTableName.${column.dbName}.",
        );
      }
    } else {
      _logger.warning("Cannot apply 'containedBy' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  // --- Range Filters (Not directly supported in SQLite standard SQL) ---
  // These would require specific schema (e.g., start/end columns) or extensions

  ClientManagerFilterBuilder<TModel> rangeLt(
    TetherColumn column,
    String range,
  ) {
    final newSupabaseBuilder = supabase.rangeLt(column.fullyQualified, range);
    _logger.warning(
      "SQLite 'rangeLt' filter not implemented for $localTableName.${column.dbName}.",
    );
    // No change to localQuery
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: localQuery,
    );
  }

  ClientManagerFilterBuilder<TModel> rangeGt(
    TetherColumn column,
    String range,
  ) {
    final newSupabaseBuilder = supabase.rangeGt(column.fullyQualified, range);
    _logger.warning(
      "SQLite 'rangeGt' filter not implemented for $localTableName.${column.dbName}.",
    );
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: localQuery,
    );
  }

  ClientManagerFilterBuilder<TModel> rangeGte(
    TetherColumn column,
    String range,
  ) {
    final newSupabaseBuilder = supabase.rangeGte(column.fullyQualified, range);
    _logger.warning(
      "SQLite 'rangeGte' filter not implemented for $localTableName.${column.dbName}.",
    );
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: localQuery,
    );
  }

  ClientManagerFilterBuilder<TModel> rangeLte(
    TetherColumn column,
    String range,
  ) {
    final newSupabaseBuilder = supabase.rangeLte(column.fullyQualified, range);
    _logger.warning(
      "SQLite 'rangeLte' filter not implemented for $localTableName.${column.dbName}.",
    );
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: localQuery,
    );
  }

  ClientManagerFilterBuilder<TModel> rangeAdjacent(
    TetherColumn column,
    String range,
  ) {
    final newSupabaseBuilder = supabase.rangeAdjacent(
      column.fullyQualified,
      range,
    );
    _logger.warning(
      "SQLite 'rangeAdjacent' filter not implemented for $localTableName.${column.dbName}.",
    );
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: localQuery,
    );
  }

  /// Finds all rows whose array/range value overlaps. Basic string implementation.
  ClientManagerFilterBuilder<TModel> overlaps(
    TetherColumn column,
    Object value,
  ) {
    final newSupabaseBuilder = supabase.overlaps(column.fullyQualified, value);
    // TODO: Implement proper array/range overlap for SQLite (complex)
    _logger.warning(
      "SQLite 'overlaps' filter not implemented for $localTableName.${column.dbName}.",
    );
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: localQuery,
    );
  }

  // --- Full Text Search ---

  /// Finds all rows matching the FTS query. Requires an FTS table (e.g., FTS5).
  ClientManagerFilterBuilder<TModel> textSearch(
    TetherColumn column,
    String query, {
    String? config, // config is PostgreSQL specific, ignored for SQLite
    TextSearchType? type, // type is PostgreSQL specific, ignored for SQLite
  }) {
    final newSupabaseBuilder = supabase.textSearch(
      column.fullyQualified,
      query,
      config: config,
      type: type,
    );
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      // Assumes the local table is an FTS table (e.g., FTS5) and the column is indexed.
      // The column name in MATCH might be the table name itself for FTS5. Check your FTS setup.
      // Using column.dbName assumes the column *is* the FTS indexed column.
      final clause = '${column.dbName} MATCH ?';
      final args = [query]; // Use the FTS query string directly
      newlocalQuery = ClientManagerSqlUtils.applyWhere(
        localQuery!,
        clause,
        args,
      );
    } else {
      _logger.warning("Cannot apply 'textSearch' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  // --- Logical Operators ---

  /// Finds all rows which doesn't satisfy the filter.
  /// NOTE: This implementation is basic and might require parentheses management for complex cases.
  ClientManagerFilterBuilder<TModel> not(
    TetherColumn column,
    String operator,
    Object? value,
  ) {
    final newSupabaseBuilder = supabase.not(
      column.fullyQualified,
      operator,
      value,
    );
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      _logger.warning(
        "SQLite 'not' filter implementation is basic and may require manual parentheses for complex cases.",
      );
      // Apply the inner filter first to get its state
      final filterResult = filter(
        column,
        operator,
        value,
      ); // This applies the filter to the *current* state

      // Check if the inner filter actually modified the state (applied a clause)
      if (filterResult.localQuery != localQuery &&
          filterResult.localQuery!.whereClauses.isNotEmpty) {
        final lastClause = filterResult.localQuery!.whereClauses.last;
        // Create new list without the last clause
        final modifiedClauses = List<String>.from(
          filterResult.localQuery!.whereClauses.sublist(
            0,
            filterResult.localQuery!.whereClauses.length - 1,
          ),
        );
        // Add the negated clause
        modifiedClauses.add('NOT ($lastClause)');

        // Use the state produced by the inner filter call, but with the modified clauses
        newlocalQuery = filterResult.localQuery!.copyWith(
          whereClauses: modifiedClauses,
        );
      } else {
        _logger.warning(
          "'not' filter could not negate previous condition for $localTableName.${column.dbName}.",
        );
        // If filter() didn't apply anything, 'not' can't either. Keep state as is.
        newlocalQuery = filterResult.localQuery;
      }
    } else {
      _logger.warning("Cannot apply 'not' filter: localQuery is null.");
    }
    // Supabase builder was already updated by supabase.not()
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows satisfying at least one of the filters.
  /// NOTE: SQLite implementation requires parsing the filter string or a different API.
  ClientManagerFilterBuilder<TModel> or(
    String filters, {
    String? referencedTable,
  }) {
    final newSupabaseBuilder = supabase.or(
      filters,
      referencedTable: referencedTable,
    );
    // TODO: Implement SQLite 'or'. Requires parsing the 'filters' string
    // or changing the API to accept multiple conditions programmatically.
    _logger.warning(
      "SQLite 'or' filter not implemented. Filter string: '$filters'",
    );
    // No change to localQuery
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: localQuery,
    );
  }

  // --- Generic Filters ---

  /// Finds all rows whose [column] satisfies the filter. Maps PostgREST operators.
  ClientManagerFilterBuilder<TModel> filter(
    TetherColumn column,
    String operator,
    Object? value,
  ) {
    final newSupabaseBuilder = supabase.filter(
      column.fullyQualified,
      operator,
      value,
    );

    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      // Map PostgREST operators to SQLite
      String? clause;
      List<Object?>? args;
      bool applied = false; // Flag if mapping was successful

      switch (operator.toLowerCase()) {
        case 'eq':
          clause = '${column.dbName} = ?';
          args = [value];
          applied = true;
          break;
        case 'neq':
          clause = '${column.dbName} != ?';
          args = [value];
          applied = true;
          break;
        case 'gt':
          clause = '${column.dbName} > ?';
          args = [value];
          applied = true;
          break;
        case 'gte':
          clause = '${column.dbName} >= ?';
          args = [value];
          applied = true;
          break;
        case 'lt':
          clause = '${column.dbName} < ?';
          args = [value];
          applied = true;
          break;
        case 'lte':
          clause = '${column.dbName} <= ?';
          args = [value];
          applied = true;
          break;
        case 'like':
          clause = '${column.dbName} LIKE ?';
          args = [value];
          applied = true;
          break;
        case 'ilike': // SQLite LIKE is often case-insensitive
          clause = '${column.dbName} LIKE ?';
          args = [value];
          applied = true;
          break;
        case 'is':
          if (value == null) {
            clause = '${column.dbName} IS NULL';
            args = [];
            applied = true;
          } else if (value is bool) {
            clause = '${column.dbName} = ?';
            args = [value ? 1 : 0];
            applied = true;
          } else {
            _logger.warning(
              "SQLite 'is' filter only supports null, true, false for $localTableName.${column.dbName}.",
            );
          }
          break;
        case 'in':
          if (value is List && value.isNotEmpty) {
            final placeholders = List.filled(value.length, '?').join(', ');
            clause = '${column.dbName} IN ($placeholders)';
            args = value;
            applied = true;
          } else if (value is List && value.isEmpty) {
            clause = '1 = 0'; // Always false for empty IN list
            args = [];
            applied = true;
          } else {
            _logger.warning(
              "SQLite 'in' filter requires a List value for $localTableName.${column.dbName}.",
            );
          }
          break;
        // Add other operators as needed (cs, cd, sl, sr, nxr, nxl, adj, ov, fts)
        case 'fts':
        case 'plfts':
        case 'phfts':
        case 'wfts':
          // Assumes FTS setup
          clause = '${column.dbName} MATCH ?';
          args = [value];
          applied = true;
          break;
        default:
          _logger.warning(
            "SQLite filter mapping not implemented for operator '$operator' on $localTableName.${column.dbName}.",
          );
      }

      if (applied && clause != null) {
        newlocalQuery = ClientManagerSqlUtils.applyWhere(
          localQuery!,
          clause,
          args,
        );
      }
    } else {
      _logger.warning("Cannot apply 'filter' ($operator): localQuery is null.");
    }

    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Finds all rows whose columns match the specified [query] object (equality).
  ClientManagerFilterBuilder<TModel> match(Map<String, Object> query) {
    // Supabase builder requires simple keys, handle qualification manually for local
    final newSupabaseBuilder = supabase.match(query);

    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      if (query.isNotEmpty) {
        final clauses = <String>[];
        final args = <Object?>[];
        query.forEach((key, value) {
          // Assuming 'key' is the direct column name for local query
          clauses.add('$key = ?');
          args.add(value);
        });
        // Apply all match conditions as a single ANDed clause group
        final combinedClause = '(${clauses.join(' AND ')})';
        newlocalQuery = ClientManagerSqlUtils.applyWhere(
          localQuery!,
          combinedClause,
          args,
        );
      }
      // If query is empty, no change to local state
    } else {
      _logger.warning("Cannot apply 'match' filter: localQuery is null.");
    }

    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  // --- Multi-pattern LIKE/ILIKE ---
  // Helper for LIKE/ILIKE Any/All
  SqlStatement _buildLikeAnyAllLocal(
    SqlStatement currentState,
    TetherColumn column,
    List<String> patterns,
    String joinOperator,
  ) {
    // No null check needed for currentState here, as it's called internally after check
    if (patterns.isEmpty) {
      _logger.warning(
        "LIKE Any/All called with empty patterns list for $localTableName.${column.dbName}.",
      );
      // Return condition that matches nothing if AND, everything if OR?
      // For simplicity, let's add a clause that's always false for AND, true for OR.
      final clause = joinOperator == 'AND' ? '1 = 0' : '1 = 1';
      return ClientManagerSqlUtils.applyWhere(currentState, clause);
    }
    final clauses = patterns.map((_) => '${column.dbName} LIKE ?').toList();
    final combinedClause = '(${clauses.join(' $joinOperator ')})';
    final args = patterns;
    return ClientManagerSqlUtils.applyWhere(currentState, combinedClause, args);
  }

  /// Match only rows where [column] matches all of [patterns] case-sensitively.
  ClientManagerFilterBuilder<TModel> likeAllOf(
    TetherColumn column,
    List<String> patterns,
  ) {
    final newSupabaseBuilder = supabase.likeAllOf(
      column.fullyQualified,
      patterns,
    );
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      // Assumes default SQLite LIKE insensitivity, so same as ilikeAllOf
      newlocalQuery = _buildLikeAnyAllLocal(
        localQuery!,
        column,
        patterns,
        'AND',
      );
    } else {
      _logger.warning("Cannot apply 'likeAllOf' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Match only rows where [column] matches any of [patterns] case-sensitively.
  ClientManagerFilterBuilder<TModel> likeAnyOf(
    TetherColumn column,
    List<String> patterns,
  ) {
    final newSupabaseBuilder = supabase.likeAnyOf(
      column.fullyQualified,
      patterns,
    );
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      // Assumes default SQLite LIKE insensitivity, so same as ilikeAnyOf
      newlocalQuery = _buildLikeAnyAllLocal(
        localQuery!,
        column,
        patterns,
        'OR',
      );
    } else {
      _logger.warning("Cannot apply 'likeAnyOf' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Match only rows where [column] matches all of [patterns] case-insensitively.
  ClientManagerFilterBuilder<TModel> ilikeAllOf(
    TetherColumn column,
    List<String> patterns,
  ) {
    final newSupabaseBuilder = supabase.ilikeAllOf(
      column.fullyQualified,
      patterns,
    );
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      newlocalQuery = _buildLikeAnyAllLocal(
        localQuery!,
        column,
        patterns,
        'AND',
      );
    } else {
      _logger.warning("Cannot apply 'ilikeAllOf' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }

  /// Match only rows where [column] matches any of [patterns] case-insensitively.
  ClientManagerFilterBuilder<TModel> ilikeAnyOf(
    TetherColumn column,
    List<String> patterns,
  ) {
    final newSupabaseBuilder = supabase.ilikeAnyOf(
      column.fullyQualified,
      patterns,
    );
    SqlStatement? newlocalQuery = localQuery;
    if (localQuery != null) {
      newlocalQuery = _buildLikeAnyAllLocal(
        localQuery!,
        column,
        patterns,
        'OR',
      );
    } else {
      _logger.warning("Cannot apply 'ilikeAnyOf' filter: localQuery is null.");
    }
    return _copyWithFilter(
      supabaseBuilder: newSupabaseBuilder,
      localQuery: newlocalQuery,
    );
  }
}
