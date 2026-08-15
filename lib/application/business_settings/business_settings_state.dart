import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/business_settings.dart';

/// Loading state of the business settings.
enum BusinessSettingsViewStatus { initial, loading, loaded, failure }

/// Immutable business settings state.
class BusinessSettingsState extends Equatable {
  const BusinessSettingsState({
    this.status = BusinessSettingsViewStatus.initial,
    this.settings = const BusinessSettings(),
    this.isSaving = false,
    this.failure,
  });

  final BusinessSettingsViewStatus status;
  final BusinessSettings settings;
  final bool isSaving;
  final Failure? failure;

  bool get isLoading => status == BusinessSettingsViewStatus.loading;

  BusinessSettingsState copyWith({
    BusinessSettingsViewStatus? status,
    BusinessSettings? settings,
    bool? isSaving,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return BusinessSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, settings, isSaving, failure];
}
