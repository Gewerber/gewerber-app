import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/main.dart';

void main() {
  testWidgets('App renders and applies the Gewerber theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GewerberApp());

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Gewerber'), findsWidgets);
    expect(find.text('Business. Simplified.'), findsOneWidget);
    expect(find.text('Let’s start'), findsOneWidget);
  });
}
