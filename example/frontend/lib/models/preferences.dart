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

final Map<String, ({Object value, String valueType})> defaultAppSettings = {
  ExamplePreferences.textValue.value: (
    value: 'Default Text Value',
    valueType: 'text',
  ),
  ExamplePreferences.boolean.value: (value: true, valueType: 'boolean'),
  ExamplePreferences.integer.value: (value: 42, valueType: 'integer'),
  ExamplePreferences.textArray.value: (
    value: ['Item1', 'Item2'],
    valueType: 'textArray',
  ),
  ExamplePreferences.real.value: (value: 3.14, valueType: 'real'),
  ExamplePreferences.jsonObject.value: (
    value: {'key': 'value'},
    valueType: 'jsonObject',
  ),
  ExamplePreferences.jsonArray.value: (
    value: ['item1', 'item2'],
    valueType: 'jsonArray',
  ),
};
