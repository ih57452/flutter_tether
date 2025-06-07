import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/database/managers/user_preferences_manager.g.dart';
import 'package:example/models/preferences.dart';

/// Stream provider for the [ExamplePreferences.textValue] preference.
final textPrefStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  // Use the fromJson converter for text preferences
  return prefsManager.watchPreference<String>(
    ExamplePreferences.textValue.name,
    fromJson: (jsonData) => jsonData as String,
  );
});

/// Stream provider for the [ExamplePreferences.boolean] preference.
final boolPrefStreamProvider = StreamProvider.autoDispose<bool?>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  // Use the fromJson converter for boolean preferences
  return prefsManager.watchPreference<bool>(
    ExamplePreferences.boolean.name,
    fromJson: (jsonData) => jsonData as bool,
  );
});

/// Stream provider for the [ExamplePreferences.integer] preference.
final intPrefStreamProvider = StreamProvider.autoDispose<int?>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  // Use the fromJson converter for integer preferences
  return prefsManager.watchPreference<int>(
    ExamplePreferences.integer.name,
    fromJson: (jsonData) => jsonData as int,
  );
});

/// Stream provider for the [ExamplePreferences.textArray] preference.
final textArrayPrefStreamProvider = StreamProvider.autoDispose<List<String>?>((
  ref,
) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  // Use the fromJson converter for text array preferences
  return prefsManager.watchPreference<List<String>>(
    ExamplePreferences.textArray.name,
    fromJson: (jsonData) => List<String>.from(jsonData as List),
  );
});

/// Stream provider for the [ExamplePreferences.real] preference.
final realPrefStreamProvider = StreamProvider.autoDispose<double?>((ref) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  // Use the fromJson converter for real preferences
  return prefsManager.watchPreference<double>(
    ExamplePreferences.real.name,
    fromJson: (jsonData) => jsonData as double,
  );
});

/// Stream provider for the [ExamplePreferences.jsonObject] preference.
final jsonObjectPrefStreamProvider =
    StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
      final prefsManager = ref.watch(userPreferencesManagerProvider);
      // Use the fromJson converter for JSON object preferences
      return prefsManager.watchPreference<Map<String, dynamic>>(
        ExamplePreferences.jsonObject.name,
        fromJson: (jsonData) => Map<String, dynamic>.from(jsonData as Map),
      );
    });

/// Stream provider for the [ExamplePreferences.jsonArray] preference.
final jsonArrayPrefStreamProvider = StreamProvider.autoDispose<List<dynamic>?>((
  ref,
) {
  final prefsManager = ref.watch(userPreferencesManagerProvider);
  // Use the fromJson converter for JSON array preferences
  return prefsManager.watchPreference<List<dynamic>>(
    ExamplePreferences.jsonArray.name,
    fromJson: (jsonData) => List<dynamic>.from(jsonData as List),
  );
});

class PreferencesTab extends ConsumerWidget {
  const PreferencesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textPrefAsyncValue = ref.watch(textPrefStreamProvider);
    final boolPrefAsyncValue = ref.watch(boolPrefStreamProvider);
    final intPrefAsyncValue = ref.watch(intPrefStreamProvider);
    final textArrayPrefAsyncValue = ref.watch(textArrayPrefStreamProvider);
    final realPrefAsyncValue = ref.watch(realPrefStreamProvider);
    final jsonObjectPrefAsyncValue = ref.watch(jsonObjectPrefStreamProvider);
    final jsonArrayPrefAsyncValue = ref.watch(jsonArrayPrefStreamProvider);

    return ListView(
      children: [
        // A Card for the text preference. Shows the current value and allows editing.
        Card(
          child: Column(
            children: [
              Text('Text Preference'),
              const SizedBox(height: 8),
              textPrefAsyncValue.when(
                data: (currentValue) => Text('Current Value: $currentValue'),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Text('Error loading preference: $error'),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Edit Text Preference',
                  hintText: 'Enter new value',
                ),
                onSubmitted: (newValue) {
                  // Update the preference when the user submits a new value
                  ref
                      .read(userPreferencesManagerProvider)
                      .setPreference<String>(
                        ExamplePreferences.textValue.name,
                        newValue,
                        valueType: UserPreferenceValueType.text,
                      );
                },
                onChanged:
                    (value) => ref
                        .read(userPreferencesManagerProvider)
                        .setPreference<String>(
                          ExamplePreferences.textValue.name,
                          value,
                          valueType: UserPreferenceValueType.text,
                        ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        // A Card for the boolean preference. Shows the current value and allows toggling.
        Card(
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Toggle Boolean Preference'),
                  const Spacer(),
                  Switch(
                    value: boolPrefAsyncValue.value ?? false,
                    onChanged: (newValue) {
                      // Update the preference when the switch is toggled
                      ref
                          .read(userPreferencesManagerProvider)
                          .setPreference<bool>(
                            ExamplePreferences.boolean.name,
                            newValue,
                            valueType: UserPreferenceValueType.boolean,
                          );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // A Card for the integer preference. Shows the current value and allows editing.
        Card(
          child: Column(
            children: [
              Text('Integer Preference'),
              const SizedBox(height: 8),
              intPrefAsyncValue.when(
                data: (currentValue) => Text('Current Value: $currentValue'),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Text('Error loading preference: $error'),
              ),
              const SizedBox(height: 8),
              Slider(
                value: (intPrefAsyncValue.value ?? 0).toDouble(),
                min: 0,
                max: 100,
                onChanged: (newValue) {
                  ref
                      .read(userPreferencesManagerProvider)
                      .setPreference<int>(
                        ExamplePreferences.integer.name,
                        newValue.toInt(),
                        valueType: UserPreferenceValueType.integer,
                      );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        // A Card for the text array preference. Shows the current value and allows editing.
        Card(
          child: Column(
            children: [
              Text('Text Array Preference'),
              const SizedBox(height: 8),
              textArrayPrefAsyncValue.when(
                data:
                    (currentValue) =>
                        Text('Current Value: ${currentValue?.join(', ')}'),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Text('Error loading preference: $error'),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Edit Text Array Preference',
                  hintText: 'Enter comma-separated values',
                ),
                onSubmitted: (newValue) {
                  // Update the preference when the user submits a new value
                  final newArray =
                      newValue.split(',').map((e) => e.trim()).toList();
                  ref
                      .read(userPreferencesManagerProvider)
                      .setPreference<List<String>>(
                        ExamplePreferences.textArray.name,
                        newArray,
                        valueType: UserPreferenceValueType.stringList,
                      );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        // A Card for the real preference. Shows the current value and allows editing.
        Card(
          child: Column(
            children: [
              Text('Real Preference'),
              const SizedBox(height: 8),
              realPrefAsyncValue.when(
                data: (currentValue) => Text('Current Value: $currentValue'),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Text('Error loading preference: $error'),
              ),
              const SizedBox(height: 8),
              Slider(
                value: (realPrefAsyncValue.value ?? 0.0),
                min: 0,
                max: 100,
                onChanged: (newValue) {
                  ref
                      .read(userPreferencesManagerProvider)
                      .setPreference<double>(
                        ExamplePreferences.real.name,
                        newValue,
                        valueType: UserPreferenceValueType.number,
                      );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        // A Card for the JSON object preference. Shows the current value and allows editing.
        Card(
          child: Column(
            children: [
              Text('JSON Object Preference'),
              const SizedBox(height: 8),
              jsonObjectPrefAsyncValue.when(
                data:
                    (currentValue) =>
                        Text('Current Value: ${currentValue.toString()}'),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Text('Error loading preference: $error'),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Edit JSON Object Preference',
                  hintText: 'Enter JSON string',
                ),
                onSubmitted: (newValue) {
                  // Update the preference when the user submits a new value
                  final newJson = jsonDecode(newValue);
                  ref
                      .read(userPreferencesManagerProvider)
                      .setPreference<Map<String, dynamic>>(
                        ExamplePreferences.jsonObject.name,
                        newJson,
                        valueType: UserPreferenceValueType.jsonObject,
                      );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        // A Card for the JSON array preference. Shows the current value and allows editing.
        Card(
          child: Column(
            children: [
              Text('JSON Array Preference'),
              const SizedBox(height: 8),
              jsonArrayPrefAsyncValue.when(
                data:
                    (currentValue) =>
                        Text('Current Value: ${currentValue.toString()}'),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Text('Error loading preference: $error'),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Edit JSON Array Preference',
                  hintText: 'Enter JSON string',
                ),
                onSubmitted: (newValue) {
                  // Update the preference when the user submits a new value
                  final newJson = jsonDecode(newValue);
                  ref
                      .read(userPreferencesManagerProvider)
                      .setPreference<List<dynamic>>(
                        ExamplePreferences.jsonArray.name,
                        newJson,
                        valueType: UserPreferenceValueType.jsonArray,
                      );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
