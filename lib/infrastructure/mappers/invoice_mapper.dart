import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/invoice.dart';

/// Maps between the domain [Invoice]/[InvoiceItem] and the protocol models.
@injectable
class InvoiceMapper {
  const InvoiceMapper();

  Invoice fromModel(sdk.Invoice model) {
    return Invoice(
      id: model.id ?? -1,
      number: model.number,
      status: InvoiceStatus.fromName(model.status.name),
      customerId: model.customerId,
      issueDate: model.issueDate,
      dueDate: model.dueDate,
      serviceDateFrom: model.serviceDateFrom,
      serviceDateTo: model.serviceDateTo,
      subtotalCents: model.subtotalCents,
      vatTotalCents: model.vatTotalCents,
      totalCents: model.totalCents,
      notes: model.notes,
    );
  }

  InvoiceItem itemFromModel(sdk.InvoiceItem model) {
    return InvoiceItem(
      description: model.description,
      quantity: model.quantity,
      unitPriceCents: model.unitPriceCents,
      vatRate: InvoiceVatRate.fromName(model.vatRate.name),
      lineTotalCents: model.lineTotalCents,
    );
  }

  sdk.InvoiceItemRequest toItemRequest(InvoiceItem item) {
    return sdk.InvoiceItemRequest(
      description: item.description,
      quantity: item.quantity,
      unitPriceCents: item.unitPriceCents,
      vatRate: sdk.VatRate.values.byName(item.vatRate.name),
    );
  }

  sdk.InvoiceStatus toProtocolStatus(InvoiceStatus status) =>
      sdk.InvoiceStatus.values.byName(status.name);
}
