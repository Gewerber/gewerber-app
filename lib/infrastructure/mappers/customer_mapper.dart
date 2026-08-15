import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';

/// Maps between the domain [Customer] and the protocol customer model.
@injectable
class CustomerMapper {
  const CustomerMapper();

  Customer fromModel(sdk.Customer model) {
    final address = model.address;
    return Customer(
      id: model.id ?? -1,
      name: model.name,
      companyName: model.companyName,
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
      notes: model.notes,
      status: CustomerStatus.fromName(model.status.name),
    );
  }

  sdk.Address? toProtocolAddress(Address? address) {
    return address == null
        ? null
        : sdk.Address(
            street: address.street,
            zip: address.zip,
            city: address.city,
          );
  }

  sdk.CustomerStatus toProtocolStatus(CustomerStatus status) =>
      sdk.CustomerStatus.values.byName(status.name);
}
