import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/business.dart';

/// Loading state of the user's businesses.
enum BusinessStatus { initial, loading, loaded, failure }

/// Immutable business state.
class BusinessState extends Equatable {
  const BusinessState({
    this.status = BusinessStatus.initial,
    this.businesses = const [],
    this.failure,
  });

  final BusinessStatus status;
  final List<Business> businesses;
  final Failure? failure;

  bool get isLoading => status == BusinessStatus.loading;
  bool get isLoaded => status == BusinessStatus.loaded;
  bool get hasBusiness => businesses.isNotEmpty;

  /// The first business of the user; businesses beyond the first are rare but
  /// supported by the backend.
  Business? get activeBusiness => businesses.isEmpty ? null : businesses.first;

  BusinessState copyWith({
    BusinessStatus? status,
    List<Business>? businesses,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return BusinessState(
      status: status ?? this.status,
      businesses: businesses ?? this.businesses,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, businesses, failure];
}
