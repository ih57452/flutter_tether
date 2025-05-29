// lib/src/utils/string_utils.dart
import 'package:recase/recase.dart';

class StringUtils {
  /// Convert a database name to a Dart class name (PascalCase)
  static String toClassName(String name, {String? prefix, String? suffix}) {
    final className = ReCase(name).pascalCase;
    return '${prefix ?? ''}$className${suffix ?? ''}';
  }

  /// Convert a database name to a Dart variable name (camelCase)
  static String toVariableName(String name) {
    return ReCase(name).camelCase;
  }

  /// Convert a database name to a Dart file name (snake_case)
  static String toFileName(String name) {
    return ReCase(name).snakeCase;
  }

  /// Convert a string to PascalCase (UpperCamelCase).
  /// E.g., "user_profile" becomes "UserProfile", "user" becomes "User".
  static String toPascalCase(String text) {
    if (text.isEmpty) return '';
    // Use ReCase for consistent PascalCase conversion
    return ReCase(text).pascalCase;
  }

  /// Capitalizes the first letter of a string.
  static String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Attempts to make a word singular using common English pluralization rules.
  /// Note: This is a basic implementation and won't handle all irregular plurals
  /// (e.g., 'children', 'mice') or complex cases perfectly.
  static String singularize(String word) {
    if (word.isEmpty) {
      return word;
    }

    // Handle specific cases that shouldn't be singularized or have exceptions
    if (word.toLowerCase() == 'address' || word.toLowerCase() == 'status') {
      return word;
    }
    if (word.toLowerCase().endsWith('us') ||
        word.toLowerCase().endsWith('ss') ||
        word.toLowerCase().endsWith('is')) {
      // Avoid changing words like 'bus', 'address', 'analysis'
      return word;
    }

    // Rule: 'ies' -> 'y' (e.g., stories -> story)
    if (word.endsWith('ies')) {
      return '${word.substring(0, word.length - 3)}y';
    }

    // Rule: 'es' -> '' (e.g., boxes -> box, wishes -> wish)
    // Be careful not to remove 'es' if the singular ends in 'e' (e.g. 'addresses') - handled above
    if (word.endsWith('es')) {
      // Check for common cases like 'ches', 'shes', 'xes', 'zes'
      if (word.endsWith('ches') ||
          word.endsWith('shes') ||
          word.endsWith('xes') ||
          word.endsWith('zes')) {
        return word.substring(0, word.length - 2);
      }
      // Potentially other 'es' cases, but be cautious. For now, only handle the common ones.
      // If it ends in 'es' but not the above, maybe just remove 's'?
      // return word.substring(0, word.length - 1); // Alternative: just remove 's'
    }

    // Rule: 's' -> '' (e.g., cats -> cat)
    // This is the most basic rule, applied last.
    if (word.endsWith('s')) {
      return word.substring(0, word.length - 1);
    }

    // Add more rules here if needed (e.g., 'ves' -> 'f'/'fe')

    // Return original if no rule applies
    return word;
  }

  /// Attempts to make a word plural using common English pluralization rules.
  /// Note: This is a basic implementation and won't handle all irregular plurals
  /// or complex cases perfectly. It also avoids pluralizing words already ending in 's'.
  static String pluralize(String word) {
    if (word.isEmpty) {
      return word;
    }

    final lowerWord = word.toLowerCase();

    // Rule: Don't pluralize if already ends in 's' (basic check)
    if (lowerWord.endsWith('s')) {
      return word;
    }

    // Add specific irregular plurals here if needed
    // Example:
    // if (lowerWord == 'person') return 'people';
    // if (lowerWord == 'child') return 'children';
    // if (lowerWord == 'man') return 'men';
    // if (lowerWord == 'woman') return 'women';
    // if (lowerWord == 'mouse') return 'mice';
    // if (lowerWord == 'goose') return 'geese';
    // if (lowerWord == 'foot') return 'feet';
    // if (lowerWord == 'tooth') return 'teeth';

    // Rule: Words ending in 'y' preceded by a consonant -> 'ies'
    if (lowerWord.endsWith('y')) {
      if (word.length > 1 &&
          !'aeiou'.contains(lowerWord[lowerWord.length - 2])) {
        return '${word.substring(0, word.length - 1)}ies';
      } else {
        // If 'y' is preceded by a vowel, just add 's' (e.g., boy -> boys)
        return '${word}s';
      }
    }

    // Rule: Words ending in 's', 'x', 'z', 'ch', 'sh' -> add 'es'
    if (lowerWord.endsWith('s') ||
        lowerWord.endsWith('x') ||
        lowerWord.endsWith('z') ||
        lowerWord.endsWith('ch') ||
        lowerWord.endsWith('sh')) {
      return '${word}es';
    }

    // Default rule: Add 's'
    return '${word}s';
  }

  /// Create a Dart import statement
  static String createImport(String path) {
    return "import '$path';";
  }

  static String toCamelCase(String text) {
    if (text.isEmpty) return '';
    // Replace any non-alphanumeric sequence used as separator with a single underscore
    final safeText = text.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    // Split by underscore
    List<String> parts =
        safeText.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';

    // First part lowercase, subsequent parts capitalized
    String result = parts.first.toLowerCase();
    for (int i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        result +=
            parts[i][0].toUpperCase() + parts[i].substring(1).toLowerCase();
      }
    }
    return result;
  }

  /// Create a document comment
  static String? createDocComment(String? comment) {
    if (comment == null || comment.isEmpty) return null;

    final lines = comment.split('\n');
    if (lines.length == 1) {
      return '/// $comment';
    } else {
      return '''
/// ${lines.join('\n/// ')}
''';
    }
  }
}

/// Print Long String
void printLongString(String text) {
  final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern
      .allMatches(text)
      .forEach((RegExpMatch match) => print(match.group(0)));
}
