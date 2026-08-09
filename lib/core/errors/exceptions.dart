/// Source exceptions raised by the infrastructure layer.
///
/// Each concrete exception type maps to a matching [Failure] in
/// `failures.dart` via `core/errors/error_handler.dart`.
library;

abstract base class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the supplied credentials are invalid.
final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException() : super('Invalid credentials');
}
