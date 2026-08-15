import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/business/business_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/repositories/business_repository.dart';

/// Owns the signed-in user's businesses.
///
/// Loads the user's businesses after sign-in and exposes the active business
/// to the rest of the app (billing address, VAT settings, tenant for
/// invoicing).
@LazySingleton()
class BusinessCubit extends Cubit<BusinessState> {
  BusinessCubit(this._repository) : super(const BusinessState());

  final BusinessRepository _repository;

  /// Loads the user's businesses from the backend.
  Future<void> load() async {
    if (state.isLoading) return;
    emit(state.copyWith(status: BusinessStatus.loading, clearFailure: true));
    try {
      final businesses = await _repository.listMine();
      if (isClosed) return;
      emit(
        BusinessState(status: BusinessStatus.loaded, businesses: businesses),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BusinessStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BusinessStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Creates a business for the signed-in user.
  ///
  /// Returns `true` on success; the new business becomes the active one.
  Future<bool> create({
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
    try {
      final business = await _repository.create(
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
      if (!isClosed) {
        emit(
          BusinessState(
            status: BusinessStatus.loaded,
            businesses: [...state.businesses, business],
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Updates an existing business.
  ///
  /// Returns `true` on success.
  Future<bool> update(Business business) async {
    try {
      final updated = await _repository.update(business);
      if (!isClosed) {
        emit(
          BusinessState(
            status: BusinessStatus.loaded,
            businesses: [
              for (final current in state.businesses)
                if (current.id == updated.id) updated else current,
            ],
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }
}
