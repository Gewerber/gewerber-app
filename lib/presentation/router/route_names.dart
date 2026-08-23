/// Central route definitions for the whole app.
abstract final class RouteNames {
  const RouteNames._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  /// Authenticated area (stateful shell).
  static const String app = '/app';
  static const String dashboard = '/app/dashboard';
  static const String invoicing = '/app/invoicing';
  static const String timeTracking = '/app/time';
  static const String accounting = '/app/accounting';
  static const String settings = '/app/settings';

  /// Onboarding shown to signed-in users without a business.
  static const String onboarding = '/onboarding';

  /// Invoicing sub-screens.
  static const String invoiceCreate = '/app/invoicing/new';
  static const String invoiceDetail = '/app/invoicing/detail';
  static const String customers = '/app/invoicing/customers';
  static const String customerNew = '/app/invoicing/customers/new';
  static const String customerEdit = '/app/invoicing/customers/edit';
  static const String invoiceTemplates = '/app/invoicing/templates';
  static const String templateNew = '/app/invoicing/templates/new';
  static const String templateEdit = '/app/invoicing/templates/edit';
  static const String recurringSchedules = '/app/invoicing/recurring';
  static const String recurringScheduleEdit = '/app/invoicing/recurring/edit';

  /// Time tracking sub-screens.
  static const String timeProjects = '/app/time/projects';
  static const String timeTimer = '/app/time/timer';
  static const String timeEntryCreate = '/app/time/new';
  static const String timeReport = '/app/time/report';

  /// Accounting sub-screens.
  static const String accountingReport = '/app/accounting/reports';
  static const String accountingEntryCreate = '/app/accounting/new';

  /// Guidance system.
  static const String guides = '/app/guides';
  static const String guideChecklist = '/app/guides/checklist';
  static const String guideTips = '/app/guides/tips';

  /// Settings sub-screens.
  static const String settingsProfile = '/app/settings/profile';
  static const String settingsBusiness = '/app/settings/business';
  static const String settingsBusinessSettings =
      '/app/settings/business-settings';
  static const String settingsLanguage = '/app/settings/language';
  static const String settingsTheme = '/app/settings/theme';
  static const String settingsAbout = '/app/settings/about';
}
