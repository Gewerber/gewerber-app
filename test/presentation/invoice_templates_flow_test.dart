import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/repositories/invoice_template_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_invoice_template_repository.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_template_edit_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_templates_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoicing_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

void main() {
  setUpAll(configureDependencies);

  setUp(() {
    // The template cubit and its mock backend are singletons; start from a
    // clean slate so tests do not inherit data from an earlier scenario.
    (getIt<InvoiceTemplateRepository>() as MockInvoiceTemplateRepository)
        .reset();
    getIt<InvoiceTemplateCubit>().reset();
  });

  testWidgets('create and edit an invoice template from the shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(CustomTextField).at(0),
      'demo@gewerber.de',
    );
    await tester.enterText(find.byType(CustomTextField).at(1), 'demo-password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      // The preferences step (theme/language) comes before the business form.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      await tester.tap(find.text('Create business'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Invoicing -> templates.
    await tester.tap(find.text('Invoicing'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoicingScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.description_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceTemplatesScreen), findsOneWidget);
    expect(
      find.text('No templates yet. Create your first template.'),
      findsOneWidget,
    );

    // Create a template.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceTemplateEditScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Standard');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.byType(InvoiceTemplatesScreen), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);

    // Edit the template: add a footer and make it the default.
    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();
    expect(find.text('Edit template'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).at(2),
      'Thank you for your business.',
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Back on the list with the default badge.
    expect(find.byType(InvoiceTemplatesScreen), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(InvoicingScreen), findsOneWidget);
  });
}
