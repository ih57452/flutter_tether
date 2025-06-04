---
sidebar_position: 3
---

# User Preferences Manager

The `UserPreferencesManager` is a powerful utility class that provides a
type-safe, reactive way to store and manage user preferences in your Flutter
application. It uses a local SQLite database to persist key-value pairs with
automatic JSON serialization/deserialization and supports streaming updates for
reactive UI components.

## Overview

`UserPreferencesManager` simplifies user preference management by:

- **Type-Safe Storage**: Store any JSON-serializable data with compile-time type
  safety
- **Automatic Serialization**: Handles JSON encoding/decoding automatically
- **Reactive Streams**: Watch preferences for real-time UI updates
- **Default Values**: Easily set up default preferences on first app launch
- **Rich Data Types**: Support for primitives, arrays, and complex objects
- **Upsert Operations**: Automatically creates or updates preferences

## Supported Data Types

The manager supports seven data types through `UserPreferenceValueTypes`:

| Type        | Constant      | Use Case          | Example               |
| ----------- | ------------- | ----------------- | --------------------- |
| Text        | `TEXT`        | Simple strings    | User names, themes    |
| Integer     | `INTEGER`     | Whole numbers     | Counters, IDs         |
| Real        | `REAL`        | Decimal numbers   | Ratings, percentages  |
| Boolean     | `BOOLEAN`     | True/false values | Feature toggles       |
| Text Array  | `TEXT_ARRAY`  | Lists of strings  | Favorite categories   |
| JSON Object | `JSON_OBJECT` | Complex objects   | User settings objects |
| JSON Array  | `JSON_ARRAY`  | Lists of objects  | Custom configurations |

## Setup & Configuration

### 1. Enable in Configuration

Add user preferences to your `tether.yaml`:

```yaml
generation:
  user_preferences:
    enabled: true
```

### 2. Generated Files

Tether generates:

- **`lib/database/managers/user_preferences_manager.g.dart`**: The core manager
  class
- **Database migration**: Creates the `user_preferences` table automatically

### 3. Database Schema

The manager uses this SQLite table structure:

```sql
CREATE TABLE user_preferences (
    preference_key TEXT PRIMARY KEY,
    preference_value TEXT NOT NULL,  -- JSON-encoded value
    value_type TEXT NOT NULL,        -- One of UserPreferenceValueTypes
    created_at INTEGER DEFAULT (unixepoch()),
    updated_at INTEGER DEFAULT (unixepoch())
);
```

## Basic Usage

### Accessing the Manager

```dart
// With Riverpod (recommended)
final prefsManager = ref.watch(userPreferencesManagerProvider);

// Direct instantiation
final prefsManager = UserPreferencesManager(yourSqliteDatabase);
```

### Setting Preferences

#### Simple Values

```dart
// Store a string
await prefsManager.setPreference(
  'username',
  'john_doe',
  valueType: UserPreferenceValueTypes.text,
);

// Store a boolean
await prefsManager.setPreference(
  'notifications_enabled',
  true,
  valueType: UserPreferenceValueTypes.boolean,
);

// Store a number
await prefsManager.setPreference(
  'user_score',
  85.5,
  valueType: UserPreferenceValueTypes.real,
);
```

#### Complex Objects

```dart
// Store an object
class UserSettings {
  final String theme;
  final bool darkMode;
  final List<String> languages;

  UserSettings({
    required this.theme,
    required this.darkMode,
    required this.languages,
  });

  Map<String, dynamic> toJson() => {
    'theme': theme,
    'darkMode': darkMode,
    'languages': languages,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    theme: json['theme'],
    darkMode: json['darkMode'],
    languages: List<String>.from(json['languages']),
  );
}

// Store the settings object
final settings = UserSettings(
  theme: 'blue',
  darkMode: true,
  languages: ['en', 'es'],
);

await prefsManager.setPreference(
  'user_settings',
  settings.toJson(),
  valueType: UserPreferenceValueTypes.jsonObject,
);
```

#### Arrays

```dart
// Store a list of strings
await prefsManager.setPreference(
  'favorite_categories',
  ['technology', 'sports', 'music'],
  valueType: UserPreferenceValueTypes.textArray,
);

// Store a list of objects
final recentSearches = [
  {'query': 'flutter', 'timestamp': DateTime.now().millisecondsSinceEpoch},
  {'query': 'dart', 'timestamp': DateTime.now().millisecondsSinceEpoch},
];

await prefsManager.setPreference(
  'recent_searches',
  recentSearches,
  valueType: UserPreferenceValueTypes.jsonArray,
);
```

### Getting Preferences

#### Simple Values

```dart
// Get a string
final username = await prefsManager.getPreference<String>(
  'username',
  fromJson: (json) => json as String? ?? '',
);

// Get a boolean with default
final notificationsEnabled = await prefsManager.getPreference<bool>(
  'notifications_enabled',
  fromJson: (json) => json as bool? ?? true,
);

// Get a number
final userScore = await prefsManager.getPreference<double>(
  'user_score',
  fromJson: (json) => (json as num?)?.toDouble() ?? 0.0,
);
```

#### Complex Objects

```dart
// Get an object
final settings = await prefsManager.getPreference<UserSettings?>(
  'user_settings',
  fromJson: (json) {
    if (json == null) return null;
    return UserSettings.fromJson(json as Map<String, dynamic>);
  },
);

// Get with fallback to default
final settingsWithDefault = await prefsManager.getPreference<UserSettings>(
  'user_settings',
  fromJson: (json) {
    if (json == null) {
      return UserSettings(
        theme: 'default',
        darkMode: false,
        languages: ['en'],
      );
    }
    return UserSettings.fromJson(json as Map<String, dynamic>);
  },
);
```

#### Arrays

```dart
// Get a list of strings
final categories = await prefsManager.getPreference<List<String>>(
  'favorite_categories',
  fromJson: (json) => json != null 
    ? List<String>.from(json as List) 
    : <String>[],
);

// Get a list of objects
final searches = await prefsManager.getPreference<List<Map<String, dynamic>>>(
  'recent_searches',
  fromJson: (json) => json != null
    ? List<Map<String, dynamic>>.from(json as List)
    : <Map<String, dynamic>>[],
);
```

## Reactive UI with Riverpod Providers

For the most seamless integration with your app's state management, create
Riverpod providers that wrap your preference streams:

### Simple Preference Providers

```dart
// Create providers for commonly used preferences
final notificationsEnabledProvider = StreamProvider<bool>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  return prefsManager.watchPreference<bool>(
    'notifications_enabled',
    fromJson: (json) => json as bool? ?? true,
  );
});

final userThemeProvider = StreamProvider<String>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  return prefsManager.watchPreference<String>(
    'theme',
    fromJson: (json) => json as String? ?? 'default',
  );
});

final favoriteCategories = StreamProvider<List<String>>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  return prefsManager.watchPreference<List<String>>(
    'favorite_categories',
    fromJson: (json) => json != null 
      ? List<String>.from(json as List) 
      : <String>[],
  );
});
```

### Complex Object Providers

```dart
final userSettingsProvider = StreamProvider<UserSettings>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  return prefsManager.watchPreference<UserSettings>(
    'user_settings',
    fromJson: (json) {
      if (json == null) {
        return UserSettings(
          theme: 'default',
          darkMode: false,
          languages: ['en'],
        );
      }
      return UserSettings.fromJson(json as Map<String, dynamic>);
    },
  );
});
```

### Using Providers in Widgets

```dart
class NotificationToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsEnabledProvider);
    final prefsManager = ref.watch(userPreferencesManagerProvider);
    
    return notificationsAsync.when(
      data: (isEnabled) => SwitchListTile(
        title: Text('Enable Notifications'),
        value: isEnabled,
        onChanged: (value) async {
          await prefsManager.setPreference(
            'notifications_enabled',
            value,
            valueType: UserPreferenceValueTypes.boolean,
          );
        },
      ),
      loading: () => ListTile(
        title: Text('Enable Notifications'),
        trailing: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => ListTile(
        title: Text('Enable Notifications'),
        subtitle: Text('Error: $error'),
      ),
    );
  }
}

class ThemeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final prefsManager = ref.watch(userPreferencesManagerProvider);
    
    return settingsAsync.when(
      data: (settings) => Column(
        children: [
          ListTile(
            title: Text('Theme'),
            trailing: DropdownButton<String>(
              value: settings.theme,
              items: ['default', 'blue', 'green'].map((theme) =>
                DropdownMenuItem(value: theme, child: Text(theme))
              ).toList(),
              onChanged: (newTheme) async {
                if (newTheme != null) {
                  final updatedSettings = UserSettings(
                    theme: newTheme,
                    darkMode: settings.darkMode,
                    languages: settings.languages,
                  );
                  await prefsManager.setPreference(
                    'user_settings',
                    updatedSettings.toJson(),
                    valueType: UserPreferenceValueTypes.jsonObject,
                  );
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: settings.darkMode,
            onChanged: (value) async {
              final updatedSettings = UserSettings(
                theme: settings.theme,
                darkMode: value,
                languages: settings.languages,
              );
              await prefsManager.setPreference(
                'user_settings',
                updatedSettings.toJson(),
                valueType: UserPreferenceValueTypes.jsonObject,
              );
            },
          ),
        ],
      ),
      loading: () => Column(
        children: [
          ListTile(
            title: Text('Theme'),
            trailing: CircularProgressIndicator(strokeWidth: 2),
          ),
          ListTile(
            title: Text('Dark Mode'),
            trailing: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
      error: (error, stack) => ListTile(
        title: Text('Settings Error'),
        subtitle: Text(error.toString()),
      ),
    );
  }
}
```

### Provider Family for Dynamic Keys

For preferences with dynamic keys, use a provider family:

```dart
final dynamicPreferenceProvider = StreamProvider.family<String, String>((ref, key) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  return prefsManager.watchPreference<String>(
    key,
    fromJson: (json) => json as String? ?? '',
  );
});

// Usage
class DynamicPreferenceWidget extends ConsumerWidget {
  final String preferenceKey;
  
  const DynamicPreferenceWidget({required this.preferenceKey});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueAsync = ref.watch(dynamicPreferenceProvider(preferenceKey));
    
    return valueAsync.when(
      data: (value) => Text('$preferenceKey: $value'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## Reactive UI with StreamBuilder (Alternative)

If you prefer using StreamBuilder directly instead of Riverpod providers:

### Watching Simple Preferences

```dart
class NotificationToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsManager = ref.watch(userPreferencesManagerProvider);
    
    return StreamBuilder<bool>(
      stream: prefsManager.watchPreference<bool>(
        'notifications_enabled',
        fromJson: (json) => json as bool? ?? true,
      ),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? true;
        
        return SwitchListTile(
          title: Text('Enable Notifications'),
          value: isEnabled,
          onChanged: (value) async {
            await prefsManager.setPreference(
              'notifications_enabled',
              value,
              valueType: UserPreferenceValueTypes.boolean,
            );
          },
        );
      },
    );
  }
}
```

### Watching Complex Objects

```dart
class ThemeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsManager = ref.watch(userPreferencesManagerProvider);
    
    return StreamBuilder<UserSettings?>(
      stream: prefsManager.watchPreference<UserSettings?>(
        'user_settings',
        fromJson: (json) {
          if (json == null) return null;
          return UserSettings.fromJson(json as Map<String, dynamic>);
        },
      ),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? UserSettings(
          theme: 'default',
          darkMode: false,
          languages: ['en'],
        );
        
        return Column(
          children: [
            ListTile(
              title: Text('Theme: ${settings.theme}'),
              trailing: DropdownButton<String>(
                value: settings.theme,
                items: ['default', 'blue', 'green'].map((theme) =>
                  DropdownMenuItem(value: theme, child: Text(theme))
                ).toList(),
                onChanged: (newTheme) async {
                  if (newTheme != null) {
                    final updatedSettings = UserSettings(
                      theme: newTheme,
                      darkMode: settings.darkMode,
                      languages: settings.languages,
                    );
                    await prefsManager.setPreference(
                      'user_settings',
                      updatedSettings.toJson(),
                      valueType: UserPreferenceValueTypes.jsonObject,
                    );
                  }
                },
              ),
            ),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: settings.darkMode,
              onChanged: (value) async {
                final updatedSettings = UserSettings(
                  theme: settings.theme,
                  darkMode: value,
                  languages: settings.languages,
                );
                await prefsManager.setPreference(
                  'user_settings',
                  updatedSettings.toJson(),
                  valueType: UserPreferenceValueTypes.jsonObject,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
```

## Default Preferences

### Setting Up Defaults

```dart
class PreferencesService {
  final UserPreferencesManager _prefsManager;
  
  PreferencesService(this._prefsManager);
  
  Future<void> initializeDefaults() async {
    await _prefsManager.ensureDefaultPreferences({
      'theme': (value: 'default', valueType: UserPreferenceValueTypes.text),
      'notifications_enabled': (value: true, valueType: UserPreferenceValueTypes.boolean),
      'user_score': (value: 0.0, valueType: UserPreferenceValueTypes.real),
      'favorite_categories': (
        value: ['general'], 
        valueType: UserPreferenceValueTypes.textArray
      ),
      'user_settings': (
        value: {
          'theme': 'default',
          'darkMode': false,
          'languages': ['en'],
        },
        valueType: UserPreferenceValueTypes.jsonObject
      ),
    });
  }
}
```

### App Initialization

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _initializeApp(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        return MaterialApp(
          title: 'My App',
          home: HomeScreen(),
        );
      },
    );
  }
  
  Future<void> _initializeApp(WidgetRef ref) async {
    final prefsManager = ref.read(userPreferencesManagerProvider);
    final preferencesService = PreferencesService(prefsManager);
    await preferencesService.initializeDefaults();
  }
}
```

## Advanced Usage

### Raw Preference Access

For debugging or advanced use cases, you can access raw preference data:

```dart
// Get raw preference data
final rawData = await prefsManager.getRawPreference('user_settings');
print('Key: ${rawData?['preference_key']}');
print('Value: ${rawData?['preference_value']}');
print('Type: ${rawData?['value_type']}');

// Watch raw preference changes
prefsManager.watchRawPreference('user_settings').listen((rawData) {
  if (rawData != null) {
    print('Raw preference updated: $rawData');
  }
});
```

### Preference Deletion

```dart
// Delete a specific preference
await prefsManager.deletePreference('old_setting');

// Check if preference exists
final exists = await prefsManager.getRawPreference('some_key') != null;
```

### Error Handling

```dart
// Robust preference retrieval with error handling
Future<UserSettings> getUserSettings() async {
  try {
    final settings = await prefsManager.getPreference<UserSettings?>(
      'user_settings',
      fromJson: (json) {
        if (json == null) return null;
        return UserSettings.fromJson(json as Map<String, dynamic>);
      },
    );
    
    return settings ?? UserSettings.defaultSettings();
  } catch (e) {
    print('Error loading user settings: $e');
    return UserSettings.defaultSettings();
  }
}
```

## Best Practices

### 1. Use Riverpod Providers (Recommended)

Create dedicated providers for your preferences rather than accessing the
manager directly in widgets:

```dart
// Good - Declarative and reactive
final themeProvider = StreamProvider<String>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  return prefsManager.watchPreference<String>(
    'theme',
    fromJson: (json) => json as String? ?? 'default',
  );
});

// Less ideal - Direct access in widget
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsManager = ref.watch(userPreferencesManagerProvider);
    return StreamBuilder<String>(
      stream: prefsManager.watchPreference<String>('theme', fromJson: ...),
      // ...
    );
  }
}
```

### 2. Type Safety

Always use specific types and proper fromJson functions:

```dart
// Good
final count = await prefsManager.getPreference<int>(
  'item_count',
  fromJson: (json) => json as int? ?? 0,
);

// Avoid
final count = await prefsManager.getPreference<dynamic>(
  'item_count',
  fromJson: (json) => json,
);
```

### 3. Consistent Value Types

Use the appropriate `UserPreferenceValueTypes` for your data:

```dart
// Good - matches the actual data type
await prefsManager.setPreference(
  'categories',
  ['tech', 'sports'],
  valueType: UserPreferenceValueTypes.textArray,
);

// Avoid - inconsistent with data structure
await prefsManager.setPreference(
  'categories',
  ['tech', 'sports'],
  valueType: UserPreferenceValueTypes.text, // Wrong type
);
```

### 4. Default Values

Always provide sensible defaults in your fromJson functions:

```dart
// Good - handles null case
final theme = await prefsManager.getPreference<String>(
  'theme',
  fromJson: (json) => json as String? ?? 'default',
);

// Risky - could return null unexpectedly
final theme = await prefsManager.getPreference<String?>(
  'theme',
  fromJson: (json) => json as String?,
);
```

### 5. Performance Considerations

- Use Riverpod providers for UI that needs real-time updates
- Use one-time calls (`getPreference`) for initialization or infrequent access
- Consider batching multiple preference updates when possible

### 6. Migration Strategy

When changing preference structures, handle migration gracefully:

```dart
Future<UserSettings> migrateUserSettings() async {
  final settings = await prefsManager.getPreference<UserSettings?>(
    'user_settings',
    fromJson: (json) {
      if (json == null) return null;
      
      // Handle old format
      if (json is String) {
        return UserSettings(theme: json, darkMode: false, languages: ['en']);
      }
      
      // Handle new format
      return UserSettings.fromJson(json as Map<String, dynamic>);
    },
  );
  
  // Save in new format if migration occurred
  if (settings != null) {
    await prefsManager.setPreference(
      'user_settings',
      settings.toJson(),
      valueType: UserPreferenceValueTypes.jsonObject,
    );
  }
  
  return settings ?? UserSettings.defaultSettings();
}
```
