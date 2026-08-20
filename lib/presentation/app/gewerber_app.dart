import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/business_settings/business_settings_cubit.dart';
import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/application/settings/app_settings_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';

/// Root application widget.
class GewerberApp extends StatelessWidget {
  const GewerberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: getIt<AuthCubit>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppSettingsCubit>.value(
            value: getIt<AppSettingsCubit>(),
          ),
          BlocProvider<BusinessCubit>.value(value: getIt<BusinessCubit>()),
          BlocProvider<BusinessSettingsCubit>.value(
            value: getIt<BusinessSettingsCubit>(),
          ),
          BlocProvider<CustomerCubit>.value(value: getIt<CustomerCubit>()),
          BlocProvider<InvoiceCubit>.value(value: getIt<InvoiceCubit>()),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.authenticated,
      listener: (context, state) {
        // Restore the server-side preferences and the user's businesses right
        // after signing in.
        context.read<AppSettingsCubit>().syncFromServer();
        context.read<BusinessCubit>().load();
      },
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, state) {
          // Overlays a "DEV"/"STAGING" ribbon in non-production flavors
          // (configured in the entry points, see `lib/main_*.dart`).
          return FlavorBanner(
            child: MaterialApp.router(
              title: 'Gewerber',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              theme: GewerberTheme.light(),
              darkTheme: GewerberTheme.dark(),
              themeMode: state.themeMode,
              locale: state.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
            ),
          );
        },
      ),
    );
  }
}
