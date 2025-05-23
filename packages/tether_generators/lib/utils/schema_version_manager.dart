import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tether_generators/config/config_model.dart';
import 'package:tether_libs/schema/table_info.dart';
import 'package:tether_libs/utils/logger.dart';

/// Manages loading, saving, and accessing historical schema versions.
class SchemaVersionManager {
  final SupabaseGenConfig config;
  final Logger _logger;
  final String _schemaVersionsDir;

  /// Stores the loaded schema states, keyed by version number.
  final Map<int, List<SupabaseTableInfo>> previousSchemaStates = {};

  /// The highest schema version found or determined.
  int currentSchemaVersion = 0;

  // Private constructor for singleton pattern
  SchemaVersionManager._internal({required this.config, Logger? logger})
    : _logger = logger ?? Logger('SchemaVersionManager'),
      _schemaVersionsDir = p.join(config.outputDirectory, 'schemas');

  // Static instance for singleton access
  static SchemaVersionManager? _instance;

  // Factory constructor to provide the singleton instance
  factory SchemaVersionManager({
    required SupabaseGenConfig config,
    Logger? logger,
  }) {
    _instance ??= SchemaVersionManager._internal(
      config: config,
      logger: logger,
    );
    // Ensure the config is updated if a new one is provided? Or enforce single config?
    // For simplicity, assume the first config used is the correct one for the lifetime.
    return _instance!;
  }

  /// Loads previous schema states from JSON files in the versions directory.
  Future<void> loadPreviousSchemas() async {
    previousSchemaStates.clear();
    final dir = Directory(_schemaVersionsDir);
    if (!await dir.exists()) {
      _logger.info(
        'Schema versions directory not found ($_schemaVersionsDir). Starting with version 1.',
      );
      currentSchemaVersion = 0; // Will become 1 on first generation
      return;
    }

    final regex = RegExp(r'schema_v(\d+)\.json$');
    int maxVersion = 0;

    try {
      final stream = dir.list(followLinks: false);
      await for (final entity in stream) {
        if (entity is File) {
          final match = regex.firstMatch(p.basename(entity.path));
          if (match != null) {
            final version = int.tryParse(match.group(1)!);
            if (version != null) {
              _logger.info(
                'Found schema file: ${entity.path} for version $version',
              );
              try {
                final content = await entity.readAsString();
                if (content.trim().isNotEmpty) {
                  final List<dynamic> jsonList = jsonDecode(content);
                  final tables =
                      jsonList
                          .map(
                            (item) => SupabaseTableInfo.fromJson(
                              item as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                  previousSchemaStates[version] = tables;
                  if (version > maxVersion) {
                    maxVersion = version;
                  }
                } else {
                  _logger.warning(
                    'Schema file ${entity.path} is empty. Ignoring.',
                  );
                }
              } catch (e, s) {
                _logger.severe(
                  'Failed to load or parse schema file ${entity.path}: $e',
                );
              }
            }
          }
        }
      }
    } catch (e, s) {
      _logger.severe(
        'Error listing schema version files in $_schemaVersionsDir: $e',
      );
    }

    currentSchemaVersion = maxVersion;
    _logger.info(
      'Loaded ${previousSchemaStates.length} previous schema versions. Current version determined as: $currentSchemaVersion.',
    );
  }

  /// Compares the current table list against the last known version.
  bool detectSchemaChanges(List<SupabaseTableInfo> currentTables) {
    final List<SupabaseTableInfo>? previousSchemaTables =
        previousSchemaStates[currentSchemaVersion];

    if (previousSchemaTables == null) {
      // No previous schema at the current version, so definitely changed (it's new or first load)
      return true;
    }

    // Simple comparison based on JSON representation
    final currentJson = JsonEncoder().convert(
      currentTables.map((t) => t.toJson()).toList(),
    );
    final previousJson = JsonEncoder().convert(
      previousSchemaTables.map((t) => t.toJson()).toList(),
    );

    if (currentJson != previousJson) {
      _logger.fine(
        'Schema JSON representation differs from previous version $currentSchemaVersion.',
      );
      // Add more detailed diff logging here if needed
      return true;
    }

    return false;
  }

  /// Saves the current schema state to a versioned JSON file.
  Future<void> saveSchemaVersion(
    int version,
    List<SupabaseTableInfo> tables,
  ) async {
    final filePath = p.join(_schemaVersionsDir, 'schema_v$version.json');
    _logger.info('Saving schema state for version $version to: $filePath');
    try {
      final file = File(filePath);
      await _ensureDirectoryExists(file.parent.path); // Ensure parent exists
      final jsonList = tables.map((t) => t.toJson()).toList();
      final content = JsonEncoder.withIndent('  ').convert(jsonList);
      await file.writeAsString(content);
      // Update internal state after successful save
      previousSchemaStates[version] = tables;
      if (version > currentSchemaVersion) {
        currentSchemaVersion = version;
      }
    } catch (e) {
      _logger.severe('Failed to save schema version file $filePath: $e');
    }
  }

  /// Ensures a directory exists, creating it if necessary.
  Future<void> _ensureDirectoryExists(String path) async {
    if (path.isEmpty) return;
    final dir = Directory(path);
    if (!await dir.exists()) {
      _logger.fine('Creating directory: $path');
      try {
        await dir.create(recursive: true);
      } catch (e) {
        _logger.severe('Failed to create directory $path: $e');
      }
    }
  }
}
