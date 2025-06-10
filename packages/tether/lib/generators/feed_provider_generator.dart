import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tether_libs/utils/logger.dart'; // Assuming you have a Logger utility

class FeedProviderGenerator {
  final String outputDirectory; // e.g., 'example/frontend/lib'
  final Logger _logger;

  FeedProviderGenerator({required this.outputDirectory, Logger? logger})
    : _logger = logger ?? Logger('FeedProviderGenerator');

  Future<void> generate() async {
    final providersDir = p.join(outputDirectory);
    final fileName = 'feed_provider.dart';
    final filePath = p.join(providersDir, fileName);

    final buffer = StringBuffer();

    buffer.writeln('');
    buffer.writeln("""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names, avoid_public_notifier_properties

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:sqlite_async/sqlite_async.dart'; // Ensure SqliteDatabase is imported
import 'package:tether_libs/client_manager/client_manager.dart';
import 'package:tether_libs/client_manager/manager/client_manager_base.dart';
import 'package:tether_libs/client_manager/manager/client_manager_filter_builder.dart';
import 'package:tether_libs/client_manager/manager/client_manager_models.dart';
import 'package:tether_libs/models/supabase_select_builder_base.dart';
import 'package:tether_libs/models/tether_model.dart';
import 'package:tether_libs/utils/logger.dart';

import '../database.dart';
import '../managers/feed_item_reference_manager.g.dart';

typedef QueryBuilderFactory<TModel extends TetherModel<TModel>> =
    ClientManagerFilterBuilder<TModel> Function();

class FeedStreamNotifierSettings<TModel extends TetherModel<TModel>>
    extends Equatable {
  final String feedKey;
  final TetherColumn? searchColumn; // Made nullable
  final int pageSize;
  final ClientManager<TModel> clientManager;
  final SelectBuilderBase selectArgs;
  final TModel Function(Map<String, dynamic> json) fromJsonFactory;
  final ClientManagerFilterBuilder<TModel> Function(
    ClientManagerFilterBuilder<TModel> baseQuery,
  )?
  queryCustomizer; // This can define the "base filtered view"

  const FeedStreamNotifierSettings({
    required this.feedKey,
    this.searchColumn, // Nullable, so not required
    required this.clientManager,
    required this.selectArgs,
    required this.fromJsonFactory,
    this.pageSize = 20,
    this.queryCustomizer,
  });

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

class FeedStreamNotifier<TModel extends TetherModel<TModel>>
    extends
        FamilyStreamNotifier<List<TModel>, FeedStreamNotifierSettings<TModel>> {
  late FeedStreamNotifierSettings<TModel> _currentSettings;

  int currentPage = 0;
  String terms = '';
  bool _isDisposed = false;
  final Logger _logger = Logger('SearchStreamNotifier');

  // For dynamic filters applied on top of queryCustomizer
  ClientManagerFilterBuilder<TModel> Function(
    ClientManagerFilterBuilder<TModel> query,
  )?
  _dynamicFilterApplicator;

  FeedStreamNotifier() {
    // Initialization in build
  }

  ClientManagerFilterBuilder<TModel> _getEffectiveQueryBuilder() {
    // 1. Start with the absolute base query from settings
    var query = _currentSettings.clientManager.query.select(
      _currentSettings.selectArgs,
    );

    // 2. Apply the "base query modifications" (static customizer) from settings
    if (_currentSettings.queryCustomizer != null) {
      query = _currentSettings.queryCustomizer!(query);
    }

    // 3. Apply dynamic filters if any are set
    if (_dynamicFilterApplicator != null) {
      query = _dynamicFilterApplicator!(query);
    }

    // 4. Apply search terms if search is configured and terms are present
    if (_currentSettings.searchColumn != null && terms.isNotEmpty) {
      query = query.textSearch(_currentSettings.searchColumn!, terms);
    }
    return query;
  }

  // Helper to get the query structure for feedStream's JSON sub-select
  ClientManagerFilterBuilder<TModel> _getBaseQueryForFeedStreamSchema() {
    var baseQuery = _currentSettings.clientManager.query.select(
      _currentSettings.selectArgs,
    );
    if (_currentSettings.queryCustomizer != null) {
      baseQuery = _currentSettings.queryCustomizer!(baseQuery);
    }
    return baseQuery;
  }

  @override
  Stream<List<TModel>> build(FeedStreamNotifierSettings<TModel> arg) async* {
    _currentSettings = arg;
    currentPage = 0;
    terms = '';
    _dynamicFilterApplicator = null; // Reset dynamic filters
    _isDisposed = false;

    ref.onDispose(() {
      _isDisposed = true;
    });

    final count = await _getCount();
    if (_isDisposed) return;

    if (count == 0) {
      await refreshFeed(initialize: true);
    } else {
      await refreshFeed();
    }
    if (_isDisposed) return;

    yield* feedStream;
  }

  Stream<List<TModel>> get feedStream async* {
    final appDatabase = ref.watch(databaseProvider).value!;
    final sqliteDb = appDatabase.db as SqliteDatabase;

    // Use the base query (with static customizer) for determining table name and selector for SQL
    final baseQueryForSchema = _getBaseQueryForFeedStreamSchema();
    final modelTableName = baseQueryForSchema.tableName;
    final SelectBuilderBase? selector =
        baseQueryForSchema.selectorStatement;

    if (selector == null) {
      _logger.severe(
        'SearchStreamNotifier: selectorStatement is null in feedStream for \$modelTableName. This indicates a setup error with base query.',
      );
      yield <TModel>[];
      return;
    }

    final SqlStatement jsonSelectSubQueryStatement =
        selector.buildSelectWithNestedData();

    if (selector.currentTableInfo.primaryKeys.isEmpty) {
      _logger.severe(
        'SearchStreamNotifier: Table \${selector.currentTableInfo.originalName} has no primary keys defined. Cannot build feedStream SQL.',
      );
      yield <TModel>[];
      return;
    }
    final String modelPrimaryKeyCol =
        selector.currentTableInfo.primaryKeys.first.originalName;
    final String aliasInSubQuery =
        jsonSelectSubQueryStatement.fromAlias ?? 't_fallback';

    final sql = '''
      SELECT
        fir.id AS feed_item_ref_id,
        fir.feed_key,
        fir.item_source_table,
        fir.item_source_id,
        fir.display_order,
        CASE
            WHEN fir.item_source_table = ? THEN (
                SELECT \${jsonSelectSubQueryStatement.selectColumns}
                FROM "\${jsonSelectSubQueryStatement.tableName}" AS "\$aliasInSubQuery"
                WHERE "\$aliasInSubQuery"."\$modelPrimaryKeyCol" = fir.item_source_id
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
                  'SearchStreamNotifier: JSONDecode error for item_json_data: \$e, data: \$jsonData',
                );
                return null;
              }
            } else if (jsonData is Map<String, dynamic>) {
              parsedJson = jsonData;
            } else {
              _logger.warning(
                'SearchStreamNotifier: Unexpected format for item_json_data: \${jsonData.runtimeType}',
              );
              return null;
            }
            try {
              return _currentSettings.fromJsonFactory(parsedJson);
            } catch (e) {
              _logger.severe(
                'SearchStreamNotifier: Error in fromJsonFactory for \$modelTableName: \$e, json: \$parsedJson',
              );
              return null;
            }
          })
          .whereType<TModel>()
          .toList();
    });
  }

  Future<int> _getCount() async {
    final feedManager = ref.read(feedItemReferenceManagerProvider);
    return await feedManager.getCount(feedKey: _currentSettings.feedKey);
  }

  Future<void> refreshFeed({bool initialize = false}) async {
    try {
      _logger.info(
        'refreshFeed called. initialize: \$initialize, current terms: "\$terms", dynamicFiltersSet: \${_dynamicFilterApplicator != null}',
      );

      // _fetch will use _getEffectiveQueryBuilder()
      final items = await _fetch(
        rangeStart: 0,
        rangeEnd: _currentSettings.pageSize - 1,
      );

      if (_isDisposed) return;

      final feedManager = ref.read(feedItemReferenceManagerProvider);
      final feedKey = _currentSettings.feedKey;
      final effectiveQuery = _getEffectiveQueryBuilder(); // To get tableName

      if (initialize) {
        await feedManager.clearFeed(feedKey: feedKey);
        if (_isDisposed) return;
        await feedManager.setFeedItems(
          feedKey: feedKey,
          items:
              items
                  .data
                  .asMap()
                  .entries
                  .map(
                    (e) => FeedItemReference(
                      itemSourceTable:
                          effectiveQuery
                              .tableName, // Use effective query's table
                      itemSourceId: e.value.localId.toString(),
                      displayOrder: e.key,
                    ),
                  )
                  .toList(),
        );
      } else {
        // addItemsToStart might not be the right behavior if filters change.
        // Consider if 'initialize: true' should always be used when filters or search terms change.
        // For now, keeping existing logic.
        await feedManager.addItemsToStart(
          feedKey: feedKey,
          newItemsToAdd:
              items
                  .data
                  .asMap()
                  .entries
                  .map(
                    (e) => FeedItemReference(
                      itemSourceTable:
                          effectiveQuery
                              .tableName, // Use effective query's table
                      itemSourceId: e.value.localId.toString(),
                      displayOrder: e.key,
                    ),
                  )
                  .toList(),
        );
      }
      if (_isDisposed) return;
      currentPage = 0;
    } catch (e, s) {
      if (!_isDisposed) {
        state = AsyncValue.error(e, s);
      } else {
        _logger.warning(
          'SearchStreamNotifier: Error in refreshFeed but unmounted: \$e',
        );
      }
    }
  }

  Future<void> fetchMoreItems() async {
    final nextPage = currentPage + 1;
    try {
      final rangeStart = nextPage * _currentSettings.pageSize;
      final rangeEnd = ((nextPage + 1) * _currentSettings.pageSize) - 1;
      // _fetch will use _getEffectiveQueryBuilder()
      final newItems = await _fetch(rangeStart: rangeStart, rangeEnd: rangeEnd);

      if (_isDisposed) return;

      if (newItems.data.isNotEmpty) {
        final feedManager = ref.read(feedItemReferenceManagerProvider);
        final effectiveQuery = _getEffectiveQueryBuilder(); // To get tableName
        await feedManager.addItemsToEnd(
          feedKey: _currentSettings.feedKey,
          itemsToAdd:
              newItems
                  .data
                  .map(
                    (item) => FeedItemReference(
                      itemSourceTable:
                          effectiveQuery
                              .tableName, // Use effective query's table
                      itemSourceId: item.localId.toString(),
                      // displayOrder for addItemsToEnd is handled by the manager
                      displayOrder: -1, // Or let manager handle it
                    ),
                  )
                  .toList(),
        );
        if (_isDisposed) return;
        currentPage = nextPage;
      }
    } catch (e, s) {
      if (!_isDisposed) {
        state = AsyncValue.error(e, s);
      } else {
        _logger.warning(
          'SearchStreamNotifier: Error in fetchMoreItems but unmounted: \$e',
        );
      }
    }
  }

  Future<TetherClientReturn<TModel>> _fetch({int rangeStart = 0, int rangeEnd = 20}) async {
    final effectiveQuery = _getEffectiveQueryBuilder();
    // The textSearch is now part of _getEffectiveQueryBuilder if terms are set
    return await effectiveQuery.range(rangeStart, rangeEnd).remoteOnly();
  }

  Future<void> search(String newTerms) async {
    if (_currentSettings.searchColumn == null && newTerms.isNotEmpty) {
      _logger.warning(
        "SearchStreamNotifier: Search initiated for '\$newTerms' but no searchColumn is configured for feedKey '\${_currentSettings.feedKey}'.",
      );
      // Optionally, clear terms if search is not supported
      // terms = '';
      // return; // Or proceed to refresh without search
    }
    if (_currentSettings.searchColumn == null &&
        newTerms.isEmpty &&
        terms.isEmpty) {
      // If search isn't configured and both new and old terms are empty, no need to refresh if only terms changed.
      // However, if other filters might have changed, a refresh might still be desired.
      // For simplicity, we'll proceed with refresh, as `refreshFeed` handles the effective query.
    }

    terms = newTerms;
    currentPage = 0;
    await refreshFeed(initialize: true);
  }

  /// Applies a new set of dynamic filters to the feed.
  /// The [filterApplicator] function takes the current base query (after static customizers)
  /// and should return a new query with the dynamic filters applied.
  Future<void> applyDynamicFilters(
    ClientManagerFilterBuilder<TModel> Function(
      ClientManagerFilterBuilder<TModel> baseQueryWithoutDynamicFilters,
    )
    filterApplicator,
  ) async {
    _logger.info(
      "Applying dynamic filters for feedKey '\${_currentSettings.feedKey}'.",
    );
    _dynamicFilterApplicator = filterApplicator;
    currentPage = 0;
    // It's usually best to re-initialize the feed when filters change significantly.
    // Also, consider if search terms should be cleared or maintained.
    // For now, maintaining search terms.
    await refreshFeed(initialize: true);
  }

  /// Clears any previously applied dynamic filters, reverting to the base query
  /// (which includes the static queryCustomizer from settings).
  Future<void> clearDynamicFilters() async {
    if (_dynamicFilterApplicator != null) {
      _logger.info(
        "Clearing dynamic filters for feedKey '\${_currentSettings.feedKey}'.",
      );
      _dynamicFilterApplicator = null;
      currentPage = 0;
      // Also consider if search terms should be cleared.
      await refreshFeed(initialize: true);
    } else {
      _logger.info(
        "No dynamic filters to clear for feedKey '\${_currentSettings.feedKey}'.",
      );
    }
  }
}



""");
    buffer.writeln('');

    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(buffer.toString());
      _logger.info('Generated feed provider: $filePath');
    } catch (e) {
      _logger.severe('Error writing feed provider file $filePath: $e');
    }
  }
}
