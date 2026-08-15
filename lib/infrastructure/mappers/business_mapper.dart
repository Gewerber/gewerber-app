import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/business.dart';

/// Maps between the domain [Business] and the protocol business model.
@injectable
class BusinessMapper {
  const BusinessMapper();

  Business fromModel(sdk.Business model) {
    final address = model.address;
    return Business(
      id: model.id ?? -1,
      name: model.name,
      legalForm: LegalForm.fromName(model.legalForm.name),
      isKleinunternehmer: model.isKleinunternehmer,
      vatId: model.vatId,
      email: model.email,
      phone: model.phone,
      address: address == null
          ? null
          : Address(
              street: address.street,
              zip: address.zip,
              city: address.city,
            ),
      locale: BusinessLocale.fromName(model.locale.name),
      currency: BusinessCurrency.fromName(model.currency.name),
    );
  }

  sdk.Address toProtocolAddress(Address address) {
    return sdk.Address(
      street: address.street,
      zip: address.zip,
      city: address.city,
    );
  }

  sdk.LegalForm toProtocolLegalForm(LegalForm legalForm) =>
      sdk.LegalForm.values.byName(legalForm.name);

  sdk.Locale toProtocolLocale(BusinessLocale locale) =>
      sdk.Locale.values.byName(locale.name);

  sdk.Currency toProtocolCurrency(BusinessCurrency currency) =>
      sdk.Currency.values.byName(currency.name);
}
