import 'package:example/database/managers/user_preferences_manager.g.dart';

enum ExamplePreferences {
  textValue("textValue", "Text Value"),
  boolean("boolean", "Boolean"),
  integer("integer", "Integer"),
  textArray("textArray", "Text Array"),
  real("real", "Real"),
  jsonObject("jsonObject", "JSON Object"),
  jsonArray("jsonArray", "JSON Array");

  final String value;
  final String description;
  const ExamplePreferences(this.value, this.description);
  static const List<String> all = [
    'textValue',
    'boolean',
    'integer',
    'textArray',
    'real',
    'jsonObject',
    'jsonArray',
  ];
}

final Map<String, ({Object value, UserPreferenceValueType valueType})>
defaultAppSettings = {
  ExamplePreferences.textValue.value: (
    value: 'Default Text Value',
    valueType: UserPreferenceValueType.text,
  ),
  ExamplePreferences.boolean.value: (
    value: true,
    valueType: UserPreferenceValueType.boolean,
  ),
  ExamplePreferences.integer.value: (
    value: 42,
    valueType: UserPreferenceValueType.integer,
  ),
  ExamplePreferences.textArray.value: (
    value: ['Item1', 'Item2'],
    valueType: UserPreferenceValueType.stringList,
  ),
  ExamplePreferences.real.value: (
    value: 3.14,
    valueType: UserPreferenceValueType.number,
  ),
  ExamplePreferences.jsonObject.value: (
    value: {'key': 'value'},
    valueType: UserPreferenceValueType.jsonObject,
  ),
  ExamplePreferences.jsonArray.value: (
    value: ['item1', 'item2'],
    valueType: UserPreferenceValueType.jsonArray,
  ),
};
