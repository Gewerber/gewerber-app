import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/repositories/business_repository.dart';

/// In-memory [BusinessRepository] backing the demo experience and the widget
/// tests. Data lives for the app session only.
@LazySingleton(as: BusinessRepository, env: [AppEnvironment.authMock])
class MockBusinessRepository implements BusinessRepository {
  final List<Business> _businesses = [];

  @override
  Future<List<Business>> listMine() async => List.unmodifiable(_businesses);

  @override
  Future<Business> getBusiness(int businessId) async {
    final match = _businesses.where((b) => b.id == businessId);
    if (match.isNotEmpty) return match.first;
    throw const NotFoundException();
  }

  @override
  Future<Business> create({
    required String name,
    LegalForm legalForm = LegalForm.einzelunternehmen,
    bool isKleinunternehmer = false,
    String? vatId,
    String? email,
    String? phone,
    Address? address,
    BusinessLocale locale = BusinessLocale.de,
    BusinessCurrency currency = BusinessCurrency.eur,
  }) async {
    final business = Business(
      id: _businesses.length + 1,
      name: name,
      legalForm: legalForm,
      isKleinunternehmer: isKleinunternehmer,
      vatId: vatId,
      email: email,
      phone: phone,
      address: address,
      locale: locale,
      currency: currency,
    );
    _businesses.add(business);
    return business;
  }

  @override
  Future<Business> update(Business business) async {
    final index = _businesses.indexWhere((value) => value.id == business.id);
    if (index >= 0) {
      _businesses[index] = business;
      return business;
    }
    throw StateError('Unknown business id ${business.id}');
  }
}
