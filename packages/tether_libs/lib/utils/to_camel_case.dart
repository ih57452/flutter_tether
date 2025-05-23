String toCamelCase(String text) {
  if (text.isEmpty) return '';
  // Replace any non-alphanumeric sequence used as separator with a single underscore
  final safeText = text.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
  // Split by underscore
  List<String> parts = safeText.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';

  // First part lowercase, subsequent parts capitalized
  String result = parts.first.toLowerCase();
  for (int i = 1; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      result += parts[i][0].toUpperCase() + parts[i].substring(1).toLowerCase();
    }
  }
  return result;
}
