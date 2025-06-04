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
        print('AuthManager: Profile not found for user $userId or unexpected response. Clearing local profile.');
        await _clearLocalProfileData();
      }
    } catch (e, s) {
      print('AuthManager: Error fetching/storing profile for user $userId: $e\n$s');
      await _clearLocalProfileData();
    }
  }

  Future<void> _upsertProfileToLocalDb(TProfileModel profileModel) async {
    final profileTableSchemaKey = 'public.$_supabaseProfileTableName';
    final tableInfo = _tableSchemas[profileTableSchemaKey];

    if (tableInfo == null) {
      print("AuthManager: Error - Table info for '$profileTableSchemaKey' not found in provided tableSchemas.");
      return;
    }

    try {
      await _localDb.execute('DELETE FROM $_localProfileTableName');
      final insertStatement = ClientManagerSqlUtils.buildInsertSql(
        [profileModel],
        _localProfileTableName,
      );
      final finalSql = insertStatement.build();
      await _localDb.execute(finalSql.sql, finalSql.arguments);
      print('AuthManager: Profile upserted to local DB table $_localProfileTableName.');
    } catch (e, s) {
      print('AuthManager: Error upserting profile to local DB table $_localProfileTableName: $e\n$s');
    }
  }

  Future<void> _clearLocalProfileData() async {
    try {
      await _localDb.execute('DELETE FROM $_localProfileTableName');
      currentProfileNotifier.value = null;
      print('AuthManager: Local profile data cleared from table $_localProfileTableName.');
    } catch (e, s) {
      print('AuthManager: Error clearing local profile data from table $_localProfileTableName: $e\n$s');
    }
  }
  
  void dispose() {
    _authSubscription.cancel();
    currentUserNotifier.dispose();
    currentProfileNotifier.dispose();
  }
}

