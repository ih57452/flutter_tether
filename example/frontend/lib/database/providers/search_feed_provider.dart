// GENERATED CODE - Consider if this file should be manually maintained or always generated.
// If generated, add appropriate DO NOT MODIFY BY HAND comments.

import 'dart:convert';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tether/utils/logger.dart';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:tether/client_manager/client_manager.dart';
import 'package:tether/client_manager/client_manager_filter_builder.dart';
import 'package:tether/client_manager/client_manager_models.dart';
import 'package:tether/schema/supabase_select_builder_base.dart';
import 'package:sqlite_async/sqlite_async.dart'; // Ensure SqliteDatabase is imported

import '../database.dart';
import '../managers/feed_item_reference_manager.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tether/schema/tether_model.dart';

typedef QueryBuilderFactory<TModel extends TetherModel<TModel>> =
    ClientManagerFilterBuilder<TModel> Function();

class SearchStreamNotifierSettings<TModel extends TetherModel<TModel>>
    extends Equatable {
  final String feedKey;
  final SupabaseColumn searchColumn;
  final int pageSize;
  // Store stable components needed to build the query
  final ClientManager<TModel> clientManager; // From a stable provider
  final SupabaseSelectBuilderBase
  selectArgs; // Stable (e.g., a constant or from a provider)
  final TModel Function(Map<String, dynamic> json)
  fromJsonFactory; // Stable (e.g., static method)
  // Optional: For additional dynamic filters not covered by search terms
  // This function itself needs a stable identity if used in props.
  final ClientManagerFilterBuilder<TModel> Function(
    ClientManagerFilterBuilder<TModel> baseQuery,
  )?
  queryCustomizer;

  const SearchStreamNotifierSettings({
    required this.feedKey,
    required this.searchColumn,
    required this.clientManager,
    required this.selectArgs,
    required this.fromJsonFactory,
    this.pageSize = 20,
    this.queryCustomizer,
  });

  QueryBuilderFactory<TModel> get queryBuilderFactory {
    return () {
      var q = clientManager.query().select(selectArgs);
      if (queryCustomizer != null) {
        q = queryCustomizer!(q);
      }
      return q;
    };
  }

  @override
  List<Object?> get props => [
    feedKey,
    searchColumn,
    pageSize,
    clientManager, // Relies on stable identity from its provider
    selectArgs, // Relies on stable identity (e.g., const)
    fromJsonFactory, // Static methods have stable identity
    queryCustomizer, // Needs stable identity if provided
  ];
}

class SearchStreamNotifier<TModel extends TetherModel<TModel>>
    extends
        FamilyStreamNotifier<
          List<TModel>,
          SearchStreamNotifierSettings<TModel>
        > {
  // Store the settings argument directly
  late SearchStreamNotifierSettings<TModel> _currentSettings;

  int currentPage = 0;
  String terms = '';
  bool _isDisposed = false; // Flag to track disposal

  final Logger _logger = Logger('SearchStreamNotifier'); // Class-level logger

  SearchStreamNotifier() {
    // No need to initialize from arg here, build will do it.
  }

  @override
  Stream<List<TModel>> build(SearchStreamNotifierSettings<TModel> arg) async* {
    _currentSettings = arg; // Store the current settings
    // Reset state for the new settings
    currentPage = 0;
    terms = '';
    _isDisposed = false; // Reset disposed flag

    ref.onDispose(() {
      _isDisposed = true;
    });

    // Use _currentSettings throughout
    final count = await _getCount();
    if (_isDisposed) return; // Check after await

    if (count == 0) {
      await refreshFeed(initialize: true);
    } else {
      await refreshFeed();
    }
    if (_isDisposed) return; // Check after await

    yield* feedStream;
  }

  Stream<List<TModel>> get feedStream async* {
    final appDatabase = ref.watch(databaseProvider).value!;

    // Cast the dynamic 'db' getter to its concrete type 'SqliteDatabase'.
    // This assumes this feedStream is intended for platforms where appDatabase.db is SqliteDatabase.
    // sqlite_async's SqliteDatabase provides the .watch method.
    final sqliteDb = appDatabase.db as SqliteDatabase;

    final modelSpecificQueryBuilder = _currentSettings.queryBuilderFactory();
    final modelTableName = modelSpecificQueryBuilder.tableName;

    final SupabaseSelectBuilderBase? selector =
        modelSpecificQueryBuilder.selectorStatement;

    if (selector == null) {
      _logger.severe(
        "SearchStreamNotifier: selectorStatement is null in feedStream for $modelTableName. This indicates a setup error.",
      );
      yield <TModel>[];
      return;
    }

    final SqlStatement jsonSelectSubQueryStatement =
        selector.buildSelectWithNestedData();
    // String baseJsonSelectSql = jsonSelectSubQueryStatement.build().sql; // We don't need the fully built string here anymore for the CASE
    // String internalAliasForJsonSelect = jsonSelectSubQueryStatement.fromAlias ?? modelTableName.substring(0, 1); // Use fromAlias directly from statement

    if (selector.currentTableInfo.primaryKeys.isEmpty) {
      _logger.severe(
        "SearchStreamNotifier: Table ${selector.currentTableInfo.originalName} has no primary keys defined. Cannot build feedStream SQL.",
      );
      yield <TModel>[];
      return;
    }
    final String modelPrimaryKeyCol =
        selector.currentTableInfo.primaryKeys.first.originalName;

    // Ensure fromAlias is not null, or provide a default, though it should be set by buildSelectWithNestedData
    final String aliasInSubQuery =
        jsonSelectSubQueryStatement.fromAlias ?? 't_fallback';
    if (jsonSelectSubQueryStatement.fromAlias == null) {
      _logger.warning(
        "jsonSelectSubQueryStatement.fromAlias was null for table $modelTableName, using fallback '$aliasInSubQuery'",
      );
    }

    final sql = '''
      SELECT
        fir.id AS feed_item_ref_id,
        fir.feed_key,
        fir.item_source_table,
        fir.item_source_id,
        fir.display_order,
        CASE
            WHEN fir.item_source_table = ? THEN (
                SELECT ${jsonSelectSubQueryStatement.selectColumns}
                FROM "${jsonSelectSubQueryStatement.tableName}" AS "$aliasInSubQuery"
                WHERE "$aliasInSubQuery"."$modelPrimaryKeyCol" = fir.item_source_id
            )
            ELSE NULL
        END AS item_json_data
      FROM
        feed_item_references fir
      WHERE
        fir.feed_key = ?
      ORDER BY
        fir.display_order ASC;
    ''';

    // Use the typed sqliteDb and provide an explicit type argument to .map()
    yield* sqliteDb.watch(sql, parameters: [modelTableName, _currentSettings.feedKey]).map<
      List<TModel>
    >((ResultSet rawData) {
      // Explicit type for map's T and rawData
      if (_isDisposed) return <TModel>[];
      return rawData
          .map((row) {
            final jsonData = row['item_json_data'];
            if (jsonData == null) return null;

            Map<String, dynamic> parsedJson;
            if (jsonData is String) {
              try {
                parsedJson = jsonDecode(jsonData) as Map<String, dynamic>;
              } catch (e) {
                _logger.warning(
                  'SearchStreamNotifier: JSONDecode error for item_json_data: $e, data: $jsonData',
                );
                return null;
              }
            } else if (jsonData is Map<String, dynamic>) {
              parsedJson = jsonData;
            } else {
              _logger.warning(
                'SearchStreamNotifier: Unexpected format for item_json_data: ${jsonData.runtimeType}',
              );
              return null;
            }
            try {
              return _currentSettings.fromJsonFactory(parsedJson);
            } catch (e) {
              _logger.severe(
                'SearchStreamNotifier: Error in fromJsonFactory for $modelTableName: $e, json: $parsedJson',
              );
              return null;
            }
          })
          .whereType<TModel>()
          .toList();
    });
  }

  Future<int> _getCount() async {
    // Access feedKey from _currentSettings
    final feedManager = ref.read(feedItemReferenceManagerProvider);
    return await feedManager.getCount(feedKey: _currentSettings.feedKey);
  }

  Future<void> refreshFeed({bool initialize = false}) async {
    try {
      // Access queryBuilder, searchColumn, terms, pageSize from _currentSettings or instance vars
      _logger.info(
        'refreshFeed called. initialize: $initialize, current terms: "$terms"',
      ); // Log terms

      final query = _currentSettings.queryBuilderFactory();

      final items = await _fetch(
        rangeStart: 0,
        rangeEnd: _currentSettings.pageSize - 1,
      );

      if (_isDisposed) return; // Check after await

      final feedManager = ref.read(feedItemReferenceManagerProvider);
      final feedKey = _currentSettings.feedKey; // Use from settings

      if (initialize) {
        await feedManager.clearFeed(feedKey: feedKey);
        if (_isDisposed) return;
        await feedManager.setFeedItems(
          feedKey: feedKey,
          items:
              items
                  .asMap()
                  .entries
                  .map(
                    (e) => FeedItemReference(
                      itemSourceTable: query.tableName,
                      itemSourceId: e.value.localId,
                      displayOrder: e.key,
                    ),
                  )
                  .toList(),
        );
      } else {
        await feedManager.addItemsToStart(
          feedKey: feedKey,
          newItemsToAdd:
              items
                  .asMap()
                  .entries
                  .map(
                    (e) => FeedItemReference(
                      itemSourceTable: query.tableName,
                      itemSourceId: e.value.localId,
                      displayOrder: e.key,
                    ),
                  )
                  .toList(),
        );
      }
      if (_isDisposed) return;
      currentPage = 0; // Reset current page
      // No direct state update here, build method yields from feedStream
    } catch (e, s) {
      if (!_isDisposed) {
        // Check before setting state
        state = AsyncValue.error(e, s);
      } else {
        print("SearchStreamNotifier: Error in refreshFeed but unmounted: $e");
      }
    }
  }

  Future<void> fetchMoreItems() async {
    final nextPage = currentPage + 1;
    try {
      final query = _currentSettings.queryBuilderFactory();
      final rangeStart = nextPage * _currentSettings.pageSize;
      final rangeEnd = ((nextPage + 1) * _currentSettings.pageSize) - 1;
      final newItems = await _fetch(rangeStart: rangeStart, rangeEnd: rangeEnd);

      if (_isDisposed) return; // Check after await

      if (newItems.isNotEmpty) {
        final feedManager = ref.read(feedItemReferenceManagerProvider);
        await feedManager.addItemsToEnd(
          feedKey: _currentSettings.feedKey,
          itemsToAdd:
              newItems
                  .map(
                    (item) => FeedItemReference(
                      itemSourceTable: query.tableName,
                      itemSourceId: item.localId,
                      displayOrder: currentPage * _currentSettings.pageSize,
                    ),
                  )
                  .toList(),
        );
        if (_isDisposed) return;
        currentPage = nextPage;
      }
      // No direct state update here
    } catch (e, s) {
      if (!_isDisposed) {
        // Check before setting state
        state = AsyncValue.error(e, s);
      } else {
        log("SearchStreamNotifier: Error in fetchMoreItems but unmounted: $e");
      }
    }
  }

  Future<List<TModel>> _fetch({int rangeStart = 0, int rangeEnd = 20}) async {
    final query = _currentSettings.queryBuilderFactory();

    if (terms.isEmpty) {
      return await query.range(rangeStart, rangeEnd).remoteOnly();
    } else {
      return await query
          .textSearch(_currentSettings.searchColumn, terms)
          .range(rangeStart, rangeEnd)
          .remoteOnly();
    }
  }

  Future<void> search(String newTerms) async {
    terms = newTerms;
    currentPage = 0;
    // refreshFeed will use the new `terms` and has its own disposal checks
    await refreshFeed(
      initialize: true,
    ); // Or false, depending on desired behavior
  }
}
