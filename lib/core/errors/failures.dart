/// Abstract failure type used as the error arm of [Either]-style results.
///
/// Concrete failure classes are added together with the domain logic they
/// describe (see `core/errors/exceptions.dart` for source exceptions).
abstract base class Failure {
  const Failure([this.message]);

  /// Human-readable description of the failure.
  final String? message;

  @override
  String toString() => '$runtimeType${message == null ? '' : ': $message'}';
}

/// The supplied credentials were rejected.
final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Invalid credentials');
}

/// The login was blocked due to too many failed attempts.
final class TooManyAttemptsFailure extends Failure {
  const TooManyAttemptsFailure() : super('Too many failed attempts');
}
