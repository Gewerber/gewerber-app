import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/guidance.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/mappers/guidance_mapper.dart';

/// Transport-level guidance calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class GuidanceRemoteDataSource {
  GuidanceRemoteDataSource(this._clientFactory, this._mapper);

  final ServerpodClientFactory _clientFactory;
  final GuidanceMapper _mapper;

  sdk.Client get _client => _clientFactory.client;

  Future<List<GuidanceTip>> tips() async {
    try {
      final models = await _client.guidance.tips();
      return models.map(_mapper.tipFromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<List<GuidanceChecklist>> checklists() async {
    try {
      final models = await _client.guidance.checklists();
      return models.map(_mapper.checklistFromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Set<String>> completedItemKeys() async {
    try {
      final models = await _client.guidance.myProgress();
      return models
          .where((model) => model.completedAt != null)
          .map((model) => model.itemKey)
          .toSet();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<void> markCompleted(String itemKey) async {
    try {
      await _client.guidance.markCompleted(itemKey);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<void> dismissTip(String topic) async {
    try {
      await _client.guidance.dismissTip(topic);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }
}
