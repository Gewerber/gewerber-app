import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/widgets/common/beta_banner.dart';
import 'package:gewerber_app/application/settings/beta_banner/beta_banner_cubit.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BetaBannerCubit>(
      create: (context) => BetaBannerCubit(),
      child: Scaffold(
        body: Column(
          children: [
            const BetaBanner(),
            Expanded(child: AppRouter()),
          ],
        ),
      ),
    );
  }
}
