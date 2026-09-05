import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_hint.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_info_icon.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_info_sheet.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_label.dart';

/// English label of the sheet's trailing "more" action
/// (`fieldInfoMore` in `app_en.arb`).
const String kMoreLabel = 'More in the guide';

void main() {
  /// Pumps [child] inside a localized [MaterialApp] pinned to English
  /// ([FieldInfoIcon] reads `AppLocalizations.of(context).fieldInfoMore`).
  Future<void> pumpField(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(800, 600),
  }) async {
    // `tester.view` drives `MediaQuery.sizeOf`; `setSurfaceSize` only affects
    // the render surface and would leave the breakpoint logic on 800x600.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapInfoIcon(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
  }

  group('FieldInfoIcon', () {
    testWidgets('renders an info icon with the hint as its tooltip', (
      tester,
    ) async {
      await pumpField(tester, const FieldInfoIcon(infoText: 'Short hint'));

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byTooltip('Short hint'), findsOneWidget);
    });

    testWidgets('tap with longInfoText opens a sheet with title and bodies', (
      tester,
    ) async {
      await pumpField(
        tester,
        const FieldInfoIcon(
          infoText: 'Short hint',
          longInfoText: 'Long explanation',
          sheetTitle: 'VAT ID',
        ),
      );

      await tapInfoIcon(tester);

      final sheet = find.byType(BottomSheet);
      expect(sheet, findsOneWidget);
      expect(
        find.descendant(of: sheet, matching: find.text('VAT ID')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Short hint')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Long explanation')),
        findsOneWidget,
      );
    });

    testWidgets('tap without longInfoText does not open a sheet', (
      tester,
    ) async {
      await pumpField(tester, const FieldInfoIcon(infoText: 'Short hint'));

      await tapInfoIcon(tester);

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('icon exposes its hint text through the tooltip semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await pumpField(tester, const FieldInfoIcon(infoText: 'Short hint'));

      // The Tooltip widget carries the message for assistive tech...
      expect(find.byTooltip('Short hint'), findsOneWidget);
      // ...and it lands in the semantics tree as the `tooltip` property.
      // Note: it is NOT exposed as the button's `label` (see report).
      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.tooltip == 'Short hint',
      );
      expect(semanticsFinder, findsOneWidget);
      expect(tester.getSemantics(semanticsFinder).tooltip, 'Short hint');

      handle.dispose();
    });
  });

  group('FieldInfoSheet', () {
    /// Pumps a button that invokes [showFieldInfoSheet] directly.
    Future<void> pumpSheetTrigger(WidgetTester tester, Size size) async {
      await pumpField(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showFieldInfoSheet<void>(
              context: context,
              title: 'Sheet title',
              body: 'Short hint',
              longBody: 'Long explanation',
            ),
            child: const Text('open'),
          ),
        ),
        size: size,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('showFieldInfoSheet uses a bottom sheet below 900 px', (
      tester,
    ) async {
      await pumpSheetTrigger(tester, const Size(400, 800));

      final sheet = find.byType(BottomSheet);
      expect(sheet, findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.descendant(of: sheet, matching: find.text('Sheet title')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Short hint')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Long explanation')),
        findsOneWidget,
      );
    });

    testWidgets('showFieldInfoSheet uses a dialog at or above 900 px', (
      tester,
    ) async {
      await pumpSheetTrigger(tester, const Size(1200, 800));

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(
        find.descendant(of: dialog, matching: find.text('Sheet title')),
        findsOneWidget,
      );
    });

    testWidgets('narrow screen shows a modal bottom sheet', (tester) async {
      await pumpField(
        tester,
        const FieldInfoIcon(
          infoText: 'Short hint',
          longInfoText: 'Long explanation',
        ),
        size: const Size(400, 800),
      );

      await tapInfoIcon(tester);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('wide screen shows an alert dialog', (tester) async {
      await pumpField(
        tester,
        const FieldInfoIcon(
          infoText: 'Short hint',
          longInfoText: 'Long explanation',
        ),
        size: const Size(1200, 800),
      );

      await tapInfoIcon(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Long explanation'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('"more" action appears only when onLongInfoRequested is set', (
      tester,
    ) async {
      await pumpField(
        tester,
        FieldInfoIcon(
          infoText: 'Short hint',
          longInfoText: 'Long explanation',
          onLongInfoRequested: () {},
        ),
      );

      await tapInfoIcon(tester);

      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(kMoreLabel),
        ),
        findsOneWidget,
      );
    });

    testWidgets('"more" action is absent without onLongInfoRequested', (
      tester,
    ) async {
      await pumpField(
        tester,
        const FieldInfoIcon(
          infoText: 'Short hint',
          longInfoText: 'Long explanation',
        ),
      );

      await tapInfoIcon(tester);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text(kMoreLabel), findsNothing);
    });

    testWidgets('tapping "more" closes the sheet and invokes the callback', (
      tester,
    ) async {
      var called = false;
      await pumpField(
        tester,
        FieldInfoIcon(
          infoText: 'Short hint',
          longInfoText: 'Long explanation',
          onLongInfoRequested: () => called = true,
        ),
      );

      await tapInfoIcon(tester);
      await tester.tap(find.text(kMoreLabel));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  group('FieldLabel', () {
    testWidgets('renders the label text and no icon without infoText', (
      tester,
    ) async {
      await pumpField(tester, const FieldLabel(label: 'Company name'));

      expect(find.text('Company name'), findsOneWidget);
      expect(find.byType(FieldInfoIcon), findsNothing);
    });

    testWidgets('renders an info icon when infoText is set', (tester) async {
      await pumpField(
        tester,
        const FieldLabel(label: 'Company name', infoText: 'Short hint'),
      );

      expect(find.text('Company name'), findsOneWidget);
      expect(find.byType(FieldInfoIcon), findsOneWidget);
      expect(find.byTooltip('Short hint'), findsOneWidget);
    });
  });

  group('CustomTextField hint', () {
    testWidgets('renders the info icon in the suffix when hint is set', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pumpField(
        tester,
        CustomTextField(
          controller: controller,
          label: 'USt-IdNr.',
          hint: const FieldHint(shortText: 'Short hint'),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(InputDecorator),
          matching: find.byType(FieldInfoIcon),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Short hint'), findsOneWidget);
    });

    testWidgets('hint icon and suffixIcon are merged into one Row', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pumpField(
        tester,
        CustomTextField(
          controller: controller,
          label: 'USt-IdNr.',
          hint: const FieldHint(shortText: 'Short hint'),
          suffixIcon: const Icon(Icons.clear),
        ),
      );

      final mergedSuffix = find.byWidgetPredicate(
        (widget) =>
            widget is Row &&
            widget.children.any((child) => child is FieldInfoIcon) &&
            widget.children.any(
              (child) => child is Icon && child.icon == Icons.clear,
            ),
      );
      expect(mergedSuffix, findsOneWidget);
      expect(find.byType(FieldInfoIcon), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('without hint the suffixIcon renders alone (back-compat)', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pumpField(
        tester,
        CustomTextField(
          controller: controller,
          label: 'USt-IdNr.',
          suffixIcon: const Icon(Icons.clear),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byType(FieldInfoIcon), findsNothing);
    });

    testWidgets('tapping the hint icon opens a sheet titled with the label', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pumpField(
        tester,
        CustomTextField(
          controller: controller,
          label: 'USt-IdNr.',
          hint: const FieldHint(
            shortText: 'Short hint',
            longText: 'Long explanation',
          ),
        ),
      );

      await tapInfoIcon(tester);

      final sheet = find.byType(BottomSheet);
      expect(sheet, findsOneWidget);
      expect(
        find.descendant(of: sheet, matching: find.text('USt-IdNr.')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Long explanation')),
        findsOneWidget,
      );
    });
  });
}
