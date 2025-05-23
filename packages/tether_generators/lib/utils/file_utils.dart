import 'dart:developer';
import 'dart:io';

// Asynchronous method (recommended for most cases, especially Flutter)
Future<String> readFileAsync(String filePath) async {
  try {
    final file = File(filePath);
    // Check if file exists before reading
    if (await file.exists()) {
      // Read the entire file content as a string (UTF-8 encoding by default)
      final contents = await file.readAsString();
      return contents;
    } else {
      // Handle file not found error
      log('Error: File not found at $filePath');
      return ''; // Or throw an exception
    }
  } catch (e) {
    // Handle potential errors during file reading
    log('Error reading file $filePath: $e');
    return ''; // Or throw an exception
  }
}

// Synchronous method (use with caution, blocks the current isolate)
String readFileSync(String filePath) {
  try {
    final file = File(filePath);
    // Check if file exists before reading
    if (file.existsSync()) {
      // Read the entire file content as a string (UTF-8 encoding by default)
      final contents = file.readAsStringSync();
      return contents;
    } else {
      // Handle file not found error
      log('Error: File not found at $filePath');
      return ''; // Or throw an exception
    }
  } catch (e) {
    // Handle potential errors during file reading
    log('Error reading file $filePath: $e');
    return ''; // Or throw an exception
  }
}
