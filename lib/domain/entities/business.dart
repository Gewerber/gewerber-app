import 'package:equatable/equatable.dart';

/// Legal form of a business, mirroring the server's `LegalForm` enum.
enum LegalForm {
  einzelunternehmen,
  kleingewerbe,
  freiberufler,
  gbr,
  other;

  static LegalForm fromName(String name) {
    return LegalForm.values.firstWhere(
      (value) => value.name == name,
      orElse: () => LegalForm.einzelunternehmen,
    );
  }
}

/// Invoicing currency, mirroring the server's `Currency` enum.
enum BusinessCurrency {
  eur;

  static BusinessCurrency fromName(String name) {
    return BusinessCurrency.values.firstWhere(
      (value) => value.name == name,
      orElse: () => BusinessCurrency.eur,
    );
  }
}

/// Business language, mirroring the server's `Locale` enum.
enum BusinessLocale {
  de,
  en,
  ru,
  tr;

  static BusinessLocale fromName(String name) {
    return BusinessLocale.values.firstWhere(
      (value) => value.name == name,
      orElse: () => BusinessLocale.de,
    );
  }
}

/// Postal address of a business.
class Address extends Equatable {
  const Address({required this.street, required this.zip, required this.city});

  final String street;
  final String zip;
  final String city;

  @override
  List<Object?> get props => [street, zip, city];
}

/// A business belonging to the signed-in user.
class Business extends Equatable {
  const Business({
    required this.id,
    required this.name,
    this.legalForm = LegalForm.einzelunternehmen,
    this.isKleinunternehmer = false,
    this.vatId,
    this.taxNumber,
    this.email,
    this.phone,
    this.address,
    this.locale = BusinessLocale.de,
    this.currency = BusinessCurrency.eur,
  });

  final int id;
  final String name;
  final LegalForm legalForm;

  /// Whether the owner is a §19 UStG Kleinunternehmer (VAT-exempt).
  final bool isKleinunternehmer;
  final String? vatId;

  /// Domestic tax number (Steuernummer) assigned by the Finanzamt. Distinct
  /// from [vatId] (the USt-IdNr. used for cross-border B2B invoicing).
  final String? taxNumber;
  final String? email;
  final String? phone;
  final Address? address;
  final BusinessLocale locale;
  final BusinessCurrency currency;

  @override
  List<Object?> get props => [
    id,
    name,
    legalForm,
    isKleinunternehmer,
    vatId,
    taxNumber,
    email,
    phone,
    address,
    locale,
    currency,
  ];
}
