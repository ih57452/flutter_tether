import 'dart:io';
import 'package:inflection3/inflection3.dart';
import 'package:recase/recase.dart';
import 'package:flutter_tether/config/config_model.dart';
import 'package:tether_libs/models/table_info.dart';
import 'package:path/path.dart' as p;

Future<void> generateAuthManagerFiles({
  required SupabaseGenConfig config,
  required List<SupabaseTableInfo> allTables,
}) async {
  if (!config.generateAuthentication) {
    print('AuthManager generation is disabled in the config. Skipping.');
    return;
  }

  final profileTableInfo = allTables.firstWhere(
    (t) => t.originalName == config.authProfileTableName,
    orElse: () {
      print(
        'Error: Profile table "${config.authProfileTableName}" not found in allTables. Cannot generate AuthManager.',
      );
      // Return a dummy SupabaseTableInfo to prevent null errors if we were to proceed,
      // but ideally, we should throw or handle this more gracefully.
      // For now, we'll just print and exit this function.
      return SupabaseTableInfo(
        name: '',
        originalName: '',
        localName: '',
        schema: '',
        columns: [],
        foreignKeys: [],
        indexes: [],
        reverseRelations: [],
        comment: '',
      );
    },
  );

  if (profileTableInfo.originalName.isEmpty) {
    // Error already printed
    return;
  }

  final profileModelClassName = _getDartClassName(profileTableInfo, config);
  // Assuming local profile table name is the same as the Supabase one for simplicity.
  // This could be made configurable if needed.
  final localProfileTableName = profileTableInfo.localName;

  await _generateAuthManagerClassFile(
    config: config,
    profileModelClassName: profileModelClassName,
    supabaseProfileTableName: config.authProfileTableName,
    localProfileTableName: localProfileTableName,
    profileTableInfo: profileTableInfo,
  );

  await _generateAuthProvidersFile(
    config: config,
    profileModelClassName: profileModelClassName,
    supabaseProfileTableName: config.authProfileTableName,
    localProfileTableName: localProfileTableName,
  );
}

Future<void> _generateAuthManagerClassFile({
  required SupabaseGenConfig config,
  required String profileModelClassName,
  required String supabaseProfileTableName,
  required String localProfileTableName,
  required SupabaseTableInfo profileTableInfo,
}) async {
  final buffer = StringBuffer();
  final managersDir = p.join(config.outputDirectory, 'managers');

  buffer.writeln('''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/foundation.dart'; // For ValueNotifier
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqlite_async/sqlite_async.dart'; // For SqliteConnection
import 'package:tether_libs/client_manager/manager/client_manager_models.dart';
import 'package:tether_libs/models/table_info.dart';
import 'package:tether_libs/models/tether_model.dart';

typedef _FromJsonFactory<T extends TetherModel<T>> = T Function(Map<String, dynamic> json);

class AuthManager<TProfileModel extends TetherModel<TProfileModel>> {
  final SupabaseClient _supabaseClient;
  final SqliteConnection _localDb;
  final String _supabaseProfileTableName;
  final String _localProfileTableName;
  final _FromJsonFactory<TProfileModel> _profileFromJsonFactory;
  final Map<String, SupabaseTableInfo> _tableSchemas;
  late StreamSubscription<AuthState> _authSubscription;

  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);
  final ValueNotifier<TProfileModel?> currentProfileNotifier = ValueNotifier(null);

  AuthManager({
    required SupabaseClient supabaseClient,
    required SqliteConnection localDb,
    required String supabaseProfileTableName,
    required String localProfileTableName,
    required _FromJsonFactory<TProfileModel> profileFromJsonFactory,
    required Map<String, SupabaseTableInfo> tableSchemas,
  })  : _supabaseClient = supabaseClient,
        _localDb = localDb,
        _supabaseProfileTableName = supabaseProfileTableName,
        _localProfileTableName = localProfileTableName,
        _profileFromJsonFactory = profileFromJsonFactory,
        _tableSchemas = tableSchemas {
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen(_onAuthStateChanged);
    final currentSession = _supabaseClient.auth.currentSession;
    final initialAuthState = currentSession == null
        ? AuthState(AuthChangeEvent.signedOut, null)
        : AuthState(AuthChangeEvent.signedIn, currentSession);
    _onAuthStateChanged(initialAuthState);
  }

  User? get currentUser => _supabaseClient.auth.currentUser;
  Session? get currentSession => _supabaseClient.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => _supabaseClient.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _supabaseClient.auth.signUp(email: email, password: password, data: data);
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _supabaseClient.auth.signInWithPassword(email: email, password: password);
  }
  
  Future<AuthResponse> signInWithOtp({
    required String email,
    required String token,
    OtpType type = OtpType.email,
  }) {
    return _supabaseClient.auth.verifyOTP(
      type: type,
      token: token,
      email: email,
    );
  }
  
  Future<void> resendOtp({
    required String email,
    required OtpType type,
  }) {
    return _supabaseClient.auth.resend(type: type, email: email);
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Future<void> _onAuthStateChanged(AuthState authState) async {
    final session = authState.session;
    final user = session?.user;
    currentUserNotifier.value = user;

    if (authState.event == AuthChangeEvent.signedIn ||
        authState.event == AuthChangeEvent.tokenRefreshed ||
        authState.event == AuthChangeEvent.userUpdated) {
      if (user != null) {
        await _fetchAndStoreProfile(user.id);
      } else {
        await _clearLocalProfileData();
      }
    } else if (authState.event == AuthChangeEvent.signedOut ||
               authState.event == AuthChangeEvent.userDeleted) {
      await _clearLocalProfileData();
    }
  }

  Future<void> _fetchAndStoreProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from(_supabaseProfileTableName)
          .select()
          .eq('id', userId) 
          .maybeSingle();

      if (response != null && response is Map<String, dynamic>) {
        final profileModel = _profileFromJsonFactory(response);
        await _upsertProfileToLocalDb(profileModel);
        currentProfileNotifier.value = profileModel;
      } else {
        print('AuthManager: Profile not found for user \$userId or unexpected response. Clearing local profile.');
        await _clearLocalProfileData();
      }
    } catch (e, s) {
      print('AuthManager: Error fetching/storing profile for user \$userId: \$e\\n\$s');
      await _clearLocalProfileData();
    }
  }

  Future<void> _upsertProfileToLocalDb(TProfileModel profileModel) async {
    final profileTableSchemaKey = 'public.\$_supabaseProfileTableName';
    final tableInfo = _tableSchemas[profileTableSchemaKey];

    if (tableInfo == null) {
      print("AuthManager: Error - Table info for '\$profileTableSchemaKey' not found in provided tableSchemas.");
      return;
    }

    try {
      await _localDb.execute('DELETE FROM \$_localProfileTableName');
      final insertStatement = ClientManagerSqlUtils.buildInsertSql(
        [profileModel],
        _localProfileTableName,
      );
      final finalSql = insertStatement.build();
      await _localDb.execute(finalSql.sql, finalSql.arguments);
      print('AuthManager: Profile upserted to local DB table \$_localProfileTableName.');
    } catch (e, s) {
      print('AuthManager: Error upserting profile to local DB table \$_localProfileTableName: \$e\\n\$s');
    }
  }

  Future<void> _clearLocalProfileData() async {
    try {
      await _localDb.execute('DELETE FROM \$_localProfileTableName');
      currentProfileNotifier.value = null;
      print('AuthManager: Local profile data cleared from table \$_localProfileTableName.');
    } catch (e, s) {
      print('AuthManager: Error clearing local profile data from table \$_localProfileTableName: \$e\\n\$s');
    }
  }
  
  void dispose() {
    _authSubscription.cancel();
    currentUserNotifier.dispose();
    currentProfileNotifier.dispose();
  }
}
''');

  final file = File(p.join(managersDir, 'auth_manager.g.dart'));
  final parentDir = file.parent;
  if (!await parentDir.exists()) {
    await parentDir.create(recursive: true);
  }
  await file.writeAsString(buffer.toString());
  print('Generated AuthManager class at ${file.path}');
}

Future<void> _generateAuthProvidersFile({
  required SupabaseGenConfig config,
  required String profileModelClassName,
  required String supabaseProfileTableName,
  required String localProfileTableName,
}) async {
  final buffer = StringBuffer();
  final providersDir = config.providersDirectoryPath; // Use the helper getter

  // Calculate relative paths
  final authManagerPath = p
      .relative(
        p.join(config.outputDirectory, 'managers', 'auth_manager.g.dart'),
        from: providersDir,
      )
      .replaceAll(r'\', '/');
  final modelsFilePath = p
      .relative(config.modelsFilePath, from: providersDir)
      .replaceAll(r'\', '/');
  final schemaFilePath = p
      .relative(config.generatedSupabaseSchemaDartFilePath, from: providersDir)
      .replaceAll(r'\', '/');
  // Assuming database_provider.dart and supabase_client_provider.dart are accessible from providersDir
  // These might need to be configurable if their locations vary greatly.
  // For now, let's assume they are in a way that `../database/database_provider.dart` or similar works.
  // A common pattern is to have a central `database.dart` in `outputDirectory` that exports the provider.
  final databaseProviderPath = p
      .relative(
        p.join(config.outputDirectory, 'database.dart'),
        from: providersDir,
      )
      .replaceAll(r'\', '/');

  buffer.writeln('''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For User
import '$authManagerPath';
import '$modelsFilePath';
import '$schemaFilePath';

import '$databaseProviderPath'; // Provides 'databaseProvider'

final authManagerProvider = Provider<AuthManager<$profileModelClassName>>((ref) {
  final supabaseClient = Supabase.instance.client;
  final localDb = ref.watch(databaseProvider).requireValue.db; 
  final tableSchemas = globalSupabaseSchema; // Assumes globalSupabaseSchema is directly available via schemaFilePath import

  final manager = AuthManager<$profileModelClassName>(
    supabaseClient: supabaseClient,
    localDb: localDb,
    supabaseProfileTableName: '$supabaseProfileTableName',
    localProfileTableName: '$localProfileTableName',
    profileFromJsonFactory: (json) => $profileModelClassName.fromJson(json),
    tableSchemas: tableSchemas,
  );

  ref.onDispose(() => manager.dispose());
  return manager;
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final authManager = ref.watch(authManagerProvider);
  // Use ValueNotifier directly for simpler StreamProvider
  return authManager.currentUserNotifier.stream;
});

final currentProfileProvider = StreamProvider<$profileModelClassName?>((ref) {
  final authManager = ref.watch(authManagerProvider);
  // Use ValueNotifier directly for simpler StreamProvider
  return authManager.currentProfileNotifier.stream;
});

// Extension to convert ValueNotifier to Stream for StreamProvider
extension _ValueNotifierStream<T> on ValueNotifier<T> {
  Stream<T> get stream {
    final controller = StreamController<T>();
    controller.add(value); // Add current value immediately
    void listener() {
      if (!controller.isClosed) {
        controller.add(value);
      }
    }
    addListener(listener);
    controller.onCancel = () {
      removeListener(listener);
      // Do not close the controller here if it's meant to be long-lived
      // and potentially re-listened to, or if the ValueNotifier itself is not disposed.
      // However, for a typical StreamProvider usage, closing on cancel is fine.
    };
    // Closing the controller when the ValueNotifier is disposed is ideal,
    // but ValueNotifier doesn't have an onDispose callback.
    // The StreamProvider's autoDispose or manual ref.onDispose for the authManagerProvider
    // handles the lifecycle of the ValueNotifier itself.
    return controller.stream;
  }
}
''');

  final file = File(p.join(providersDir, 'auth_providers.g.dart'));
  final parentDir = file.parent;
  if (!await parentDir.exists()) {
    await parentDir.create(recursive: true);
  }
  await file.writeAsString(buffer.toString());
  print('Generated Auth providers at ${file.path}');
}

/// Generates the Dart class name for a table, consistent with ModelGenerator.
String _getDartClassName(SupabaseTableInfo table, SupabaseGenConfig config) {
  final prefix = config.modelPrefix ?? '';
  final suffix = config.modelSuffix ?? 'Model';
  return '$prefix${singularize(table.localName.pascalCase)}$suffix';
}
