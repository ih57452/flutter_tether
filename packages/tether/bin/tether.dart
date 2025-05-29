// bin/supabase_gen.dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:tether/config/config_loader.dart';
import 'package:tether/generator.dart';
import 'package:tether_libs/utils/logger.dart';

Future<void> main(List<String> arguments) async {
  final parser =
      ArgParser()
        ..addFlag(
          'help',
          abbr: 'h',
          help: 'Print this usage information',
          negatable: false,
        )
        ..addFlag(
          'version',
          abbr: 'v',
          help: 'Print the version',
          negatable: false,
        )
        ..addOption('config', abbr: 'c', help: 'Path to configuration file')
        ..addFlag(
          'init',
          help: 'Create a sample configuration file',
          negatable: false,
        );

  try {
    final results = parser.parse(arguments);

    if (results['help']) {
      _printUsage(parser);
      return;
    }

    if (results['version']) {
      print('supabase_gen version 0.1.0');
      return;
    }

    if (results['init']) {
      final configPath = results['config'] as String? ?? 'supabase_gen.yaml';
      await ConfigLoader.createSampleConfig(configPath);
      print('Created sample configuration file at $configPath');
      return;
    }

    if (results['config'] == null) {
      print('Error: Missing required option --config');
      _printUsage(parser);
      exit(1);
    }

    final configPath = results['config'] as String;

    // Initialize logging
    Logger.initializeLogging();
    final logger = Logger('SupabaseGen');

    logger.info('Starting Supabase code generation');

    try {
      // Load configuration
      final config = ConfigLoader.fromFile(configPath);
      logger.info('Loaded configuration from $configPath');

      // Create generator
      final generator = SupabaseGenerator(config);

      // Run generation
      await generator.generate();

      logger.info('Code generation completed successfully');
    } catch (e, stackTrace) {
      logger.severe('Error during code generation: $e');
      logger.severe('Stack trace: $stackTrace');
      exit(1);
    }
  } catch (e) {
    print('Error: $e');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Usage: supabase_gen [options]');
  print(parser.usage);
}
