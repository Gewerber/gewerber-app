import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/business_settings/business_settings_cubit.dart';
import 'package:gewerber_app/application/business_settings/business_settings_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/business_settings.dart';
import 'package:gewerber_app/domain/repositories/business_settings_repository.dart';

class _FakeBusinessSettingsRepository implements BusinessSettingsRepository {
  _FakeBusinessSettingsRepository({
    this._settings = const BusinessSettings(),
    this.failGet = false,
    this.failUpdate = false,
  });

  BusinessSettings _settings;
  bool failGet;
  bool failUpdate;

  @override
  Future<BusinessSettings> get({required int businessId}) async {
    if (failGet) throw const NetworkException();
    return _settings;
  }

  @override
  Future<BusinessSettings> update(
    BusinessSettings settings, {
    required int businessId,
  }) async {
    if (failUpdate) throw const NetworkException();
    _settings = settings;
    return settings;
  }
}

void main() {
  const settings = BusinessSettings(paymentTermsDays: 30);

  test('starts in the initial state', () {
    final cubit = BusinessSettingsCubit(_FakeBusinessSettingsRepository());

    expect(cubit.state.status, BusinessSettingsViewStatus.initial);
    expect(cubit.state.isSaving, isFalse);
  });

  test('load emits loading then loaded with the settings', () async {
    final cubit = BusinessSettingsCubit(
      _FakeBusinessSettingsRepository(settings: settings),
    );
    final states = <BusinessSettingsViewStatus>[];
    cubit.stream.listen((state) => states.add(state.status));

    await cubit.load(businessId: 1);
    await Future<void>.delayed(Duration.zero);

    expect(states, [
      BusinessSettingsViewStatus.loading,
      BusinessSettingsViewStatus.loaded,
    ]);
    expect(cubit.state.settings, settings);
  });

  test('load failure maps to a failure state', () async {
    final cubit = BusinessSettingsCubit(
      _FakeBusinessSettingsRepository(failGet: true),
    );

    await cubit.load(businessId: 1);

    expect(cubit.state.status, BusinessSettingsViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('update saves the settings and clears the saving flag', () async {
    final cubit = BusinessSettingsCubit(
      _FakeBusinessSettingsRepository(settings: settings),
    );
    final updatedSettings = const BusinessSettings(paymentTermsDays: 60);

    final saved = await cubit.update(updatedSettings, businessId: 1);

    expect(saved, isTrue);
    expect(cubit.state.settings, updatedSettings);
    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.status, BusinessSettingsViewStatus.loaded);
  });

  test('update failure returns false and exposes a failure', () async {
    final cubit = BusinessSettingsCubit(
      _FakeBusinessSettingsRepository(failUpdate: true),
    );

    final saved = await cubit.update(
      const BusinessSettings(paymentTermsDays: 60),
      businessId: 1,
    );

    expect(saved, isFalse);
    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });
}
