import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
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
      child: BlocProvider<AppSettingsCubit>(
        create: (_) => AppSettingsCubit(),
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Gewerber',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: GewerberTheme.light(),
          darkTheme: GewerberTheme.dark(),
          themeMode: state.themeMode,
          locale: state.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        );
      },
    );
  }
}
