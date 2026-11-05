/// The only error type ViewModels and widgets ever see (D12).
/// Firebase implementations translate SDK exceptions into these.
sealed class AppError implements Exception {
  const AppError(this.message);

  /// User-facing message (English, wording from Figma where it exists).
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkError extends AppError {
  const NetworkError([super.message = "You're offline"]);
}

class PermissionDeniedError extends AppError {
  const PermissionDeniedError([super.message = "You don't have access to this"]);
}

class CancelledError extends AppError {
  const CancelledError([super.message = 'Sign-in was cancelled']);
}

class NotFoundError extends AppError {
  const NotFoundError([super.message = 'Not found']);
}

class ValidationError extends AppError {
  const ValidationError(super.message);
}

class TimeoutAppError extends AppError {
  const TimeoutAppError([super.message = 'This is taking too long']);
}

class UnknownError extends AppError {
  const UnknownError([super.message = 'Something went wrong', this.cause]);
  final Object? cause;
}
