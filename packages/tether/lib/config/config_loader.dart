// lib/src/config/config_loader.dart
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:dotenv/dotenv.dart' as dotenv; // Import dotenv
import 'config_model.dart';

class ConfigLoader {
  /// Loads configuration from a YAML file and environment variables.
  ///
  /// [filePath]: Path to the YAML configuration file.
  /// [dotEnvPath]: Path to the .env file. Defaults to '.env' in the current directory.
  static SupabaseGenConfig fromFile(
    String filePath, {
    String dotEnvPath = '.env',
  }) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('Configuration file not found', filePath);
    }

    final yamlContent = file.readAsStringSync();
    final yamlMap = loadYaml(yamlContent);

    if (yamlMap is! Map) {
      throw FormatException('YAML content does not represent a Map', filePath);
    }
    final configMap = _convertYamlToMap(yamlMap);

    // Load .env file.
    // Create a DotEnv instance, allow it to also read platform environment variables as fallback.
    final envLoader = dotenv.DotEnv(includePlatformEnvironment: true);
    // Check if the .env file exists before trying to load it to prevent errors if it's optional
    // or if platform env vars are the primary source.
    if (File(dotEnvPath).existsSync()) {
      envLoader.load([dotEnvPath]);
    } else {
      print(
        "Info: .env file not found at '$dotEnvPath'. Relying on platform environment variables if any.",
      );
    }

    // envLoader.map will contain variables from .env file (if loaded) and platform environment.
    // Variables from .env file take precedence over platform environment variables with the same name.
    final envVars = envLoader.map;

    return SupabaseGenConfig.fromYaml(configMap, envVars);
  }

  /// Creates a sample configuration file (`supabase_gen.yaml`) at the specified [filePath].
  ///
  /// This sample includes sections for database connection, general generation settings,
  /// model generation, and Drift migration generation settings.
  ///
  /// Throws a [FileSystemException] if a file already exists at the path.
  static Future<void> createSampleConfig(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      // Use await file.exists() for async check
      print(
        'Warning: Configuration file already exists at $filePath. Not overwriting.',
      );
      // Or throw: throw FileSystemException('Configuration file already exists', filePath);
      return;
    }

    try {
      // Ensure the directory for the config file exists
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      // Updated sample config content
      const String sampleConfigContent = """
# --- Database Connection Details ---
# Specifies how to connect to your Supabase (<PostgreSQL>) database to read its schema.
# Values for database connection are loaded from environment variables.
# Create a .env file in the root of the 'tether' package (or specify its path)
# with the actual credentials.
database:
  host_env_var: SUPABASE_DB_HOST          # Default: SUPABASE_DB_HOST
  port_env_var: SUPABASE_DB_PORT          # Default: SUPABASE_DB_PORT
  database_env_var: SUPABASE_DB_NAME      # Default: SUPABASE_DB_NAME
  username_env_var: SUPABASE_DB_USER      # Default: SUPABASE_DB_USER
  password_env_var: SUPABASE_DB_PASSWORD  # Default: SUPABASE_DB_PASSWORD
  ssl: false                              # SSL for DB connection (can also be an env var if needed)

# --- General Code Generation Settings ---
generation:
  output_directory: lib/database
  exclude_tables:
    - migrations 
    - schema_migrations
  include_tables: []
  exclude_references: []
  generate_for_all_tables: true
  dbClassName: AppDb
  databaseName: 'app_db.sqlite'
  database_import_path: 'package:example/database/database.dart' # Adjust 'example' to your actual package name.
  models:
    enabled: true
    filename: models.g.dart
    prefix: ''
    suffix: Model
    use_null_safety: true
  supabase_select_builders:
    enabled: true
    filename: 'supabase_select_builders.g.dart'
    generated_schema_dart_file_path: 'lib/database/supabase_schema.g.dart'
    suffix: SelectBuilder
  supabase_select_builders_import_path: 'package:example/database/supabase_select_builders.g.dart' # Adjust 'example'
  schema_registry_file_path: 'lib/database/schema_registry.g.dart'
  sqlite_migrations:
    enabled: true
    output_subdir: 'sqlite_migrations' # Typically 'assets/sqlite_migrations' or 'lib/database/migrations'
  client_managers:
    enabled: true
    use_riverpod: true
  providers:
    enabled: true
    output_subdir: 'providers'
  authentication: # Top-level key
    enabled: true
    profile_table: 'profiles'
  background_services: # Top-level key
    enabled: true
  sanitization_endings:
    - _id
    - _fk
    - _uuid
""";
      await file.writeAsString(sampleConfigContent);
      print(
        'Sample configuration file (referencing .env variables) created at: $filePath',
      );
      print(
        'Please ensure you have a .env file with your actual database credentials.',
      );
    } catch (e) {
      print('Error creating sample configuration file at $filePath: $e');
    }
  }

  /// Recursively converts a [YamlMap] or [YamlList] into a standard Dart
  /// [Map<String, dynamic>] or [List<dynamic>].
  ///
  /// This is necessary because the `loadYaml` function returns specialized
  /// types from the `yaml` package.
  static dynamic _convertNode(dynamic node) {
    if (node is Map) {
      // Handle potential YamlMap explicitly
      return _convertYamlToMap(node);
    } else if (node is YamlList) {
      // Handle YamlList explicitly
      return node.map(_convertNode).toList();
    } else if (node is List) {
      // Handle standard List just in case
      return node.map(_convertNode).toList();
    } else {
      // Return primitive types directly
      return node;
    }
  }

  /// Converts a [YamlMap] (or standard [Map]) into a [Map<String, dynamic>].
  static Map<String, dynamic> _convertYamlToMap(Map yamlMap) {
    final result = <String, dynamic>{};
    for (final entry in yamlMap.entries) {
      // Ensure keys are strings
      final key = entry.key.toString();
      // Recursively convert values
      result[key] = _convertNode(entry.value);
    }
    return result;
  }
}
