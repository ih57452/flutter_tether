import 'dart:async';
import 'package:flutter/foundation.dart'; // For ValueNotifier
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqlite_async/sqlite_async.dart'; // For SqliteConnection
import 'package:tether_libs/models/table_info.dart';
import 'package:tether_libs/models/tether_model.dart';
import 'package:tether_libs/client_manager/manager/client_manager_models.dart';
import 'package:tether_libs/utils/logger.dart';

typedef FromJsonFactory<T extends TetherModel<T>> =
    T Function(Map<String, dynamic> json);

class AuthManager<TProfileModel extends TetherModel<TProfileModel>> {
  final SupabaseClient _supabaseClient;
  final SqliteConnection _localDb;
  final String _supabaseProfileTableName; // e.g., "profiles"
  final String
  _localProfileTableName; // e.g., "user_profile" (local SQLite table name)
  final FromJsonFactory<TProfileModel> _profileFromJsonFactory;
  final Map<String, SupabaseTableInfo> _tableSchemas;
  late StreamSubscription<AuthState> _authSubscription;

  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);
  final ValueNotifier<TProfileModel?> currentProfileNotifier = ValueNotifier(
    null,
  );

  final Logger _logger = Logger('AuthManager');

  AuthManager({
    required SupabaseClient supabaseClient,
    required SqliteConnection localDb,
    required String supabaseProfileTableName,
    required String localProfileTableName,
    required FromJsonFactory<TProfileModel> profileFromJsonFactory,
    required Map<String, SupabaseTableInfo> tableSchemas,
  }) : _supabaseClient = supabaseClient,
       _localDb = localDb,
       _supabaseProfileTableName = supabaseProfileTableName,
       _localProfileTableName = localProfileTableName,
       _profileFromJsonFactory = profileFromJsonFactory,
       _tableSchemas = tableSchemas {
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen(
      _onAuthStateChanged,
    );
    // Initialize with current state
    final currentSession = _supabaseClient.auth.currentSession;
    final initialAuthState =
        currentSession == null
            ? AuthState(AuthChangeEvent.signedOut, null)
            : AuthState(AuthChangeEvent.signedIn, currentSession);
    _onAuthStateChanged(initialAuthState);
  }

  User? get currentUser => _supabaseClient.auth.currentUser;
  Session? get currentSession => _supabaseClient.auth.currentSession;
  Stream<AuthState> get onAuthStateChange =>
      _supabaseClient.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signInWithOtp({
    required String email,
    required String token,
  }) {
    return _supabaseClient.auth.verifyOTP(
      type: OtpType.email, // Or other OtpType as appropriate
      token: token,
      email: email,
    );
  }

  Future<void> resendOtp({required String email, required OtpType type}) {
    return _supabaseClient.auth.resend(type: type, email: email);
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    // The listener _onAuthStateChanged will handle clearing local data.
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
        // Should not happen if event is signedIn and session is present, but good to handle
        await _clearLocalProfileData();
      }
    } else if (authState.event == AuthChangeEvent.signedOut) {
      await _clearLocalProfileData();
    }
  }

  Future<void> _fetchAndStoreProfile(String userId) async {
    try {
      final response =
          await _supabaseClient
              .from(_supabaseProfileTableName)
              .select()
              .eq(
                'id',
                userId,
              ) // Assuming profile table's PK is 'id' and matches user.id
              .maybeSingle();

      if (response != null) {
        final profileModel = _profileFromJsonFactory(response);
        await _upsertProfileToLocalDb(profileModel);
        currentProfileNotifier.value = profileModel;
      } else {
        // Profile not found or unexpected response
        _logger.warning(
          'Profile not found for user $userId or unexpected response. Clearing local profile.',
        );
        await _clearLocalProfileData();
      }
    } catch (e, s) {
      _logger.severe('Error fetching/storing profile for user $userId: $e\n$s');
      await _clearLocalProfileData(); // Clear local data on error
    }
  }

  Future<void> _upsertProfileToLocalDb(TProfileModel profileModel) async {
    final profileTableSchemaKey =
        'public.$_supabaseProfileTableName'; // Assuming 'public' schema
    final profileTableInfo = _tableSchemas[profileTableSchemaKey];

    if (profileTableInfo == null) {
      _logger.severe(
        "Error - Table info for '$profileTableSchemaKey' not found in provided tableSchemas.",
      );
      return;
    }

    try {
      // Clear existing profile data first to ensure only one profile is stored
      await _localDb.execute('DELETE FROM $_localProfileTableName');

      final insertStatement = ClientManagerSqlUtils.buildInsertSql(
        [profileModel], // buildInsertSql expects a list
        _localProfileTableName,
      );
      final finalSql = insertStatement.build();
      await _localDb.execute(finalSql.sql, finalSql.arguments);
      _logger.info(
        'Profile upserted to local DB table $_localProfileTableName.',
      );
    } catch (e, s) {
      _logger.severe(
        'Error upserting profile to local DB table $_localProfileTableName: $e\n$s',
      );
    }
  }

  Future<void> _clearLocalProfileData() async {
    try {
      await _localDb.execute('DELETE FROM $_localProfileTableName');
      currentProfileNotifier.value = null;
      _logger.info(
        'Local profile data cleared from table $_localProfileTableName.',
      );
    } catch (e, s) {
      _logger.severe(
        'Error clearing local profile data from table $_localProfileTableName: $e\n$s',
      );
    }
  }

  /// Call this when the AuthManager is no longer needed, e.g., in a Riverpod provider's onDispose.
  void dispose() {
    _authSubscription.cancel();
    currentUserNotifier.dispose();
    currentProfileNotifier.dispose();
  }
}
