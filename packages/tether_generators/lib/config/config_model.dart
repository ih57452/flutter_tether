// lib/src/config/config_model.dart
import 'package:path/path.dart' as p;

class SupabaseGenConfig {
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  final bool ssl;
  final String outputDirectory;
  final List<String> excludeTables;
  final List<String> includeTables;
  final List<String> excludeReferences;
  final bool generateForAllTables;

  // --- Database Settings ---
  final String dbClassName;
  final String databaseName;
  final bool generateSupabaseSelectBuilders;
  final String supabaseSelectBuildersFilePath;
  final String generatedSupabaseSchemaDartFilePath;

  // --- Model Settings ---
  final bool generateModels;
  final String modelsFileName;
  final String? modelPrefix;
  final String? modelSuffix;
  final bool useNullSafety;
  final String? repositorySuffix;

  // --- SQLite Migration Settings ---
  final bool generateSqliteMigrations;
  final String sqliteMigrationsSubDir;

  // --- SSchema Settings ---
  final String schemaRegistryFilePath;
  final String databaseImportPath;
  final String supabaseSelectBuildersImportPath;
  final List<String> sanitizationEndings;

  // --- ClientManager Settings ---
  final bool generateClientManagers;
  final bool useRiverpod;

  // --- Provider Settings ---
  final String providersSubDir;
  final bool generateProviders;

  const SupabaseGenConfig({
    // Database, General...
    required this.host,
    this.port = 5432,
    required this.database,
    required this.username,
    required this.password,
    this.ssl = false,
    required this.outputDirectory,
    this.excludeTables = const ['migrations', 'schema_migrations'],
    this.includeTables = const [],
    this.excludeReferences = const [],
    this.generateForAllTables = true,

    // Models, Repositories...
    this.generateModels = true,
    this.modelsFileName = 'models.dart',
    this.modelPrefix = '',
    this.modelSuffix = 'Model',
    this.useNullSafety = true,
    this.repositorySuffix = 'Repository',

    // Database Settings
    this.dbClassName = 'AppDb',
    this.databaseName = 'app_db.sqlite',
    this.generateSupabaseSelectBuilders = false,
    this.supabaseSelectBuildersFilePath =
        'lib/database/supabase_select_builders.dart',
    this.generatedSupabaseSchemaDartFilePath = 'supabase_schema.dart',

    // SQLite Migration Settings
    this.generateSqliteMigrations = false,
    this.sqliteMigrationsSubDir = 'assets/sqlite_migrations',

    // NEW FIELDS
    this.schemaRegistryFilePath = 'lib/database/schema_registry.dart',
    this.databaseImportPath = '../database/my_database.dart',
    this.supabaseSelectBuildersImportPath =
        '../database/supabase_select_builders.dart',
    this.sanitizationEndings = const ['_id', '_fk'],

    // --- ClientManager Settings ---
    this.generateClientManagers = false,
    this.useRiverpod = true,

    // --- Provider Settings ---
    this.providersSubDir = 'providers', // <<< NEW FIELD DEFAULT
    this.generateProviders = true,
  });

  factory SupabaseGenConfig.fromYaml(Map<String, dynamic> yaml) {
    final dbConfig = yaml['database'] as Map<String, dynamic>? ?? {};
    final genConfig = yaml['generation'] as Map<String, dynamic>? ?? {};
    final modelConfig = genConfig['models'] as Map<String, dynamic>? ?? {};
    final sqliteConfig =
        genConfig['sqlite_migrations'] as Map<String, dynamic>? ?? {};
    final selectBuildersConfig =
        genConfig['supabase_select_builders'] as Map<String, dynamic>? ?? {};
    final clientManagerConfig =
        genConfig['client_managers'] as Map<String, dynamic>? ?? {};
    final providerConfig =
        genConfig['providers'] as Map<String, dynamic>? ?? {};
    final outputDir = // This correctly uses genConfig['output_directory'] or defaults
        genConfig['output_directory'] as String? ?? 'lib/database';

    return SupabaseGenConfig(
      // Database, General...
      host: dbConfig['host'] as String? ?? 'localhost',
      port: dbConfig['port'] as int? ?? 5432,
      database: dbConfig['database'] as String? ?? '',
      username: dbConfig['username'] as String? ?? '',
      password: dbConfig['password'] as String? ?? '',
      ssl: dbConfig['ssl'] as bool? ?? false,
      outputDirectory: outputDir,
      excludeTables: List<String>.from(genConfig['exclude_tables'] as List? ??
          ['migrations', 'schema_migrations']),
      includeTables:
          List<String>.from(genConfig['include_tables'] as List? ?? []),
      excludeReferences:
          List<String>.from(genConfig['exclude_references'] as List? ?? []),
      generateForAllTables:
          genConfig['generate_for_all_tables'] as bool? ?? true,

      // Models, Repositories...
      generateModels: modelConfig['enabled'] as bool? ?? true,
      modelsFileName: modelConfig['filename'] as String? ?? 'models.dart',
      modelPrefix: modelConfig['prefix'] as String? ?? '',
      modelSuffix: modelConfig['suffix'] as String? ?? 'Model',
      useNullSafety: modelConfig['use_null_safety'] as bool? ?? true,
      repositorySuffix:
          genConfig['repository_suffix'] as String? ?? 'Repository',

      // SQLite Migration Settings
      generateSqliteMigrations: sqliteConfig['enabled'] as bool? ?? false,
      sqliteMigrationsSubDir: sqliteConfig['output_subdir'] as String? ??
          'assets/sqlite_migrations',

      generateSupabaseSelectBuilders:
          selectBuildersConfig['enabled'] as bool? ?? false,
      supabaseSelectBuildersFilePath:
          selectBuildersConfig['output_path'] as String? ??
              p.join(outputDir, 'supabase_select_builders.dart'),
      // Corrected generatedSupabaseSchemaDartFilePath construction:
      // If 'generated_schema_dart_file_path' is in selectBuildersConfig, use it directly.
      // Otherwise, join outputDir with a default filename 'supabase_schema.dart'.
      generatedSupabaseSchemaDartFilePath:
          selectBuildersConfig['generated_schema_dart_file_path'] as String? ??
              p.join(outputDir, 'supabase_schema.dart'),

      // NEW FIELDS
      schemaRegistryFilePath:
          genConfig['schema_registry_file_path'] as String? ??
              p.join(outputDir, 'schema_registry.dart'),
      supabaseSelectBuildersImportPath:
          genConfig['supabase_select_builders_import_path'] as String? ??
              '../supabase_select_builders.dart',
      sanitizationEndings: List<String>.from(
        genConfig['sanitization_endings'] as List? ?? ['_id', '_fk'],
      ),

      // --- ClientManager Settings ---
      generateClientManagers: clientManagerConfig['enabled'] as bool? ?? false,
      useRiverpod: clientManagerConfig['use_riverpod'] as bool? ?? true,

      // --- Provider Settings ---
      providersSubDir:
          providerConfig['output_subdir'] as String? ?? 'providers',
      generateProviders: providerConfig['enabled'] as bool? ?? true,
    );
  }

  // --- Existing Helper Getters ---
  String get modelsFilePath => p.join(outputDirectory, modelsFileName);

  // --- NEW Helper Getter for SQLite Migrations ---
  String get sqliteMigrationsDirectory => sqliteMigrationsSubDir;

  // --- NEW Helper Getter for Providers ---
  String get providersDirectoryPath => // <<< NEW HELPER
      p.join(outputDirectory, providersSubDir);
}
