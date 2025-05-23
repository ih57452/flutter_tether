// lib/src/config/config_loader.dart
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'config_model.dart'; // Assuming config_model.dart contains the updated SupabaseGenConfig

class ConfigLoader {
  /// Loads configuration from a YAML file at the specified [filePath].
  ///
  /// Throws a [FileSystemException] if the file is not found.
  /// Parses the YAML content and uses [SupabaseGenConfig.fromYaml] to create
  /// the configuration object.
  static SupabaseGenConfig fromFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('Configuration file not found', filePath);
    }

    final yamlContent = file.readAsStringSync();
    // loadYaml returns YamlMap which needs conversion
    final yamlMap = loadYaml(yamlContent);

    // Ensure the loaded content is a Map before converting
    if (yamlMap is! Map) {
      throw FormatException('YAML content does not represent a Map', filePath);
    }

    // Convert YamlMap and nested structures to regular Map<String, dynamic>
    final configMap = _convertYamlToMap(yamlMap);

    // Use the factory constructor from the updated SupabaseGenConfig
    // No changes needed here, the factory handles the parsing logic.
    return SupabaseGenConfig.fromYaml(configMap);
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
          'Warning: Configuration file already exists at $filePath. Not overwriting.');
      // Or throw: throw FileSystemException('Configuration file already exists', filePath);
      return;
    }

    try {
      // Ensure the directory for the config file exists
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      // Define the path to the sample configuration file relative to the project root
      // Adjust this path if necessary based on your project structure
      const sampleConfigPath = 'config/sample_config.yaml';
      final sampleConfigFile = File(sampleConfigPath);

      if (!await sampleConfigFile.exists()) {
        print(
            'Error: Sample configuration file not found at $sampleConfigPath');
        // Optionally, throw an exception or handle this case differently
        // throw FileSystemException('Sample configuration file not found', sampleConfigPath);
        return; // Exit if sample config is missing
      }

      final sampleConfigContent = await sampleConfigFile.readAsString();

      // Write the loaded sample configuration content to the target file
      await file.writeAsString(sampleConfigContent);
      print('Sample configuration file created at: $filePath');
    } catch (e) {
      print('Error creating sample configuration file at $filePath: $e');
      // Re-throw if needed, or handle appropriately
      // throw e;
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
