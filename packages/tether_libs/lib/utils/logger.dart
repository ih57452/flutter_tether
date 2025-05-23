// lib/src/utils/logger.dart
import 'dart:convert';

import 'package:logging/logging.dart' as logging;

class Logger {
  static final Map<String, Logger> _loggers = {};

  final logging.Logger _logger;

  factory Logger(String name) {
    if (_loggers.containsKey(name)) {
      return _loggers[name]!;
    }

    final logger = Logger._internal(name);
    _loggers[name] = logger;
    return logger;
  }

  Logger._internal(String name) : _logger = logging.Logger(name);

  static void initializeLogging() {
    logging.hierarchicalLoggingEnabled = true;
    logging.Logger.root.level = logging.Level.INFO;
    logging.Logger.root.onRecord.listen((record) {
      print(
          '${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}');
    });
  }

  void info(String message) => _logger.info(message);
  void warning(String message) => _logger.warning(message);
  void severe(String message) => _logger.severe(message);
  void fine(String message) => _logger.fine(message);
}

JsonDecoder decoder = JsonDecoder();
JsonEncoder encoder = JsonEncoder.withIndent('  ');

void prettyPrintJson(String input) {
  var object = decoder.convert(input);
  var prettyString = encoder.convert(object);
  prettyString.split('\n').forEach((element) => print(element));
}
