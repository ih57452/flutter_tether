// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For User
import 'package:tether_libs/auth_manager/auth_manager.dart';
import '../models.g.dart';
import '../supabase_schema.dart';

import '../database.dart'; // Provides 'databaseProvider'

final authManagerProvider = Provider<AuthManager<ProfileModel>>((ref) {
  final supabaseClient = Supabase.instance.client;
  final localDb = ref.watch(databaseProvider).requireValue.db; 
  final tableSchemas = globalSupabaseSchema; // Assumes globalSupabaseSchema is directly available via schemaFilePath import

  final manager = AuthManager<ProfileModel>(
    supabaseClient: supabaseClient,
    localDb: localDb,
    supabaseProfileTableName: 'profiles',
    localProfileTableName: 'profiles',
    profileFromJsonFactory: (json) => ProfileModel.fromJson(json),
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

final currentProfileProvider = StreamProvider<ProfileModel?>((ref) {
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

