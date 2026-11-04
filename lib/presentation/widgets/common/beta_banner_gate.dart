import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/settings/beta_banner/beta_banner_cubit.dart';
import 'package:gewerber_app/presentation/widgets/common/beta_banner.dart';

/// Shows the public-beta banner until the user dismisses it.
class BetaBannerGate extends StatelessWidget {
  /// Creates a [BetaBannerGate].
  const BetaBannerGate({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<BetaBannerCubit>();
    if (cubit.state.isDismissed) return const SizedBox.shrink();
    return BetaBanner(onDismiss: cubit.dismiss);
  }
}
