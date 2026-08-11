// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gewerber';

  @override
  String get tagline => 'Business. Simplified.';

  @override
  String get splashTitle => 'Your business, finally simple.';

  @override
  String get splashSubtitle =>
      'Bills, time tracking and bookkeeping — friendly software made for solo entrepreneurs in Germany.';

  @override
  String get splashGetStarted => 'Get started';

  @override
  String get splashLogIn => 'I already have an account';

  @override
  String get splashPrivacy => 'Open source · GDPR friendly · Built for solos';

  @override
  String get panelTrustCreate => 'Create an account in under two minutes';

  @override
  String get panelTrustInvoices => 'Send your first invoice today';

  @override
  String get panelTrustTax => 'Understand the taxes that apply to you';

  @override
  String get panelTrustOpenSource => 'Your data, your business — open source';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to keep running your business.';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get loginCta => 'Log in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'New to Gewerber?';

  @override
  String get loginCreateAccount => 'Create your account';

  @override
  String get loginInvalidCredentials =>
      'The email address or password is incorrect. Please try again.';

  @override
  String get loginTooManyAttempts =>
      'Too many failed attempts. Please try again in a few minutes.';

  @override
  String get loginDemoCta => 'Explore the demo';

  @override
  String get loginDemoHint =>
      'Signs you in without a real account so you can browse the app.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'A couple of quick steps and you\'re set.';

  @override
  String get registerEmailStepTitle => 'Start with your email';

  @override
  String get registerEmailStepSubtitle =>
      'We\'ll send you a code to verify it\'s really you.';

  @override
  String get registerCodeStepTitle => 'Enter the code';

  @override
  String registerCodeStepSubtitle(Object email) {
    return 'We emailed a 6-digit code to $email.';
  }

  @override
  String get registerCodeHint => 'Check your inbox (and spam, just in case).';

  @override
  String get registerPasswordStepTitle => 'Set your password';

  @override
  String get registerPasswordStepSubtitle =>
      'At least 8 characters. You can change this later.';

  @override
  String get registerEmailExists =>
      'That email already has an account. Log in instead.';

  @override
  String get registerCodeInvalid => 'That code didn\'t work. Please try again.';

  @override
  String get registerCodeExpired => 'That code has expired. Request a new one.';

  @override
  String get registerSuccessTitle => 'You\'re in! 🎉';

  @override
  String get registerSuccessSubtitle =>
      'Your account was created. Let\'s set up your business.';

  @override
  String get registerContinue => 'Continue';

  @override
  String get resendCode => 'Resend code';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get registerHaveAccount => 'Already have an account?';

  @override
  String get reRegisterCta => 'Log in';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotSubtitle =>
      'We\'ll email you a code so you can pick a new password.';

  @override
  String get forgotCodeStepTitle => 'Enter the code';

  @override
  String forgotCodeStepSubtitle(Object email) {
    return 'We emailed a 6-digit code to $email.';
  }

  @override
  String get forgotPasswordStepTitle => 'Choose a new password';

  @override
  String get forgotPasswordStepSubtitle =>
      'At least 8 characters. Avoid reusing old passwords.';

  @override
  String get forgotSendCode => 'Send reset code';

  @override
  String get forgotSubmit => 'Update password';

  @override
  String get forgotBackToLogin => 'Back to log in';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonOrContinueWith => 'or continue with';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonGoogle => 'Google';

  @override
  String get commonApple => 'Apple';

  @override
  String get commonFacebook => 'Facebook';

  @override
  String get commonSocialUnavailable => 'One-tap sign-in is coming soon.';

  @override
  String get homeDashboard => 'Dashboard';

  @override
  String get homeInvoicing => 'Invoicing';

  @override
  String get homeTimeTracking => 'Time';

  @override
  String get homeAccounting => 'Accounting';

  @override
  String get moduleComingSoonTitle => 'On it!';

  @override
  String get moduleComingSoonSubtitle =>
      'This module is next on our roadmap and lands here soon.';

  @override
  String get invoicesCreateTitle => 'New invoice';

  @override
  String get invoicesCreateSubtitle =>
      'Invoice data and line items will be edited here.';

  @override
  String get invoicesDetailTitle => 'Invoice';

  @override
  String get invoicesDetailSubtitle =>
      'A ready invoice document will open here.';

  @override
  String get timeProjectsTitle => 'Projects';

  @override
  String get timeProjectsSubtitle => 'Projects and tasks will appear here.';

  @override
  String get timeTimerTitle => 'Timer';

  @override
  String get timeTimerSubtitle =>
      'A stopwatch-based time recorder will live here.';

  @override
  String get timeEntryCreateTitle => 'Manual entry';

  @override
  String get timeEntryCreateSubtitle =>
      'Tracked time will be added here in seconds.';

  @override
  String get accountingReportTitle => 'Report';

  @override
  String get accountingReportSubtitle =>
      'A simple profit and loss view will appear here.';

  @override
  String get accountingEntryCreateTitle => 'Add entry';

  @override
  String get accountingEntryCreateSubtitle =>
      'Income and expenses will be recorded here.';

  @override
  String get guidesTitle => 'Guides';

  @override
  String get guidesSubtitle =>
      'Checklists and tips for running your business appear here.';

  @override
  String get checklistTitle => 'Checklist';

  @override
  String get checklistSubtitle => 'A step-by-step checklist will appear here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBusinessProfile => 'Business profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsGuides => 'Guides';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get businessProfileTitle => 'Business profile';

  @override
  String get businessProfileSubtitle =>
      'Company name, address and tax rules will be edited here.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageSystemHint => 'Follows the language of your device.';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemHint => 'Follows your device settings.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get aboutTitle => 'About Gewerber';

  @override
  String get aboutSubtitle =>
      'Version, licenses and privacy information arrive here.';
}
