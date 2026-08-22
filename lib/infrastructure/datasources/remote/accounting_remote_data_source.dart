import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/mappers/transaction_mapper.dart';

/// Transport-level accounting calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class AccountingRemoteDataSource {
  AccountingRemoteDataSource(this._clientFactory, this._mapper);

  final ServerpodClientFactory _clientFactory;
  final TransactionMapper _mapper;

  sdk.Client get _client => _clientFactory.client;

  Future<List<AccountingTransaction>> list({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await _client.accounting.list(
        type: type == null ? null : _mapper.toProtocolType(type),
        category: category == null
            ? null
            : _mapper.toProtocolCategory(category),
        from: from,
        to: to,
        limit: limit,
        offset: offset,
      );
      return models.map(_mapper.fromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<AccountingTransaction> create({
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
    required int amountCents,
    String? description,
  }) async {
    try {
      final model = await _client.accounting.create(
        sdk.CreateTransactionRequest(
          type: _mapper.toProtocolType(type),
          category: _mapper.toProtocolCategory(category),
          occurredAt: occurredAt,
          amountCents: amountCents,
          description: description,
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<AccountingTransaction> update(
    AccountingTransaction transaction,
  ) async {
    try {
      final model = await _client.accounting.update(
        sdk.UpdateTransactionRequest(
          transactionId: transaction.id,
          type: _mapper.toProtocolType(transaction.type),
          category: _mapper.toProtocolCategory(transaction.category),
          occurredAt: transaction.occurredAt,
          amountCents: transaction.amountCents,
          description: transaction.description,
          receiptDocumentId: transaction.receiptDocumentId,
          relatedInvoiceId: transaction.relatedInvoiceId,
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<void> delete(int transactionId) async {
    try {
      await _client.accounting.delete(transactionId);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<ProfitLossReport> profitLoss(DateTime from, DateTime to) async {
    try {
      final model = await _client.accounting.profitLoss(from, to);
      return _mapper.reportFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<String> exportCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      return await _client.accounting.exportCsv(
        type: type == null ? null : _mapper.toProtocolType(type),
        from: from,
        to: to,
      );
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }
}
