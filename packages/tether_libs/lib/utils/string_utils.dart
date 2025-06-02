// lib/src/utils/string_utils.dart
import 'package:recase/recase.dart';

/// A utility class for string manipulation, focusing on case conversions
/// and formatting relevant to code generation (e.g., from database names
/// to Dart conventions).
class StringUtils {
  /// Converts a string (typically a database table or column name) to a Dart class name
  /// convention (PascalCase or UpperCamelCase).
  ///
  /// An optional [prefix] and/or [suffix] can be added to the generated class name.
  ///
  /// Examples:
  /// ```dart
  /// StringUtils.toClassName("user_profiles") // "UserProfiles"
  /// StringUtils.toClassName("user_profiles", prefix: "Db") // "DbUserProfiles"
  /// StringUtils.toClassName("categories", suffix: "Table") // "CategoriesTable"
  /// ```
  static String toClassName(String name, {String? prefix, String? suffix}) {
    final className = ReCase(name).pascalCase;
    return '${prefix ?? ''}$className${suffix ?? ''}';
  }

  /// Converts a string (typically a database column name) to a Dart variable name
  /// convention (camelCase).
  ///
  /// Example:
  /// ```dart
  /// StringUtils.toVariableName("user_id") // "userId"
  /// StringUtils.toVariableName("first_name") // "firstName"
  /// ```
  static String toVariableName(String name) {
    return ReCase(name).camelCase;
  }

  /// Converts a string (typically a class or concept name) to a Dart file name
  /// convention (snake_case).
  ///
  /// Example:
  /// ```dart
  /// StringUtils.toFileName("UserProfile") // "user_profile"
  /// StringUtils.toFileName("AuthService") // "auth_service"
  /// ```
  static String toFileName(String name) {
    return ReCase(name).snakeCase;
  }

  /// Converts a string to PascalCase (UpperCamelCase).
  ///
  /// This is a common convention for class names in Dart.
  ///
  /// Example:
  /// ```dart
  /// StringUtils.toPascalCase("user_profile") // "UserProfile"
  /// StringUtils.toPascalCase("user") // "User"
  /// StringUtils.toPascalCase("APIClient") // "ApiClient" (if ReCase handles it this way)
  /// ```
  static String toPascalCase(String text) {
    if (text.isEmpty) return '';
    // Use ReCase for consistent PascalCase conversion
    return ReCase(text).pascalCase;
  }

  /// Capitalizes the first letter of a string.
  ///
  /// Example:
  /// ```dart
  /// StringUtils.capitalize("hello") // "Hello"
  /// StringUtils.capitalize("World") // "World"
  /// ```
  static String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Attempts to make a word singular using common English pluralization rules.
  ///
  /// This is a basic implementation and may not handle all irregular plurals
  /// (e.g., \'children\', \'mice\') or complex cases perfectly. It includes specific
  /// exceptions for words like "address" or "status" that should not be changed,
  /// and words ending in "us", "ss", "is".
  ///
  /// Rules applied:
  /// - `ies` -> `y` (e.g., stories -> story)
  /// - `ches`, `shes`, `xes`, `zes` -> remove `es` (e.g., boxes -> box)
  /// - `s` -> remove `s` (e.g., cats -> cat) - applied last.
  ///
  /// Example:
  /// ```dart
  /// StringUtils.singularize("stories") // "story"
  /// StringUtils.singularize("boxes") // "box"
  /// StringUtils.singularize("cats") // "cat"
  /// StringUtils.singularize("status") // "status"
  /// ```
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
  ///
  /// This is a basic implementation and won\'t handle all irregular plurals
  /// or complex cases perfectly. It avoids pluralizing words that already seem
  /// to be plural (basic check for ending in \'s\').
  ///
  /// Rules applied:
  /// - Words ending in \'y\' preceded by a consonant: `y` -> `ies` (e.g., story -> stories).
  /// - Words ending in \'y\' preceded by a vowel: add `s` (e.g., boy -> boys).
  /// - Words ending in `s`, `x`, `z`, `ch`, `sh`: add `es` (e.g., box -> boxes).
  /// - Default: add `s` (e.g., cat -> cats).
  ///
  /// Example:
  /// ```dart
  /// StringUtils.pluralize("story") // "stories"
  /// StringUtils.pluralize("box") // "boxes"
  /// StringUtils.pluralize("cat") // "cats"
  /// StringUtils.pluralize("statuses") // "statuses" (no change)
  /// ```
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

  /// Creates a Dart import statement string for the given [path].
  ///
  /// Example:
  /// ```dart
  /// StringUtils.createImport("package:example_project/models/user.dart")
  /// // returns "import \'package:example_project/models/user.dart\';"
  /// ```
  static String createImport(String path) {
    return "import '$path';";
  }

  /// Converts a string to camelCase.
  ///
  /// This method first replaces any sequence of non-alphanumeric characters
  /// with a single underscore, then splits the string by underscores.
  /// The first part is lowercased, and subsequent parts are capitalized.
  ///
  /// Example:
  /// ```dart
  /// StringUtils.toCamelCase("user_profile_id") // "userProfileId"
  /// StringUtils.toCamelCase("User-Profile-ID") // "userProfileId"
  /// StringUtils.toCamelCase("firstName") // "firstName"
  /// ```
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

  /// Creates a Dart-style documentation comment (doc comment) from a string.
  ///
  /// If the [comment] is null or empty, returns null.
  /// Single-line comments are prefixed with `/// `.
  /// Multi-line comments are formatted with `///` at the beginning of each line.
  ///
  /// Example:
  /// ```dart
  /// StringUtils.createDocComment("This is a user profile.")
  /// // returns "/// This is a user profile."
  ///
  /// StringUtils.createDocComment("First line.\nSecond line.")
  /// // returns:
  /// // /// First line.
  /// // /// Second line.
  /// ```
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

/// Prints a long string to the console by breaking it into chunks.
///
/// This can be useful for debugging or logging very long strings that might
/// otherwise be truncated by the console output limit.
/// Each chunk will be at most 800 characters long.
void printLongString(String text) {
  final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern
      .allMatches(text)
      .forEach((RegExpMatch match) => print(match.group(0)));
}
