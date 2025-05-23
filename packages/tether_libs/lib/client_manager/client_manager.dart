import 'package:sqlite_async/sqlite_async.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_libs/schema/table_info.dart';
import 'client_manager_models.dart';
import 'client_manager_query_builder.dart';
import '../models/tether_model.dart';

class ClientManager<TModel extends TetherModel<TModel>> {
  final String tableName;

  final String localTableName;

  final SqliteDatabase localDb;

  final SupabaseClient client;

  final SupabaseQueryBuilder supabase;

  final Map<String, SupabaseTableInfo> tableSchemas;

  final FromJsonFactory<TModel> fromJsonFactory;

  final FromSqliteFactory<TModel> fromSqliteFactory;

  ClientManager({
    required this.tableName,
    required this.localTableName,
    required this.localDb,
    required this.client,
    required this.tableSchemas,
    required this.fromJsonFactory,
    required this.fromSqliteFactory,
  }) : supabase = client.from(tableName);

  ClientManagerQueryBuilder<TModel> query() {
    return ClientManagerQueryBuilder<TModel>(
      tableName: tableName,
      localTableName: localTableName,
      localDb: localDb,
      client: client,
      supabase: supabase,
      tableSchemas: tableSchemas,
      fromJsonFactory: fromJsonFactory,
      fromSqliteFactory: fromSqliteFactory,
    );
  }
}
