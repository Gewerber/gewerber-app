import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/mappers/business_mapper.dart';

/// Transport-level business calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class BusinessRemoteDataSource {
  BusinessRemoteDataSource(this._clientFactory, this._mapper);

  final ServerpodClientFactory _clientFactory;
  final BusinessMapper _mapper;

  sdk.Client get _client => _clientFactory.client;

  /// Lists all businesses the signed-in user belongs to.
  Future<List<Business>> listMine() async {
    try {
      final models = await _client.business.listMine();
      return models.map(_mapper.fromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Returns a single business by its ID.
  Future<Business> getBusiness(int businessId) async {
    try {
      final model = await _client.business.get(businessId: businessId);
      return _mapper.fromModel(model);
    } on sdk.NotFoundException {
      throw const NotFoundException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Creates a business on behalf of the signed-in user.
  Future<Business> create({
    required String name,
    LegalForm legalForm = LegalForm.einzelunternehmen,
    bool isKleinunternehmer = false,
    String? vatId,
    String? taxNumber,
    String? email,
    String? phone,
    Address? address,
    BusinessLocale locale = BusinessLocale.de,
    BusinessCurrency currency = BusinessCurrency.eur,
  }) async {
    try {
      final model = await _client.business.create(
        sdk.CreateBusinessRequest(
          name: name,
          legalForm: _mapper.toProtocolLegalForm(legalForm),
          isKleinunternehmer: isKleinunternehmer,
          vatId: vatId,
          taxNumber: taxNumber,
          email: email,
          phone: phone,
          address: address == null ? null : _mapper.toProtocolAddress(address),
          locale: _mapper.toProtocolLocale(locale),
          currency: _mapper.toProtocolCurrency(currency),
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Updates an existing business.
  Future<Business> update(Business business) async {
    try {
      final model = await _client.business.update(
        sdk.UpdateBusinessRequest(
          businessId: business.id,
          name: business.name,
          legalForm: _mapper.toProtocolLegalForm(business.legalForm),
          isKleinunternehmer: business.isKleinunternehmer,
          vatId: business.vatId,
          taxNumber: business.taxNumber,
          email: business.email,
          phone: business.phone,
          address: business.address == null
              ? null
              : _mapper.toProtocolAddress(business.address!),
          locale: _mapper.toProtocolLocale(business.locale),
          currency: _mapper.toProtocolCurrency(business.currency),
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }
}
