import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';
import 'package:gewerber_app/domain/repositories/invoice_template_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/invoice_template_remote_data_source.dart';

/// Serverpod-backed [InvoiceTemplateRepository].
@LazySingleton(as: InvoiceTemplateRepository, env: [AppEnvironment.authLive])
class ServerpodInvoiceTemplateRepository implements InvoiceTemplateRepository {
  ServerpodInvoiceTemplateRepository(this._dataSource);

  final InvoiceTemplateRemoteDataSource _dataSource;

  @override
  Future<List<InvoiceTemplate>> list({int? limit, int? offset}) =>
      _guard(() => _dataSource.list(limit: limit, offset: offset));

  @override
  Future<InvoiceTemplate> get(int templateId) =>
      _guard(() => _dataSource.get(templateId));

  @override
  Future<InvoiceTemplate> create({
    required String name,
    bool isDefault = false,
    String? headerText,
    String? footerText,
  }) => _guard(
    () => _dataSource.create(
      name: name,
      isDefault: isDefault,
      headerText: headerText,
      footerText: footerText,
    ),
  );

  @override
  Future<InvoiceTemplate> update(InvoiceTemplate template) =>
      _guard(() => _dataSource.update(template));

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
