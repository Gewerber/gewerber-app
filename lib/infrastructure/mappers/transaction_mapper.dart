import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/transaction.dart';

/// Maps between the domain accounting entities and the protocol models.
@Injectable()
class TransactionMapper {
  const TransactionMapper();

  AccountingTransaction fromModel(sdk.AccountingTransaction model) {
    return AccountingTransaction(
      id: model.id ?? -1,
      type: TransactionType.fromName(model.type.name),
      category: TransactionCategory.fromName(model.category.name),
      description: model.description,
      occurredAt: model.occurredAt,
      amountCents: model.amountCents,
      receiptDocumentId: model.receiptDocumentId,
      relatedInvoiceId: model.relatedInvoiceId,
    );
  }

  ProfitLossLine lineFromModel(sdk.ProfitLossLine model) {
    return ProfitLossLine(
      category: TransactionCategory.fromName(model.category.name),
      amountCents: model.amountCents,
      count: model.count,
    );
  }

  ProfitLossReport reportFromModel(sdk.ProfitLossReport model) {
    return ProfitLossReport(
      from: model.from,
      to: model.to,
      incomeCents: model.incomeCents,
      expenseCents: model.expenseCents,
      profitCents: model.profitCents,
      incomeLines: model.incomeLines.map(lineFromModel).toList(),
      expenseLines: model.expenseLines.map(lineFromModel).toList(),
    );
  }

  sdk.TransactionType toProtocolType(TransactionType type) =>
      sdk.TransactionType.values.byName(type.name);

  sdk.TransactionCategory toProtocolCategory(TransactionCategory category) =>
      sdk.TransactionCategory.values.byName(category.name);
}
