import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/app_error.dart';

/// Stable, actionable S19 copy. Never expose SDK messages or credentials.
AppError mapAuthError(Object error) {
  if (error is AppError) return error;
  if (error is GoogleSignInException) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled ||
      GoogleSignInExceptionCode.interrupted => const CancelledError(),
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        const ValidationError(
          'Google sign-in is not configured for this app. Contact your administrator.',
        ),
      _ => const UnknownError(
        'Google sign-in failed. Check your connection and try again.',
      ),
    };
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'network-request-failed' => const NetworkError(
        'Check your internet connection and try again',
      ),
      'invalid-email' => const ValidationError('Enter a valid email'),
      'invalid-credential' || 'wrong-password' || 'user-not-found' =>
        const ValidationError('Email or password is incorrect'),
      'email-already-in-use' => const ValidationError(
        'An account already uses this email. Sign in instead.',
      ),
      'weak-password' => const ValidationError(
        'Choose a stronger password (at least 6 characters)',
      ),
      'user-disabled' => const PermissionDeniedError(
        'This account is disabled. Contact your administrator.',
      ),
      'too-many-requests' || 'quota-exceeded' => const ValidationError(
        'Too many attempts. Please wait before trying again.',
      ),
      'operation-not-allowed' => const ValidationError(
        'This sign-in method is not enabled. Contact your administrator.',
      ),
      'account-exists-with-different-credential' => const ValidationError(
        'Use the sign-in method originally used for this email',
      ),
      'invalid-phone-number' || 'missing-phone-number' => const ValidationError(
        'Enter a valid phone number with its country code',
      ),
      'invalid-verification-code' => const ValidationError(
        'The SMS code is incorrect. Try again.',
      ),
      'session-expired' || 'invalid-verification-id' => const ValidationError(
        'The SMS code has expired. Request a new code.',
      ),
      'captcha-check-failed' ||
      'invalid-app-credential' ||
      'app-not-authorized' ||
      'missing-client-identifier' => const ValidationError(
        'Phone verification could not verify this app. Check Android SHA fingerprints and try again.',
      ),
      'web-context-cancelled' ||
      'popup-closed-by-user' => const CancelledError(),
      _ => const UnknownError('Sign-in failed. Please try again.'),
    };
  }
  return const UnknownError('Sign-in failed. Please try again.');
}
