import 'exceptions.dart';
import 'failures.dart';

/// Central place that translates infrastructure [AppException]s into
/// domain [Failure]s. Implementations are added together with the
/// corresponding source exceptions.
typedef ErrorHandler = Failure Function(AppException exception);
