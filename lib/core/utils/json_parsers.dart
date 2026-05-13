int parseIntValue(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final normalized = value.trim().replaceAll(',', '');
    if (normalized.isEmpty) return defaultValue;
    final intValue = int.tryParse(normalized);
    if (intValue != null) return intValue;
    final doubleValue = double.tryParse(normalized);
    if (doubleValue != null) return doubleValue.toInt();
  }
  return defaultValue;
}

double parseDoubleValue(dynamic value, {double defaultValue = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final normalized = value.trim().replaceAll(',', '');
    if (normalized.isEmpty) return defaultValue;
    return double.tryParse(normalized) ?? defaultValue;
  }
  return defaultValue;
}
