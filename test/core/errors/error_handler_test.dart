import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';

void main() {
  group('mapAppException', () {
    test(
      'maps InvoiceLimitReachedException to a failure carrying the limit',
      () {
        final failure = mapAppException(
          const InvoiceLimitReachedException(limit: 3),
        );

        expect(failure, isA<InvoiceLimitReachedFailure>());
        expect((failure as InvoiceLimitReachedFailure).limit, 3);
      },
    );

    test(
      'does not collapse the limit failure into the generic network one',
      () {
        final failure = mapAppException(
          const InvoiceLimitReachedException(limit: 5),
        );

        expect(failure, isNot(isA<NetworkFailure>()));
      },
    );

    test('still maps unrelated exceptions to the generic network failure', () {
      expect(
        mapAppException(const NotFoundException()),
        isA<NotFoundFailure>(),
      );
      expect(
        mapAppException(const ValidationException('bad')),
        isA<ValidationFailure>(),
      );
    });
  });
}
