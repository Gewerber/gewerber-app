import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/mappers/customer_mapper.dart';

/// Transport-level customer calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class CustomerRemoteDataSource {
  CustomerRemoteDataSource(this._clientFactory, this._mapper);

  final ServerpodClientFactory _clientFactory;
  final CustomerMapper _mapper;

  sdk.Client get _client => _clientFactory.client;

  Future<List<Customer>> list({
    CustomerStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await _client.customer.list(
        status: status == null ? null : _mapper.toProtocolStatus(status),
        limit: limit,
        offset: offset,
      );
      return models.map(_mapper.fromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Customer> get(int customerId) async {
    try {
      final model = await _client.customer.get(customerId);
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Customer> create({
    required String name,
    String? companyName,
    String? vatId,
    String? email,
    String? phone,
    Address? address,
    String? notes,
  }) async {
    try {
      final model = await _client.customer.create(
        sdk.CreateCustomerRequest(
          name: name,
          companyName: companyName,
          vatId: vatId,
          email: email,
          phone: phone,
          address: _mapper.toProtocolAddress(address),
          notes: notes,
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Customer> update(Customer customer) async {
    try {
      final model = await _client.customer.update(
        sdk.UpdateCustomerRequest(
          customerId: customer.id,
          status: _mapper.toProtocolStatus(customer.status),
          name: customer.name,
          companyName: customer.companyName,
          vatId: customer.vatId,
          email: customer.email,
          phone: customer.phone,
          address: _mapper.toProtocolAddress(customer.address),
          notes: customer.notes,
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }
}
