import 'app_error.dart';

/// Shared by real/fake services and the ViewModel. Passwords are never trimmed.
abstract final class AuthValidation {
  static String email(String value) {
    final normalized = value.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
      throw const ValidationError('Enter a valid email');
    }
    return normalized;
  }

  static void password(String value, {bool registering = false}) {
    if (value.isEmpty || (registering && value.length < 6)) {
      throw ValidationError(
        registering
            ? 'Use at least 6 characters for your password'
            : 'Enter your password',
      );
    }
  }

  static String phone(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[\s()-]'), '');
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalized)) {
      throw const ValidationError(
        'Use an international phone number, for example +84912345678',
      );
    }
    return normalized;
  }

  static String smsCode(String value) {
    final normalized = value.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalized)) {
      throw const ValidationError('Enter the 6-digit SMS code');
    }
    return normalized;
  }
}
