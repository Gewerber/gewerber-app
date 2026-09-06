import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/presentation/widgets/common/empty_state.dart';

void main() {
  Future<void> pumpEmptyState(WidgetTester tester, EmptyState state) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: state)));
  }

  testWidgets('renders icon and message', (tester) async {
    await pumpEmptyState(
      tester,
      const EmptyState(icon: Icons.inbox_outlined, message: 'Nothing here'),
    );

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('action slot renders below the message', (tester) async {
    await pumpEmptyState(
      tester,
      EmptyState(
        icon: Icons.error_outline,
        message: 'Load failed',
        action: TextButton(onPressed: () {}, child: const Text('Retry')),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    // Message above the action.
    expect(
      tester.getTopLeft(find.text('Load failed')).dy,
      lessThan(tester.getTopLeft(find.text('Retry')).dy),
    );
  });

  testWidgets('compact mode uses smaller paddings and icon', (tester) async {
    await pumpEmptyState(
      tester,
      const EmptyState(
        icon: Icons.folder_open_outlined,
        message: 'No files',
        compact: true,
      ),
    );

    // Icon is 40 (compact) instead of 56.
    final icon = tester.getSize(find.byIcon(Icons.folder_open_outlined));
    expect(icon.height, 40);

    final padding = tester.widget<Padding>(
      find
          .ancestor(of: find.byType(Column), matching: find.byType(Padding))
          .first,
    );
    expect(padding.padding, const EdgeInsets.all(GewerberTokens.space16));
  });
}
