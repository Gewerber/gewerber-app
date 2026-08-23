import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/recurring_schedules/recurring_schedule_cubit.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';
import 'package:gewerber_app/domain/repositories/recurring_schedule_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_customer_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_invoice_repository.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/recurring_schedule_edit_screen.dart';
import 'package:gewerber_app/presentation/screens/home/recurring_schedules_screen.dart';

/// In-memory [RecurringScheduleRepository] with controllable failures.
class _FakeScheduleRepository implements RecurringScheduleRepository {
  _FakeScheduleRepository({List<RecurringSchedule>? schedules})
    : _schedules = {
        for (final schedule in schedules ?? const <RecurringSchedule>[])
          schedule.invoiceId: schedule,
      };

  final Map<int, RecurringSchedule> _schedules;
  bool failSave = false;

  @override
  Future<List<RecurringSchedule>> list({int? limit, int? offset}) async {
    final all = _schedules.values.toList()
      ..sort((a, b) => a.effectiveNextDate.compareTo(b.effectiveNextDate));
    return all.skip(offset ?? 0).take(limit ?? all.length).toList();
  }

  @override
  Future<RecurringSchedule> get(int invoiceId) async {
    final schedule = _schedules[invoiceId];
    if (schedule == null) throw const NotFoundException();
    return schedule;
  }

  @override
  Future<RecurringSchedule> attach({
    required int invoiceId,
    required RecurrenceInterval interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  }) async {
    if (_schedules.containsKey(invoiceId)) {
      throw const ConflictException('already scheduled');
    }
    final schedule = RecurringSchedule(
      invoiceId: invoiceId,
      invoiceNumber: 'RE-$invoiceId',
      interval: interval,
      issueDate: nextRecurrenceDate ?? DateTime(2026, 8, 1),
      nextRecurrenceDate: nextRecurrenceDate,
      recurrenceEndDate: recurrenceEndDate,
      recurrenceMaxOccurrences: recurrenceMaxOccurrences,
    );
    _schedules[invoiceId] = schedule;
    return schedule;
  }

  @override
  Future<RecurringSchedule> update(
    RecurringSchedule schedule, {
    RecurrenceInterval? interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  }) async {
    if (failSave) throw const NetworkException();
    final current = _schedules[schedule.invoiceId]!;
    final updated = RecurringSchedule(
      invoiceId: current.invoiceId,
      invoiceNumber: current.invoiceNumber,
      interval: interval ?? current.interval,
      issueDate: current.issueDate,
      customerId: current.customerId,
      nextRecurrenceDate: nextRecurrenceDate ?? current.nextRecurrenceDate,
      recurrenceEndDate: recurrenceEndDate ?? current.recurrenceEndDate,
      recurrenceMaxOccurrences:
          recurrenceMaxOccurrences ?? current.recurrenceMaxOccurrences,
      recurrenceOccurrencesCreated: current.recurrenceOccurrencesCreated,
    );
    _schedules[current.invoiceId] = updated;
    return updated;
  }

  @override
  Future<void> cancel(int invoiceId) async {
    if (!_schedules.containsKey(invoiceId)) throw const NotFoundException();
    _schedules.remove(invoiceId);
  }
}

Future<void> pumpScreen(
  WidgetTester tester, {
  required RecurringScheduleCubit scheduleCubit,
  required InvoiceCubit invoiceCubit,
  required CustomerCubit customerCubit,
  Object? editExtra,
  bool navigateToEdit = false,
}) async {
  final router = GoRouter(
    initialLocation: '/recurring',
    routes: [
      GoRoute(
        path: '/recurring',
        builder: (context, state) => const RecurringSchedulesScreen(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) => RecurringScheduleEditScreen(
          schedule: editExtra is RecurringSchedule ? editExtra : null,
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<RecurringScheduleCubit>.value(value: scheduleCubit),
        BlocProvider<InvoiceCubit>.value(value: invoiceCubit),
        BlocProvider<CustomerCubit>.value(value: customerCubit),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  // Open the edit screen on top of the list so saving/cancelling can pop
  // back (mirrors the real navigation).
  if (navigateToEdit) {
    // ignore: unawaited_futures
    router.push('/edit', extra: editExtra);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(() async {
    // Date formatting uses the German default locale (see core/utils/format).
    await initializeDateFormatting('de_DE');
  });

  testWidgets('renders schedules with interval, next date and constraints', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      scheduleCubit: RecurringScheduleCubit(
        _FakeScheduleRepository(
          schedules: [
            RecurringSchedule(
              invoiceId: 1,
              invoiceNumber: 'RE-1',
              interval: RecurrenceInterval.monthly,
              issueDate: DateTime(2026, 8, 1),
              customerId: null,
              nextRecurrenceDate: DateTime(2026, 9, 1),
              recurrenceEndDate: DateTime(2026, 12, 31),
              recurrenceMaxOccurrences: 12,
            ),
          ],
        ),
      ),
      invoiceCubit: InvoiceCubit(MockInvoiceRepository()),
      customerCubit: CustomerCubit(MockCustomerRepository()),
    );

    expect(find.textContaining('RE-1'), findsOneWidget);
    // Monthly interval and the formatted next date.
    expect(find.text('Monthly · 1.9.2026'), findsOneWidget);
    // Both constraints are shown on the tile.
    expect(find.textContaining('Ends'), findsOneWidget);
    expect(find.textContaining('Stops after 12 invoices'), findsOneWidget);
  });

  testWidgets('attach flow: pick an invoice and save the schedule', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final invoiceRepository = MockInvoiceRepository();
    for (var i = 0; i < 2; i++) {
      await invoiceRepository.create(
        items: [InvoiceItem(description: 'Work')],
        issueDate: DateTime(2026, 8, 10),
      );
    }
    final scheduleRepository = _FakeScheduleRepository();

    await pumpScreen(
      tester,
      scheduleCubit: RecurringScheduleCubit(scheduleRepository),
      invoiceCubit: InvoiceCubit(invoiceRepository),
      customerCubit: CustomerCubit(MockCustomerRepository()),
      navigateToEdit: true,
    );

    // Pick RE-1 from the invoice dropdown.
    await tester.tap(find.byType(DropdownButtonFormField<Invoice>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('RE-1').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on the list with the new schedule tile.
    expect(find.textContaining('RE-1 · No customer'), findsOneWidget);
    expect(find.text('Monthly · 1.8.2026'), findsOneWidget);
  });

  testWidgets('rejects an occurrence limit below one', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final invoiceRepository = MockInvoiceRepository();
    await invoiceRepository.create(
      items: [InvoiceItem(description: 'Work')],
      issueDate: DateTime(2026, 8, 10),
    );
    final scheduleRepository = _FakeScheduleRepository();

    await pumpScreen(
      tester,
      scheduleCubit: RecurringScheduleCubit(scheduleRepository),
      invoiceCubit: InvoiceCubit(invoiceRepository),
      customerCubit: CustomerCubit(MockCustomerRepository()),
      navigateToEdit: true,
    );

    await tester.enterText(find.byType(TextFormField), '0');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    // The inline validator blocks the submit.
    expect(
      find.text('Please enter a whole number greater than zero.'),
      findsOneWidget,
    );
    expect(scheduleRepository._schedules, isEmpty);
  });

  testWidgets('cancel flow asks for confirmation and removes the schedule', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final schedule = RecurringSchedule(
      invoiceId: 3,
      invoiceNumber: 'RE-3',
      interval: RecurrenceInterval.weekly,
      issueDate: DateTime(2026, 8, 1),
      nextRecurrenceDate: DateTime(2026, 8, 8),
    );
    final scheduleRepository = _FakeScheduleRepository(schedules: [schedule]);

    await pumpScreen(
      tester,
      scheduleCubit: RecurringScheduleCubit(scheduleRepository),
      invoiceCubit: InvoiceCubit(MockInvoiceRepository()),
      customerCubit: CustomerCubit(MockCustomerRepository()),
      navigateToEdit: true,
      editExtra: schedule,
    );

    await tester.ensureVisible(find.text('Cancel schedule'));
    await tester.tap(find.text('Cancel schedule').last);
    await tester.pumpAndSettle();

    // The confirmation explains that existing invoices remain.
    expect(
      find.textContaining('Existing invoices will remain.'),
      findsOneWidget,
    );

    // Confirm with the dialog's primary action.
    await tester.tap(find.text('Cancel schedule').last);
    await tester.pumpAndSettle();

    // Back on the list — now empty.
    expect(find.textContaining('No recurring invoices yet'), findsOneWidget);
  });
}
