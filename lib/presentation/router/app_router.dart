import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/presentation/screens/forgot_password/forgot_password_screen.dart';
import 'package:gewerber_app/presentation/screens/home/accounting_entry_create_screen.dart';
import 'package:gewerber_app/presentation/screens/home/accounting_screen.dart';
import 'package:gewerber_app/presentation/screens/home/about_screen.dart';
import 'package:gewerber_app/presentation/screens/home/business_profile_screen.dart';
import 'package:gewerber_app/presentation/screens/home/checklist_screen.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/guidance_screen.dart';
import 'package:gewerber_app/presentation/screens/home/home_shell.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_create_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_detail_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoicing_screen.dart';
import 'package:gewerber_app/presentation/screens/home/language_screen.dart';
import 'package:gewerber_app/presentation/screens/home/projects_screen.dart';
import 'package:gewerber_app/presentation/screens/home/report_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_screen.dart';
import 'package:gewerber_app/presentation/screens/home/time_entry_create_screen.dart';
import 'package:gewerber_app/presentation/screens/home/time_tracking_screen.dart';
import 'package:gewerber_app/presentation/screens/home/timer_screen.dart';
import 'package:gewerber_app/presentation/screens/home/theme_screen.dart';
import 'package:gewerber_app/presentation/screens/auth/login_screen.dart';
import 'package:gewerber_app/presentation/screens/auth/register_screen.dart';
import 'package:gewerber_app/presentation/screens/splash/splash_screen.dart';

import 'route_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Application router.
///
/// Navigation is plain for now; auth-aware redirects are added together with
/// the authentication blocs (application/auth bloc).
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.splash,
  redirect: (context, state) {
    // The shell has no path of its own; landing on it goes to the dashboard.
    if (state.matchedLocation == RouteNames.app) {
      return RouteNames.dashboard;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.invoicing,
              builder: (context, state) => const InvoicingScreen(),
            ),
            GoRoute(
              path: RouteNames.invoiceCreate,
              builder: (context, state) => const InvoiceCreateScreen(),
            ),
            GoRoute(
              path: RouteNames.invoiceDetail,
              builder: (context, state) => const InvoiceDetailScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.timeTracking,
              builder: (context, state) => const TimeTrackingScreen(),
            ),
            GoRoute(
              path: RouteNames.timeProjects,
              builder: (context, state) => const ProjectsScreen(),
            ),
            GoRoute(
              path: RouteNames.timeTimer,
              builder: (context, state) => const TimerScreen(),
            ),
            GoRoute(
              path: RouteNames.timeEntryCreate,
              builder: (context, state) => const TimeEntryCreateScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.accounting,
              builder: (context, state) => const AccountingScreen(),
            ),
            GoRoute(
              path: RouteNames.accountingReport,
              builder: (context, state) => const ReportScreen(),
            ),
            GoRoute(
              path: RouteNames.accountingEntryCreate,
              builder: (context, state) => const AccountingEntryCreateScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: RouteNames.settingsBusiness,
              builder: (context, state) => const BusinessProfileScreen(),
            ),
            GoRoute(
              path: RouteNames.settingsLanguage,
              builder: (context, state) => const LanguageScreen(),
            ),
            GoRoute(
              path: RouteNames.settingsTheme,
              builder: (context, state) => const ThemeScreen(),
            ),
            GoRoute(
              path: RouteNames.settingsAbout,
              builder: (context, state) => const AboutScreen(),
            ),
            GoRoute(
              path: RouteNames.guides,
              builder: (context, state) => const GuidanceScreen(),
            ),
            GoRoute(
              path: RouteNames.guideChecklist,
              builder: (context, state) => const ChecklistScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
