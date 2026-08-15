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
  String get authUserBlocked =>
      'This account has been blocked. Contact support if you think this is a mistake.';

  @override
  String get authValidationError => 'Please check the details you entered.';

  @override
  String get authNetworkError =>
      'We couldn\'t reach the server. Check your connection and try again.';

  @override
  String get authPasswordPolicy =>
      'This password doesn\'t meet the requirements.';

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
  String get forgotSuccessTitle => 'Password updated';

  @override
  String get forgotSuccessSubtitle =>
      'You can now log in with your new password.';

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
  String get betaBannerTitle => 'Public beta';

  @override
  String get betaBannerText =>
      'Gewerber is under construction – some areas are placeholders. Feedback: github.com/Gewerber/gewerber-app';

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
  String get settingsBusinessSettings => 'Business settings';

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

  @override
  String get onboardingTitle => 'Set up your business';

  @override
  String get onboardingSubtitle =>
      'A few details and you can send your first invoice.';

  @override
  String get onboardingBusinessName => 'Business name';

  @override
  String get onboardingBusinessNameHint => 'The name shown on your invoices.';

  @override
  String get onboardingLegalForm => 'Legal form';

  @override
  String get onboardingLegalFormEinzelunternehmen =>
      'Sole trader (Einzelunternehmen)';

  @override
  String get onboardingLegalFormKleingewerbe => 'Small business (Kleingewerbe)';

  @override
  String get onboardingLegalFormFreiberufler => 'Freelancer (Freiberufler)';

  @override
  String get onboardingLegalFormGbr => 'GbR (civil law partnership)';

  @override
  String get onboardingLegalFormOther => 'Other';

  @override
  String get onboardingKleinunternehmer => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get onboardingKleinunternehmerHint =>
      'Revenue below the limit — no VAT is charged on your invoices.';

  @override
  String get onboardingVatId => 'VAT ID (USt-IdNr.)';

  @override
  String get onboardingVatIdHint => 'Optional unless you charge VAT.';

  @override
  String get onboardingAddressSection => 'Address';

  @override
  String get onboardingStreet => 'Street';

  @override
  String get onboardingZip => 'Postal code';

  @override
  String get onboardingCity => 'City';

  @override
  String get onboardingEmail => 'Business email';

  @override
  String get onboardingPhone => 'Phone';

  @override
  String get onboardingOptional => 'optional';

  @override
  String get onboardingCreate => 'Create business';

  @override
  String get onboardingCreating => 'Creating…';

  @override
  String get onboardingError =>
      'We couldn\'t create your business. Please try again.';

  @override
  String get businessFormName => 'Business name';

  @override
  String get businessFormLegalForm => 'Legal form';

  @override
  String get businessFormKleinunternehmer => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get businessFormVatId => 'VAT ID';

  @override
  String get businessFormEmail => 'Business email';

  @override
  String get businessFormPhone => 'Phone';

  @override
  String get businessFormStreet => 'Street';

  @override
  String get businessFormZip => 'Postal code';

  @override
  String get businessFormCity => 'City';

  @override
  String get businessFormSave => 'Save';

  @override
  String get businessFormSaving => 'Saving…';

  @override
  String get businessFormSaved => 'Business profile updated.';

  @override
  String get businessFormError =>
      'We couldn\'t save your business. Please try again.';

  @override
  String get businessSettingsTitle => 'Business settings';

  @override
  String get businessSettingsSubtitle => 'Invoice numbering and payment terms.';

  @override
  String get businessSettingsPaymentTerms => 'Payment terms';

  @override
  String get businessSettingsDueDays => 'Due days';

  @override
  String get businessSettingsInvoiceNumber => 'Invoice numbering';

  @override
  String get businessSettingsNumberPrefix => 'Number prefix';

  @override
  String get businessSettingsNumberPrefixHint => 'Optional, e.g. \"RE-\".';

  @override
  String get businessSettingsIncludeYear => 'Include year';

  @override
  String get businessSettingsMinDigits => 'Minimum digits';

  @override
  String get businessSettingsSave => 'Save';

  @override
  String get businessSettingsSaved => 'Settings updated.';

  @override
  String get businessSettingsError =>
      'We couldn\'t save the settings. Please try again.';

  @override
  String get customersTitle => 'Customers';

  @override
  String get customersEmpty =>
      'No customers yet. Add your first customer to create invoices.';

  @override
  String get customersAdd => 'Add customer';

  @override
  String get customerNewTitle => 'New customer';

  @override
  String get customerEditTitle => 'Edit customer';

  @override
  String get customerName => 'Customer name';

  @override
  String get customerCompany => 'Company (optional)';

  @override
  String get customerEmail => 'Email';

  @override
  String get customerPhone => 'Phone';

  @override
  String get customerStreet => 'Street';

  @override
  String get customerZip => 'Postal code';

  @override
  String get customerCity => 'City';

  @override
  String get customerVatId => 'VAT ID';

  @override
  String get customerSave => 'Save';

  @override
  String get customerSaved => 'Customer saved.';

  @override
  String get customerError =>
      'We couldn\'t save the customer. Please try again.';

  @override
  String get customersArchive => 'Archive';

  @override
  String get customersArchived => 'Customer archived.';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get invoicesEmpty => 'No invoices yet. Create your first invoice.';

  @override
  String get invoicesNew => 'New invoice';

  @override
  String get invoiceStatusDraft => 'Draft';

  @override
  String get invoiceStatusSent => 'Sent';

  @override
  String get invoiceStatusPaid => 'Paid';

  @override
  String get invoiceStatusOverdue => 'Overdue';

  @override
  String get invoiceStatusCancelled => 'Cancelled';

  @override
  String get invoiceNewTitle => 'New invoice';

  @override
  String get invoiceEditTitle => 'Edit invoice';

  @override
  String get invoiceCustomer => 'Customer';

  @override
  String get invoiceNoCustomer => 'No customer';

  @override
  String get invoiceIssueDate => 'Invoice date';

  @override
  String get invoiceDueDate => 'Due date';

  @override
  String get invoiceServicePeriod => 'Service period';

  @override
  String get invoiceServiceFrom => 'From';

  @override
  String get invoiceServiceTo => 'To';

  @override
  String get invoiceItems => 'Items';

  @override
  String get invoiceItemDescription => 'Description';

  @override
  String get invoiceItemQuantity => 'Qty';

  @override
  String get invoiceItemUnitPrice => 'Unit price';

  @override
  String get invoiceItemAmount => 'Amount';

  @override
  String get invoiceAddItem => 'Add item';

  @override
  String get invoiceSubtotal => 'Subtotal';

  @override
  String get invoiceVat => 'VAT';

  @override
  String get invoiceTotal => 'Total';

  @override
  String get invoiceNotes => 'Notes';

  @override
  String get invoiceNotesHint => 'Shown at the bottom of the invoice.';

  @override
  String get invoiceSave => 'Save';

  @override
  String get invoiceSaving => 'Saving…';

  @override
  String get invoiceSaved => 'Invoice saved.';

  @override
  String get invoiceError => 'We couldn\'t save the invoice. Please try again.';

  @override
  String get invoiceDelete => 'Delete invoice';

  @override
  String get invoiceDeleteConfirm =>
      'Delete this invoice? This cannot be undone.';

  @override
  String get invoiceDeleted => 'Invoice deleted.';

  @override
  String get invoiceDeleteDraftOnly => 'Only draft invoices can be deleted.';

  @override
  String get invoiceMissingCustomer => 'Please pick a customer.';

  @override
  String get invoiceMissingItems =>
      'Please add at least one item with a description.';

  @override
  String get invoiceNumber => 'Invoice';

  @override
  String get invoiceNumberLabel => 'Number';

  @override
  String get invoiceNotFound => 'Invoice not found.';
}
