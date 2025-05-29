// lib/src/generator.dart
import 'dart:io';
import 'package:tether/generators/auth_manager_generator.dart';
import 'package:tether/generators/background_service_manager_generator.dart';
import 'package:tether/utils/schema_reader.dart';
import 'package:tether/utils/schema_version_manager.dart';
import 'package:tether_libs/utils/logger.dart';

import 'generators/client_manager_generator.dart';
import 'generators/core_migrations_generator.dart';
import 'generators/database_generator.dart';
import 'generators/feed_manager_generator.dart';
import 'generators/model_generator.dart';
import 'generators/feed_provider_generator.dart';
import 'generators/sqlite_schema_generator.dart';
import 'generators/supabase_select_builder_generator.dart';
import 'generators/user_preferences_manager_generator.dart';
import 'config/config_model.dart';

class SupabaseGenerator {
  final SupabaseGenConfig config;
  final Logger _logger = Logger('SupabaseGenerator');

  SupabaseGenerator(this.config);

  Future<void> generate() async {
    final outputDir = Directory(config.outputDirectory);
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
      _logger.info('Created output directory: ${config.outputDirectory}');
    }

    final schemaReader = SchemaReader(config);

    try {
      await schemaReader.connect();
      _logger.info(
        'Connected to database ${config.database} on ${config.host}:${config.port}',
      );

      final tables = await schemaReader.readTables();
      _logger.info('Read schema for ${tables.length} tables');

      // Generate Core SQLite Migration (e.g., for feed_item_references)
      // This runs first to define base tables if needed.
      final coreMigrationGenerator = CoreMigrationGenerator(config: config);
      await coreMigrationGenerator.generate();
      _logger.info('Generated core SQLite migration file (if applicable).');

      // Initialize schema version manager
      final schemaVersionManager = SchemaVersionManager(config: config);

      // Generate Sql (schema-derived migrations)
      final sqlGenerator = SqliteSchemaGenerator(
        config: config,
        schemaVersionManager: schemaVersionManager,
      );
      final latestMigrationVersion = await sqlGenerator.generate(tables);
      _logger.info(
        'Generated SQLite schema files up to version $latestMigrationVersion.',
      );

      // Generate database helper
      // The DatabaseGenerator needs to know the latest version to include all migrations
      final databaseGenerator = SqliteDatabaseGenerator(
        config: config,
        logger: _logger,
      );
      await databaseGenerator.generate();
      _logger.info('Generated SQLite database helper.');

      // Generate Models
      final modelGenerator = ModelGenerator(config: config);
      await modelGenerator.generate(tables);
      _logger.info('Generated models for ${tables.length} tables');

      // Generate Supabase selectors
      final supabaseSelectBuilderGenerator = SupabaseSelectBuilderGenerator(
        config: config,
        allTables: tables,
      );
      await supabaseSelectBuilderGenerator.generate();
      _logger.info('Generated Supabase select builders.');

      // Generate Client Managers
      await generateClientManagers(
        // Ensure this is awaited
        outputDirectory: config.outputDirectory,
        tables: tables,
        config: config,
      );
      _logger.info('Generated client managers for ${tables.length} tables.');

      // Generate Authentication Manager
      await generateAuthManagerFiles(config: config, allTables: tables);

      // Generate Feed Item Reference Manager
      final feedManagerGenerator = FeedManagerGenerator(config: config);
      await feedManagerGenerator.generate();
      _logger.info('Generated FeedItemReferenceManager (if applicable).');

      final userPrefsManagerGenerator = UserPreferencesManagerGenerator(
        config: config,
      );
      await userPrefsManagerGenerator.generate();
      _logger.info('Generated UserPreferencesManager (if applicable).');

      // Generate Background Services
      if (config.generateBackgroundServices) {
        await generateBackgroundJobManagerProviderFile;
        _logger.info('Generated background provider for FeedManager.');
      }

      // Generate providers
      if (config.generateProviders) {
        final feedProvider = FeedProviderGenerator(
          outputDirectory:
              config
                  .providersDirectoryPath, // Adjust if your project structure is different
        );
        await feedProvider.generate();
      }

      _logger.info('Code generation complete.');
    } finally {
      await schemaReader.disconnect();
    }
  }
}
