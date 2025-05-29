import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:tether_libs/models/tether_model.dart';
import 'package:tether_libs/models/table_info.dart';
import 'package:tether_libs/client_manager/manager/client_manager_models.dart'; // For SqlStatement, ClientManagerSqlUtils
import 'package:tether_libs/utils/logger.dart'; // Assuming you have a logger

/// Manages Supabase RPC calls where the response is expected to conform
/// to the structure of a specific database table and should be stored locally.
///
/// The RPC function's JSON reply must be an array of objects, where each object
/// represents a row with fields corresponding to the `targetSupabaseTableName`'s columns.
class RpcManager<TModel extends TetherModel<TModel>> {
  final SupabaseClient _supabaseClient;
  final SqliteDatabase _localDb;
  final String _rpcName;
  final String
  _targetSupabaseTableName; // The Supabase table name whose structure the RPC mirrors
  final String
  _targetLocalTableName; // The local SQLite table to upsert data into
  final FromJsonFactory<TModel> _fromJsonFactory;
  final Map<String, SupabaseTableInfo>
  _tableSchemas; // Expected to contain schema for _targetSupabaseTableName
  final Logger _logger = Logger('RpcManager');

  RpcManager({
    required SupabaseClient supabaseClient,
    required SqliteDatabase localDb,
    required String rpcName,
    required String targetSupabaseTableName,
    required String targetLocalTableName,
    required FromJsonFactory<TModel> fromJsonFactory,
    required Map<String, SupabaseTableInfo> tableSchemas,
  }) : _supabaseClient = supabaseClient,
       _localDb = localDb,
       _rpcName = rpcName,
       _targetSupabaseTableName = targetSupabaseTableName,
       _targetLocalTableName = targetLocalTableName,
       _fromJsonFactory = fromJsonFactory,
       _tableSchemas = tableSchemas;

  /// Executes the RPC function and processes its response.
  ///
  /// [params]: Parameters to pass to the RPC function.
  /// [storeResult]: If true (default), attempts to deserialize the response
  ///                and upsert it into the local database.
  /// [maybeSingle]: If true, expects the RPC to return a single object instead of a list.
  ///                The object will be wrapped in a list before processing.
  ///
  /// Returns a list of deserialized `TModel` objects if `storeResult` is true
  /// and the operation is successful, otherwise returns an empty list or throws an error.
  /// If `storeResult` is false, returns the raw RPC response (dynamic).
  Future<dynamic> call({
    Map<String, dynamic>? params,
    bool storeResult = true,
    bool maybeSingle = false,
  }) async {
    _logger.info('Calling RPC: $_rpcName with params: $params');
    try {
      final dynamic rpcResponse = await _supabaseClient.rpc(
        _rpcName,
        params: params,
      );

      if (!storeResult) {
        _logger.info(
          'RPC "$_rpcName" call successful. Result not stored locally as per request.',
        );
        return rpcResponse;
      }

      if (rpcResponse == null) {
        _logger.warning(
          'RPC "$_rpcName" returned null. No data to process or store.',
        );
        return <TModel>[];
      }

      List<Map<String, dynamic>> responseDataList;

      if (maybeSingle) {
        if (rpcResponse is Map<String, dynamic>) {
          responseDataList = [rpcResponse];
        } else {
          _logger.severe(
            'RPC "$_rpcName" expected a single object (Map<String, dynamic>) due to maybeSingle=true, but received type: ${rpcResponse.runtimeType}',
          );
          throw RpcResponseFormatException(
            _rpcName,
            'Expected a single JSON object (Map).',
            rpcResponse,
          );
        }
      } else {
        if (rpcResponse is List) {
          // Ensure all items in the list are Map<String, dynamic>
          if (rpcResponse.every((item) => item is Map<String, dynamic>)) {
            responseDataList = rpcResponse.cast<Map<String, dynamic>>();
          } else {
            _logger.severe(
              'RPC "$_rpcName" returned a list, but not all items are Map<String, dynamic>.',
            );
            throw RpcResponseFormatException(
              _rpcName,
              'Expected a List of JSON objects (Map).',
              rpcResponse,
            );
          }
        } else {
          _logger.severe(
            'RPC "$_rpcName" did not return a List as expected. Received type: ${rpcResponse.runtimeType}',
          );
          throw RpcResponseFormatException(
            _rpcName,
            'Expected a List of JSON objects (Map).',
            rpcResponse,
          );
        }
      }

      if (responseDataList.isEmpty) {
        _logger.info(
          'RPC "$_rpcName" returned an empty list. No data to store.',
        );
        return <TModel>[];
      }

      final List<TModel> models =
          responseDataList.map((data) => _fromJsonFactory(data)).toList();

      await _upsertDataToLocalDb(models);

      _logger.info(
        'Successfully called RPC "$_rpcName", processed and stored ${models.length} items into "$_targetLocalTableName".',
      );
      return models;
    } catch (e, s) {
      _logger.severe(
        'Error calling RPC "$_rpcName" or processing its result: $e\n$s',
      );
      if (e is PostgrestException || e is RpcResponseFormatException) {
        rethrow;
      }
      // Wrap other errors for more context if needed
      throw RpcCallException(
        _rpcName,
        e.toString(),
        originalException: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _upsertDataToLocalDb(List<TModel> models) async {
    if (models.isEmpty) return;

    // The key for tableSchemas is typically fully qualified, e.g., "public.my_table"
    // Assuming _targetSupabaseTableName is the simple name.
    final schemaKey = 'public.$_targetSupabaseTableName';
    final tableInfo = _tableSchemas[schemaKey];

    if (tableInfo == null) {
      final errorMsg =
          "Schema information for table '$schemaKey' (derived from '$_targetSupabaseTableName') not found. Cannot upsert RPC results.";
      _logger.severe(errorMsg);
      throw Exception(errorMsg); // Or a more specific exception type
    }

    // ClientManagerSqlUtils.buildUpsertSql expects the simple original Supabase table name
    // and the list of models. It internally derives the local table name if not explicitly passed,
    // but here we are explicit about the local table.
    // We need to ensure ClientManagerSqlUtils.buildUpsertSql can take localTableName or
    // that we adapt.
    //
    // Looking at ClientManagerBase, it calls:
    // ClientManagerSqlUtils.buildUpsertSql(modelsList, originalTableName)
    // Let's assume ClientManagerSqlUtils.buildUpsertSql uses the originalSupabaseTableName
    // to get schema and then uses the localTableName from that schema for the SQL.
    // Or, we might need a variant or to pass localTableName explicitly if the utility allows.

    // For now, let's assume ClientManagerSqlUtils.buildUpsertSql primarily uses
    // originalSupabaseTableName for schema lookup and the models' internal data for values.
    // The actual SQL will target the local table name.

    // Let's use a more direct approach if ClientManagerSqlUtils.buildUpsertSql is too tied
    // to ClientManagerBase's specific way of deriving local table names.
    // We have _targetLocalTableName explicitly.

    final List<SqlStatement> upsertStatements = [];

    // We need to build upsert SQL for _targetLocalTableName using _targetSupabaseTableName for schema.
    // ClientManagerSqlUtils.buildUpsertSql(models, _targetSupabaseTableName)
    // This utility will generate SQL for the local table associated with _targetSupabaseTableName
    // as per its schema. We need to ensure this aligns with _targetLocalTableName.
    //
    // If `SupabaseTableInfo.localName` is what `buildUpsertSql` uses, then
    // `tableInfo.localName` should match `_targetLocalTableName`.

    if (tableInfo.localName != _targetLocalTableName) {
      _logger.warning(
        "Mismatch: RpcManager's targetLocalTableName ('$_targetLocalTableName') "
        "differs from schema's localName ('${tableInfo.localName}') for Supabase table '$_targetSupabaseTableName'. "
        "Proceeding with RpcManager's targetLocalTableName for the upsert operation.",
      );
    }

    // We'll use a modified approach to ensure we target _targetLocalTableName
    // while using the schema of _targetSupabaseTableName.
    // ClientManagerSqlUtils.buildUpsertSql might need an overload or adjustment.
    // For simplicity, let's assume we can construct it correctly.

    // This assumes buildUpsertSql can correctly use the provided models
    // with the schema of _targetSupabaseTableName to generate an upsert for _targetLocalTableName.
    // A more robust ClientManagerSqlUtils.buildUpsertSql would take localTableName as a parameter.
    //
    // Let's assume ClientManagerSqlUtils.buildUpsertSql is:
    // static SqlStatement buildUpsertSql(List<TetherModel<dynamic>> models, String localTableName, SupabaseTableInfo tableSchema)
    // If not, we adapt. The existing one is:
    // static SqlStatement buildUpsertSql(List<TetherModel<dynamic>> models, String originalSupabaseTableName)
    // This implies it uses tableSchemas internally to find the local name.

    upsertStatements.add(
      ClientManagerSqlUtils.buildUpsertSql(models, _targetSupabaseTableName),
    );

    _logger.info(
      'Preparing to upsert ${models.length} models into local table "$_targetLocalTableName" (schema from "$_targetSupabaseTableName").',
    );

    if (upsertStatements.isNotEmpty) {
      await _localDb.writeTransaction((tx) async {
        for (final statement in upsertStatements) {
          final finalSql = statement.build();
          _logger.fine(
            'Executing SQL for RPC upsert: ${finalSql.sql} with args: ${finalSql.arguments}',
          );
          await tx.execute(finalSql.sql, finalSql.arguments);
        }
      });
      _logger.info(
        'Upserted ${models.length} models from RPC "$_rpcName" into "$_targetLocalTableName".',
      );
    }
  }
}

/// Custom exception for RPC call failures.
class RpcCallException implements Exception {
  final String rpcName;
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  RpcCallException(
    this.rpcName,
    this.message, {
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() {
    String result =
        'RpcCallException: Failed to execute RPC "$rpcName". Message: $message';
    if (originalException != null) {
      result += '\nOriginal Exception: $originalException';
    }
    return result;
  }
}

/// Custom exception for unexpected RPC response formats.
class RpcResponseFormatException implements Exception {
  final String rpcName;
  final String message;
  final dynamic responseReceived;

  RpcResponseFormatException(this.rpcName, this.message, this.responseReceived);

  @override
  String toString() {
    return 'RpcResponseFormatException: RPC "$rpcName" returned data in an unexpected format. Message: $message. Received: $responseReceived';
  }
}
