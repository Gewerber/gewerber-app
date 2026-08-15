import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/invoice_remote_data_source.dart';

/// Serverpod-backed [InvoiceRepository].
@LazySingleton(as: InvoiceRepository, env: [AppEnvironment.authLive])
class ServerpodInvoiceRepository implements InvoiceRepository {
  ServerpodInvoiceRepository(this._dataSource);

  final InvoiceRemoteDataSource _dataSource;

  @override
  Future<List<Invoice>> list({InvoiceStatus? status, int? limit, int? offset}) {
    return _guard(
      () => _dataSource.list(status: status, limit: limit, offset: offset),
    );
  }

  @override
  Future<({Invoice invoice, List<InvoiceItem> items})> get(int invoiceId) {
    return _guard(() => _dataSource.get(invoiceId));
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
  }) {
    return _guard(
      () => _dataSource.create(
        items: items,
        customerId: customerId,
        issueDate: issueDate,
        dueDate: dueDate,
        serviceDateFrom: serviceDateFrom,
        serviceDateTo: serviceDateTo,
        notes: notes,
      ),
    );
  }

  @override
  Future<Invoice> update(Invoice invoice, {required List<InvoiceItem> items}) {
    return _guard(() => _dataSource.update(invoice, items: items));
  }

  @override
  Future<void> delete(int invoiceId) {
    return _guard(() => _dataSource.delete(invoiceId));
  }

  /// Runs [action] and rethrows [AppException]s, wrapping any other error as
  /// a [NetworkException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
