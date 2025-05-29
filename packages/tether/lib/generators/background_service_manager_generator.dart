import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:tether/config/config_model.dart'; // Assuming SupabaseGenConfig is here

/// Generates a Riverpod provider for the BackgroundJobManager.
Future<void> generateBackgroundJobManagerProviderFile({
  required SupabaseGenConfig config,
  // Logger? logger, // Optional: if you want to integrate logging
}) async {
  final buffer = StringBuffer();
  // Determine the output directory for providers within the user's lib folder
  // config.outputDirectory usually points to 'lib/generated' or similar.
  // We want to place this in 'lib/providers' or 'lib/application/providers'
  // For simplicity, let's assume config.outputDirectory is 'lib/src/generated'
  // and we want the provider in 'lib/application/providers'.
  // Adjust this path logic based on your project structure and where SupabaseGenConfig.outputDirectory points.

  // A common pattern is to have generated files inside a 'generated' subfolder.
  // If config.outputDirectory is 'lib/src/generated', then providers might be 'lib/src/application/providers'.
  // Let's assume the user wants it in 'lib/application/providers' relative to the project root.
  // This requires knowing the project root or making assumptions about config.outputDirectory.

  // Simplification: Let's place it relative to config.outputDirectory,
  // assuming outputDirectory is something like 'lib/src/generated_code'
  // and the user might move/adjust or the actual providers dir is elsewhere.
  // A more robust solution would involve more specific configuration for provider paths.

  // For now, let's target a 'providers' subdirectory within the configured output directory.
  // The user can then export or use this generated provider from their actual provider setup.
  final providersDir = p.join(config.outputDirectory, 'providers');
  final fileName = 'background_job_manager_provider.g.dart';

  buffer.writeln('''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, unnecessary_import, lines_longer_than_80_chars

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_async/sqlite_async.dart'; // For SqliteConnection type

// Adjust the import path to your BackgroundJobManager.
// This assumes 'tether_libs' is a direct or transitive dependency.
// If your generated code (where BackgroundJobManager might be) is in a different relative path, adjust accordingly.
// For example, if BackgroundJobManager is in: 'package:my_project/src/generated_code/managers/background_job_manager.g.dart'
// and this provider is in 'package:my_project/src/generated_code/providers/background_job_manager_provider.g.dart',
// the import might be:
// import '../managers/background_job_manager.g.dart';
// For now, assuming it's accessible via tether_libs:
import 'package:tether_libs/background_service/background_service_manager.dart';

// --- IMPORTANT ---
// This provider assumes you have another Riverpod provider that supplies the
// SqliteConnection for your main UI isolate.
// Please REPLACE `uiDatabaseConnectionProvider` with your actual provider.
//
// Example of what `uiDatabaseConnectionProvider` might look like:
//
// ```dart
// // In your database setup file (e.g., lib/application/database/app_database.dart)
// // final appDatabaseProvider = Provider<AppDatabase>((ref) {
// //   return AppDatabase(); // Your class that holds the SqliteConnection
// // });
// //
// // final uiDatabaseConnectionProvider = Provider<SqliteConnection>((ref) {
// //   final appDb = ref.watch(appDatabaseProvider);
// //   if (appDb.db == null) {
// //     throw Exception("Database not initialized. Ensure AppDatabase is initialized before accessing the connection.");
// //   }
// //   return appDb.db!; // Assuming 'db' is your SqliteConnection instance
// // });
// ```
// Ensure `uiDatabaseConnectionProvider` is correctly defined and provides an initialized SqliteConnection.
// If it's a FutureProvider, you'll need to handle the AsyncValue state.

// Replace this with your actual provider that supplies the UI's SqliteConnection
// For example, if your provider is in 'lib/application/database_provider.dart':
// import 'package:your_project_name/application/database_provider.dart';

// Placeholder for the actual database provider name - USER MUST REPLACE THIS
final uiDatabaseConnectionProvider = Provider<SqliteConnection>((ref) {
  throw UnimplementedError(
      'Please replace "uiDatabaseConnectionProvider" with your actual Riverpod provider '
      'that supplies the SqliteConnection for the UI isolate.');
});


/// Riverpod provider for accessing the [BackgroundJobManager].
///
/// This manager is used to interact with the `background_service_jobs` table
/// from the main UI isolate (e.g., for enqueuing jobs or querying their status).
///
/// It requires an active [SqliteConnection] for the UI isolate, which is
/// obtained from the `uiDatabaseConnectionProvider`. Ensure that
/// `uiDatabaseConnectionProvider` is correctly defined and provides an
/// initialized database connection.
final backgroundJobManagerProvider = Provider<BackgroundJobManager>((ref) {
  final dbConnection = ref.watch(uiDatabaseConnectionProvider);
  return BackgroundJobManager(db: dbConnection);
});
''');

  final file = File(p.join(providersDir, fileName));
  final parentDir = file.parent;
  if (!await parentDir.exists()) {
    await parentDir.create(recursive: true);
  }
  await file.writeAsString(buffer.toString());
  // logger?.info('Generated BackgroundJobManager Riverpod provider at ${file.path}');
  print('Generated BackgroundJobManager Riverpod provider at ${file.path}');
  print(
    'IMPORTANT: Review the generated file ${file.path} and ensure the `uiDatabaseConnectionProvider` is correctly referenced.',
  );
}
