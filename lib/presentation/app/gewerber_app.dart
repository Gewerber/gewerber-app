import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/business_settings/business_settings_cubit.dart';
import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/documents/documents_cubit.dart';
import 'package:gewerber_app/application/guidance/checklist_cubit.dart';
import 'package:gewerber_app/application/guidance/guidance_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/application/recurring_schedules/recurring_schedule_cubit.dart';
import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/application/settings/app_settings_state.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/application/time_tracking/time_entries_cubit.dart';
import 'package:gewerber_app/application/user_profile/user_profile_cubit.dart';
import 'package:gewerber_app/application/user_profile/user_profile_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/widgets/common/account_deleted_dialog.dart';

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
          BlocProvider<InvoiceTemplateCubit>.value(
            value: getIt<InvoiceTemplateCubit>(),
          ),
          BlocProvider<RecurringScheduleCubit>.value(
            value: getIt<RecurringScheduleCubit>(),
          ),
          BlocProvider<ChecklistCubit>.value(value: getIt<ChecklistCubit>()),
          BlocProvider<GuidanceCubit>.value(value: getIt<GuidanceCubit>()),
          BlocProvider<ProjectsCubit>.value(value: getIt<ProjectsCubit>()),
          BlocProvider<TimeEntriesCubit>.value(
            value: getIt<TimeEntriesCubit>(),
          ),
          BlocProvider<DocumentsCubit>.value(value: getIt<DocumentsCubit>()),
          BlocProvider<AccountingCubit>.value(value: getIt<AccountingCubit>()),
          BlocProvider<UserProfileCubit>.value(
            value: getIt<UserProfileCubit>(),
          ),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  /// Guards against stacking several "account deleted" dialogs.
  bool _isShowingAccountDeletedDialog = false;

  /// Shows the blocking "account deleted" notice on the root navigator.
  ///
  /// Fired when a profile request reports [AccountDeletedFailure] — the
  /// server answers `NotFoundException` for every call of a deleted account.
  void _showAccountDeletedDialog() {
    if (_isShowingAccountDeletedDialog) return;
    final navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null) return;
    _isShowingAccountDeletedDialog = true;
    showDialog<void>(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (_) => const AccountDeletedDialog(),
    ).whenComplete(() => _isShowingAccountDeletedDialog = false);
  }

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
          context.read<UserProfileCubit>().reset();
          context.read<BusinessCubit>().reset();
        }
      },
      child: BlocListener<UserProfileCubit, UserProfileState>(
        listenWhen: (previous, current) =>
            previous.failure is! AccountDeletedFailure &&
            current.failure is AccountDeletedFailure,
        listener: (context, state) => _showAccountDeletedDialog(),
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
      ),
    );
  }
}
