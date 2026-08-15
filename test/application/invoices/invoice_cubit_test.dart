import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';

class _FakeInvoiceRepository implements InvoiceRepository {
  _FakeInvoiceRepository({List<Invoice>? invoices, this.failLoad = false})
    : _invoices = List.of(invoices ?? const []);

  final List<Invoice> _invoices;
  bool failLoad;

  @override
  Future<List<Invoice>> list({
    InvoiceStatus? status,
    int? limit,
    int? offset,
  }) async {
    if (failLoad) throw const NetworkException();
    return List.unmodifiable(_invoices);
  }

  @override
  Future<({Invoice invoice, List<InvoiceItem> items})> get(
    int invoiceId,
  ) async {
    final invoice = _invoices.firstWhere((value) => value.id == invoiceId);
    return (invoice: invoice, items: const <InvoiceItem>[]);
  }

  @override
  Future<Invoice> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
  }) async {
    final invoice = Invoice(
      id: _invoices.length + 1,
      number: 'RE-001',
      issueDate: issueDate ?? DateTime(2026, 8, 15),
      customerId: customerId,
      dueDate: dueDate,
      notes: notes,
    );
    _invoices.add(invoice);
    return invoice;
  }

  @override
  Future<Invoice> update(
    Invoice invoice, {
    required List<InvoiceItem> items,
  }) async {
    final index = _invoices.indexWhere((value) => value.id == invoice.id);
    if (index < 0) throw StateError('Unknown invoice ${invoice.id}');
    _invoices[index] = invoice;
    return invoice;
  }

  @override
  Future<void> delete(int invoiceId) async {
    _invoices.removeWhere((value) => value.id == invoiceId);
  }
}

void main() {
  final invoice = Invoice(
    id: 1,
    number: 'RE-2026-0001',
    issueDate: DateTime(2026, 8, 15),
  );

  test('starts in the initial state', () {
    final cubit = InvoiceCubit(_FakeInvoiceRepository());

    expect(cubit.state.status, InvoiceViewStatus.initial);
    expect(cubit.state.invoices, isEmpty);
  });

  test('load emits loading then loaded with the invoices', () async {
    final cubit = InvoiceCubit(_FakeInvoiceRepository(invoices: [invoice]));
    final states = <InvoiceViewStatus>[];
    cubit.stream.listen((state) => states.add(state.status));

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states, [InvoiceViewStatus.loading, InvoiceViewStatus.loaded]);
    expect(cubit.state.invoices, [invoice]);
  });

  test('load failure maps to a failure state', () async {
    final cubit = InvoiceCubit(_FakeInvoiceRepository(failLoad: true));

    await cubit.load();

    expect(cubit.state.status, InvoiceViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('get returns the invoice with its items', () async {
    final cubit = InvoiceCubit(_FakeInvoiceRepository(invoices: [invoice]));

    final result = await cubit.get(1);

    expect(result?.invoice.id, 1);
    expect(result?.items, isEmpty);
  });

  test('create appends the invoice and returns true', () async {
    final cubit = InvoiceCubit(_FakeInvoiceRepository());

    final created = await cubit.create(
      items: const [InvoiceItem(description: 'Beratung', unitPriceCents: 5000)],
    );

    expect(created, isTrue);
    expect(cubit.state.invoices, hasLength(1));
  });

  test('update replaces the matching invoice', () async {
    final cubit = InvoiceCubit(_FakeInvoiceRepository(invoices: [invoice]));
    await cubit.load();

    final updated = await cubit.update(
      Invoice(
        id: 1,
        number: 'RE-2026-0001',
        issueDate: DateTime(2026, 8, 15),
        notes: 'Bezahlt',
      ),
      items: const [InvoiceItem(description: 'Beratung')],
    );

    expect(updated, isTrue);
    expect(cubit.state.invoices.single.notes, 'Bezahlt');
  });

  test('delete removes the invoice from the list', () async {
    final cubit = InvoiceCubit(_FakeInvoiceRepository(invoices: [invoice]));
    await cubit.load();

    final deleted = await cubit.delete(1);

    expect(deleted, isTrue);
    expect(cubit.state.invoices, isEmpty);
  });
}
