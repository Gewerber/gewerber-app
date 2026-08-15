import 'package:equatable/equatable.dart';

import 'package:gewerber_app/domain/entities/business.dart';

/// Customer status, mirroring the server's `CustomerStatus` enum.
enum CustomerStatus {
  active,
  archived;

  static CustomerStatus fromName(String name) {
    return CustomerStatus.values.firstWhere(
      (value) => value.name == name,
      orElse: () => CustomerStatus.active,
    );
  }
}

/// A customer the business sends invoices to.
class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    this.companyName,
    this.vatId,
    this.email,
    this.phone,
    this.address,
    this.notes,
    this.status = CustomerStatus.active,
  });

  final int id;
  final String name;
  final String? companyName;
  final String? vatId;
  final String? email;
  final String? phone;
  final Address? address;
  final String? notes;
  final CustomerStatus status;

  /// Display name: company name when present, otherwise the contact name.
  String get displayName => companyName ?? name;

  Customer copyWithStatus(CustomerStatus status) {
    return Customer(
      id: id,
      name: name,
      companyName: companyName,
      vatId: vatId,
      email: email,
      phone: phone,
      address: address,
      notes: notes,
      status: status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    companyName,
    vatId,
    email,
    phone,
    address,
    notes,
    status,
  ];
}
