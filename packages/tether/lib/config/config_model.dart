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
  final List<String> sanitizationEndings;

  // --- ClientManager Settings ---
  final bool generateClientManagers;
  final bool useRiverpod;

  // --- Provider Settings ---
  final String providersSubDir;
  final bool generateProviders;

  // --- Authentication Settings ---
  final bool generateAuthentication;
  final String authProfileTableName;

  // --- Background Services Settings ---
  final bool generateBackgroundServices;

  const SupabaseGenConfig({
    // Database, General...
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    required this.ssl,
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
        'lib/database/supabase_select_builders.g.dart',
    this.generatedSupabaseSchemaDartFilePath =
        'lib/database/supabase_schema.dart',

    // SQLite Migration Settings
    this.generateSqliteMigrations = false,
    this.sqliteMigrationsSubDir = 'assets/sqlite_migrations',

    this.schemaRegistryFilePath = 'lib/database/schema_registry.dart',
    this.databaseImportPath = '../database/my_database.dart',

    this.sanitizationEndings = const ['_id', '_fk'],

    // --- ClientManager Settings ---
    this.generateClientManagers = false,
    this.useRiverpod = true,

    // --- Provider Settings ---
    this.providersSubDir = 'providers', // <<< NEW FIELD DEFAULT
    this.generateProviders = true,

    // --- Authentication Settings ---
    this.generateAuthentication = true, // Default to false
    this.authProfileTableName = 'profiles', // Default table name
    // --- Background Services Settings ---
    this.generateBackgroundServices = true, // Default to true
  });

  factory SupabaseGenConfig.fromYaml(
    Map<String, dynamic> yaml,
    Map<String, dynamic> envVars,
  ) {
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
    final authConfig =
        genConfig['authentication'] as Map<String, dynamic>? ?? {};
    final backgroundConfig =
        genConfig['background_services'] as Map<String, dynamic>? ?? {};

    return SupabaseGenConfig(
      // Database, General...
      host: envVars[dbConfig['host'] as String] as String? ?? 'localhost',
      port: int.tryParse(envVars[dbConfig['port'] as String]) ?? 5432,
      database:
          envVars[dbConfig['database'] as String] as String? ?? 'postgres',
      username:
          envVars[dbConfig['username'] as String] as String? ?? 'postgres',
      password:
          envVars[dbConfig['password'] as String] as String? ?? 'postgres',
      ssl: bool.tryParse(envVars[dbConfig['ssl'] as String]) ?? false,
      outputDirectory: outputDir,
      excludeTables: List<String>.from(
        genConfig['exclude_tables'] as List? ??
            ['migrations', 'schema_migrations'],
      ),
      includeTables: List<String>.from(
        genConfig['include_tables'] as List? ?? [],
      ),
      excludeReferences: List<String>.from(
        genConfig['exclude_references'] as List? ?? [],
      ),
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
      sqliteMigrationsSubDir:
          sqliteConfig['output_subdir'] as String? ??
          'assets/sqlite_migrations',

      generateSupabaseSelectBuilders:
          selectBuildersConfig['enabled'] as bool? ?? false,
      supabaseSelectBuildersFilePath:
          selectBuildersConfig['output_path'] as String? ??
          p.join(outputDir, 'supabase_select_builders.g.dart'),
      generatedSupabaseSchemaDartFilePath:
          p.join(
                outputDir,
                selectBuildersConfig['generated_schema_dart_file_name']
                        as String? ??
                    'supabase_schema.dart',
              )
              as String? ??
          p.join(outputDir, 'supabase_schema.dart'),
      schemaRegistryFilePath:
          p.join(outputDir, genConfig['schema_registry_file_name'])
              as String? ??
          p.join(outputDir, 'schema_registry.dart'),
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

      // --- Authentication Settings ---
      generateAuthentication: authConfig['enabled'] as bool? ?? true,
      authProfileTableName:
          authConfig['profile_table'] as String? ?? 'profiles',

      // --- Background Services Settings ---
      generateBackgroundServices: backgroundConfig['enabled'] as bool? ?? true,
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
