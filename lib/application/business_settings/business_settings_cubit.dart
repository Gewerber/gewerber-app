import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/business_settings/business_settings_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/business_settings.dart';
import 'package:gewerber_app/domain/repositories/business_settings_repository.dart';

/// Owns the active business's settings.
@LazySingleton()
class BusinessSettingsCubit extends Cubit<BusinessSettingsState> {
  BusinessSettingsCubit(this._repository)
    : super(const BusinessSettingsState());

  final BusinessSettingsRepository _repository;

  /// Loads the settings of the business with [businessId].
  Future<void> load({required int businessId}) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        status: BusinessSettingsViewStatus.loading,
        clearFailure: true,
      ),
    );
    try {
      final settings = await _repository.get(businessId: businessId);
      if (isClosed) return;
      emit(
        BusinessSettingsState(
          status: BusinessSettingsViewStatus.loaded,
          settings: settings,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BusinessSettingsViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BusinessSettingsViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Persists the given settings.
  ///
  /// Returns `true` on success.
  Future<bool> update(
    BusinessSettings settings, {
    required int businessId,
  }) async {
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      final saved = await _repository.update(settings, businessId: businessId);
      if (!isClosed) {
        emit(
          BusinessSettingsState(
            status: BusinessSettingsViewStatus.loaded,
            settings: saved,
            isSaving: false,
          ),
        );
      }
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(isSaving: false, failure: mapAppException(e)));
      return false;
    } on Exception {
      if (isClosed) return false;
      emit(state.copyWith(isSaving: false, failure: const NetworkFailure()));
      return false;
    }
  }
}
