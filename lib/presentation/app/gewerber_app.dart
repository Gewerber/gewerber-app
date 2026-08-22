import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/business_settings/business_settings_cubit.dart';
import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/guidance/checklist_cubit.dart';
import 'package:gewerber_app/application/guidance/guidance_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/application/settings/app_settings_state.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/application/time_tracking/time_entries_cubit.dart';
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
          BlocProvider<ChecklistCubit>.value(value: getIt<ChecklistCubit>()),
          BlocProvider<GuidanceCubit>.value(value: getIt<GuidanceCubit>()),
          BlocProvider<ProjectsCubit>.value(value: getIt<ProjectsCubit>()),
          BlocProvider<TimeEntriesCubit>.value(
            value: getIt<TimeEntriesCubit>(),
          ),
          BlocProvider<AccountingCubit>.value(value: getIt<AccountingCubit>()),
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
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          // Restore the server-side preferences and the user's businesses right
          // after signing in.
          context.read<AppSettingsCubit>().syncFromServer();
          context.read<BusinessCubit>().load();
        } else if (state.status == AuthStatus.unauthenticated) {
          // Drop the previous user's preferences and businesses so nothing
          // leaks across accounts after sign-out.
          context.read<AppSettingsCubit>().reset();
          context.read<BusinessCubit>().reset();
        }
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
