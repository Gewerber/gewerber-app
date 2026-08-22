import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/application/guidance/checklist_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/checklist_view.dart';

void main() {
  setUpAll(configureDependencies);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    getIt<ChecklistCubit>().reset();
  });

  Future<void> pumpChecklist(WidgetTester tester) async {
    final cubit = getIt<ChecklistCubit>();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<ChecklistCubit>.value(
          value: cubit,
          child: const Scaffold(body: ChecklistView()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all getting-started items with zero progress', (
    tester,
  ) async {
    await pumpChecklist(tester);

    expect(find.text('Done 0 of 6'), findsOneWidget);
    expect(find.text('Set up your business profile'), findsOneWidget);
    expect(find.text('Configure your invoice defaults'), findsOneWidget);
    expect(find.text('Add your first customer'), findsOneWidget);
    expect(find.text('Create your first invoice'), findsOneWidget);
    expect(find.text('Understand VAT basics'), findsOneWidget);
    expect(find.text('Personalize the app'), findsOneWidget);
    expect(find.text('All done! 🎉'), findsNothing);
  });

  testWidgets('tapping items updates progress and persists to preferences', (
    tester,
  ) async {
    await pumpChecklist(tester);

    await tester.tap(find.text('Set up your business profile'));
    await tester.pumpAndSettle();
    expect(find.text('Done 1 of 6'), findsOneWidget);

    await tester.tap(find.text('Add your first customer'));
    await tester.pumpAndSettle();
    expect(find.text('Done 2 of 6'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('getting_started_checklist_completed');
    expect(stored, containsAll(['business_profile', 'first_customer']));

    // Tapping again un-completes the item.
    await tester.tap(find.text('Set up your business profile'));
    await tester.pumpAndSettle();
    expect(find.text('Done 1 of 6'), findsOneWidget);
  });

  testWidgets('shows the completion banner when all items are done', (
    tester,
  ) async {
    await pumpChecklist(tester);

    const titles = [
      'Set up your business profile',
      'Configure your invoice defaults',
      'Add your first customer',
      'Create your first invoice',
      'Understand VAT basics',
      'Personalize the app',
    ];
    for (final title in titles) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
    }

    expect(find.text('Done 6 of 6'), findsOneWidget);
    expect(find.text('All done! 🎉'), findsOneWidget);
  });

  testWidgets('renders without overflow on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpChecklist(tester);

    expect(tester.takeException(), isNull, reason: 'overflow on 320px');
  });
}
