/// Shared wire-format validation; no Firebase or UI dependency.
abstract final class DataValidation {
  static bool isId(String value) =>
      RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$').hasMatch(value);

  static String text(Map<String, dynamic> data, String key, {int max = 120}) {
    final value = data[key];
    if (value is! String || value.trim().isEmpty || value.length > max) {
      throw FormatException('Invalid $key');
    }
    return value;
  }

  static String id(String value) {
    if (!isId(value)) throw const FormatException('Invalid document ID');
    return value;
  }

  static String? optionalText(Map<String, dynamic> data, String key, {int max = 32}) {
    final value = data[key];
    if (value == null) return null;
    return text(data, key, max: max);
  }
}
