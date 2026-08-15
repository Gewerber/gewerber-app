import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/business/business_state.dart';

/// Bridges [BusinessCubit] state changes into GoRouter's `refreshListenable`.
///
/// Combined with [AuthRedirectController], the router redirect uses this to
/// send signed-in users without a business to the onboarding flow.
@LazySingleton()
class BusinessRedirectController extends ChangeNotifier {
  BusinessRedirectController(this._cubit) {
    _subscription = _cubit.stream.listen((_) => notifyListeners());
  }

  final BusinessCubit _cubit;
  late final StreamSubscription<BusinessState> _subscription;

  /// Whether the signed-in user has at least one business.
  bool get hasBusiness => _cubit.state.hasBusiness;

  /// Whether the business list has finished loading (needed before the router
  /// may decide on onboarding redirects).
  bool get isReady => _cubit.state.isLoaded;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
