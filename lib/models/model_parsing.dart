/// Shared helpers for turning decoded JSON into typed models.
///
/// Every helper throws a [DataParseException] with a pt-BR message when the
/// input does not match the expected shape, so the UI can present a friendly
/// error instead of crashing.
class DataParseException implements Exception {
  const DataParseException(this.message);

  final String message;

  @override
  String toString() => 'DataParseException: $message';
}

/// Reads a required non-empty [String].
String requireString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  throw DataParseException('Campo "$key" ausente ou inválido.');
}

/// Reads a required list of non-empty [String]s.
List<String> requireStringList(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is List) {
    final items = value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (items.isNotEmpty) {
      return items;
    }
  }
  throw DataParseException('Campo "$key" deve conter uma lista de textos.');
}

/// Reads a required ISO-8601 [DateTime].
DateTime requireDateTime(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  throw DataParseException('Campo "$key" deve conter uma data válida.');
}
