import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gewerber'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Business. Simplified.'**
  String get tagline;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Your business, finally simple.'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bills, time tracking and bookkeeping — friendly software made for solo entrepreneurs in Germany.'**
  String get splashSubtitle;

  /// No description provided for @splashGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get splashGetStarted;

  /// No description provided for @splashLogIn.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get splashLogIn;

  /// No description provided for @splashPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Open source · GDPR friendly · Built for solos'**
  String get splashPrivacy;

  /// No description provided for @panelTrustCreate.
  ///
  /// In en, this message translates to:
  /// **'Create an account in under two minutes'**
  String get panelTrustCreate;

  /// No description provided for @panelTrustInvoices.
  ///
  /// In en, this message translates to:
  /// **'Send your first invoice today'**
  String get panelTrustInvoices;

  /// No description provided for @panelTrustTax.
  ///
  /// In en, this message translates to:
  /// **'Understand the taxes that apply to you'**
  String get panelTrustTax;

  /// No description provided for @panelTrustOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Your data, your business — open source'**
  String get panelTrustOpenSource;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep running your business.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordShow.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShow;

  /// No description provided for @passwordHide.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHide;

  /// No description provided for @loginCta.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginCta;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'New to Gewerber?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get loginCreateAccount;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email address or password is incorrect. Please try again.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again in a few minutes.'**
  String get loginTooManyAttempts;

  /// No description provided for @loginDemoCta.
  ///
  /// In en, this message translates to:
  /// **'Explore the demo'**
  String get loginDemoCta;

  /// No description provided for @loginDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Signs you in without a real account so you can browse the app.'**
  String get loginDemoHint;

  /// No description provided for @authUserBlocked.
  ///
  /// In en, this message translates to:
  /// **'This account has been blocked. Contact support if you think this is a mistake.'**
  String get authUserBlocked;

  /// No description provided for @authValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please check the details you entered.'**
  String get authValidationError;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the server. Check your connection and try again.'**
  String get authNetworkError;

  /// No description provided for @authPasswordPolicy.
  ///
  /// In en, this message translates to:
  /// **'This password doesn\'t meet the requirements.'**
  String get authPasswordPolicy;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A couple of quick steps and you\'re set.'**
  String get registerSubtitle;

  /// No description provided for @registerEmailStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with your email'**
  String get registerEmailStepTitle;

  /// No description provided for @registerEmailStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a code to verify it\'s really you.'**
  String get registerEmailStepSubtitle;

  /// No description provided for @registerCodeStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get registerCodeStepTitle;

  /// No description provided for @registerCodeStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We emailed a 6-digit code to {email}.'**
  String registerCodeStepSubtitle(Object email);

  /// No description provided for @registerCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox (and spam, just in case).'**
  String get registerCodeHint;

  /// No description provided for @registerPasswordStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your password'**
  String get registerPasswordStepTitle;

  /// No description provided for @registerPasswordStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters. You can change this later.'**
  String get registerPasswordStepSubtitle;

  /// No description provided for @registerEmailExists.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account. Log in instead.'**
  String get registerEmailExists;

  /// No description provided for @registerCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t work. Please try again.'**
  String get registerCodeInvalid;

  /// No description provided for @registerCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'That code has expired. Request a new one.'**
  String get registerCodeExpired;

  /// No description provided for @registerSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in! 🎉'**
  String get registerSuccessTitle;

  /// No description provided for @registerSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account was created. Let\'s set up your business.'**
  String get registerSuccessSubtitle;

  /// No description provided for @registerContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registerContinue;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHaveAccount;

  /// No description provided for @reRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get reRegisterCta;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a code so you can pick a new password.'**
  String get forgotSubtitle;

  /// No description provided for @forgotCodeStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get forgotCodeStepTitle;

  /// No description provided for @forgotCodeStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We emailed a 6-digit code to {email}.'**
  String forgotCodeStepSubtitle(Object email);

  /// No description provided for @forgotPasswordStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get forgotPasswordStepTitle;

  /// No description provided for @forgotPasswordStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters. Avoid reusing old passwords.'**
  String get forgotPasswordStepSubtitle;

  /// No description provided for @forgotSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get forgotSendCode;

  /// No description provided for @forgotSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get forgotSubmit;

  /// No description provided for @forgotBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get forgotBackToLogin;

  /// No description provided for @forgotSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get forgotSuccessTitle;

  /// No description provided for @forgotSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can now log in with your new password.'**
  String get forgotSuccessSubtitle;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get commonOrContinueWith;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get commonGoogle;

  /// No description provided for @commonApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get commonApple;

  /// No description provided for @commonFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get commonFacebook;

  /// No description provided for @commonSocialUnavailable.
  ///
  /// In en, this message translates to:
  /// **'One-tap sign-in is coming soon.'**
  String get commonSocialUnavailable;

  /// No description provided for @betaBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Public beta'**
  String get betaBannerTitle;

  /// No description provided for @betaBannerText.
  ///
  /// In en, this message translates to:
  /// **'Gewerber is under construction – some areas are placeholders. Feedback: github.com/Gewerber/gewerber-app'**
  String get betaBannerText;

  /// No description provided for @homeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeDashboard;

  /// No description provided for @homeInvoicing.
  ///
  /// In en, this message translates to:
  /// **'Invoicing'**
  String get homeInvoicing;

  /// No description provided for @homeTimeTracking.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get homeTimeTracking;

  /// No description provided for @homeAccounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get homeAccounting;

  /// No description provided for @moduleComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'On it!'**
  String get moduleComingSoonTitle;

  /// No description provided for @moduleComingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This module is next on our roadmap and lands here soon.'**
  String get moduleComingSoonSubtitle;

  /// No description provided for @invoicesCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get invoicesCreateTitle;

  /// No description provided for @invoicesCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice data and line items will be edited here.'**
  String get invoicesCreateSubtitle;

  /// No description provided for @invoicesDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoicesDetailTitle;

  /// No description provided for @invoicesDetailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A ready invoice document will open here.'**
  String get invoicesDetailSubtitle;

  /// No description provided for @timeProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get timeProjectsTitle;

  /// No description provided for @timeProjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Projects and tasks will appear here.'**
  String get timeProjectsSubtitle;

  /// No description provided for @timeTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timeTimerTitle;

  /// No description provided for @timeTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A stopwatch-based time recorder will live here.'**
  String get timeTimerSubtitle;

  /// No description provided for @timeEntryCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get timeEntryCreateTitle;

  /// No description provided for @timeEntryCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tracked time will be added here in seconds.'**
  String get timeEntryCreateSubtitle;

  /// No description provided for @accountingReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get accountingReportTitle;

  /// No description provided for @accountingReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A simple profit and loss view will appear here.'**
  String get accountingReportSubtitle;

  /// No description provided for @accountingEntryCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get accountingEntryCreateTitle;

  /// No description provided for @accountingEntryCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Income and expenses will be recorded here.'**
  String get accountingEntryCreateSubtitle;

  /// No description provided for @guidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get guidesTitle;

  /// No description provided for @guidesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checklists and tips for running your business appear here.'**
  String get guidesSubtitle;

  /// No description provided for @checklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklistTitle;

  /// No description provided for @checklistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A step-by-step checklist will appear here.'**
  String get checklistSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get settingsBusinessProfile;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsGuides.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get settingsGuides;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @businessProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get businessProfileTitle;

  /// No description provided for @businessProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Company name, address and tax rules will be edited here.'**
  String get businessProfileSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Follows the language of your device.'**
  String get languageSystemHint;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Follows your device settings.'**
  String get themeSystemHint;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Gewerber'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, licenses and privacy information arrive here.'**
  String get aboutSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
