import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teamup_exe/firebase/auth_error_mapper.dart';
import 'package:teamup_exe/services/app_error.dart';

void main() {
  test('Firebase errors become safe S19 messages', () {
    expect(mapAuthError(FirebaseAuthException(code: 'network-request-failed')), isA<NetworkError>());
    expect(mapAuthError(FirebaseAuthException(code: 'user-disabled')), isA<PermissionDeniedError>());
    for (final code in ['invalid-credential', 'wrong-password', 'user-not-found']) {
      expect(mapAuthError(FirebaseAuthException(code: code)).message, 'Email or password is incorrect');
    }
    for (final code in ['invalid-phone-number', 'invalid-verification-code', 'session-expired',
      'too-many-requests', 'quota-exceeded', 'operation-not-allowed', 'app-not-authorized']) {
      expect(mapAuthError(FirebaseAuthException(code: code)), isA<ValidationError>());
    }
    final mapped = mapAuthError(FirebaseAuthException(code: 'unexpected', message: 'sensitive details'));
    expect(mapped, isA<UnknownError>());
    expect(mapped.toString(), isNot(contains('sensitive')));
  });
  test('Google cancel/interruption and configuration are distinguished', () {
    for (final code in [GoogleSignInExceptionCode.canceled, GoogleSignInExceptionCode.interrupted]) {
      expect(mapAuthError(GoogleSignInException(code: code)), isA<CancelledError>());
    }
    expect(mapAuthError(const GoogleSignInException(code: GoogleSignInExceptionCode.clientConfigurationError)),
      isA<ValidationError>());
  });
}
