// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Gewerber';

  @override
  String get tagline => 'Business. Einfach geregelt.';

  @override
  String get splashTitle => 'Dein Business, endlich einfach.';

  @override
  String get splashSubtitle =>
      'Rechnungen, Zeiterfassung und Buchhaltung — freundliche Software für Solo-Selbstständige in Deutschland.';

  @override
  String get splashGetStarted => 'Loslegen';

  @override
  String get splashLogIn => 'Ich habe bereits ein Konto';

  @override
  String get splashPrivacy =>
      'Open Source · DSGVO-freundlich · Für Solos gemacht';

  @override
  String get panelTrustCreate => 'Guthaben in unter zwei Minuten erstellen';

  @override
  String get panelTrustInvoices => 'Heute deine erste Rechnung schreiben';

  @override
  String get panelTrustTax => 'Verstehe, welche Steuern für dich gelten';

  @override
  String get panelTrustOpenSource => 'Deine Daten, dein Business — Open Source';

  @override
  String get loginTitle => 'Willkommen zurück';

  @override
  String get loginSubtitle => 'Melde dich an, um dein Business weiterzuführen.';

  @override
  String get emailLabel => 'E-Mail-Adresse';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get passwordShow => 'Passwort anzeigen';

  @override
  String get passwordHide => 'Passwort ausblenden';

  @override
  String get loginCta => 'Anmelden';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginNoAccount => 'Neu bei Gewerber?';

  @override
  String get loginCreateAccount => 'Konto erstellen';

  @override
  String get loginInvalidCredentials =>
      'Die E-Mail-Adresse oder das Passwort ist falsch. Bitte versuche es erneut.';

  @override
  String get loginTooManyAttempts =>
      'Zu viele fehlgeschlagene Versuche. Bitte versuche es in ein paar Minuten erneut.';

  @override
  String get loginDemoCta => 'Demo erkunden';

  @override
  String get loginDemoHint =>
      'Meldet dich ohne echtes Konto an, damit du die App durchstöbern kannst.';

  @override
  String get registerTitle => 'Konto erstellen';

  @override
  String get registerSubtitle =>
      'Ein paar schnelle Schritte und du bist startklar.';

  @override
  String get registerEmailStepTitle => 'Starte mit deiner E-Mail';

  @override
  String get registerEmailStepSubtitle =>
      'Wir senden dir einen Code, um zu prüfen, dass du es wirklich bist.';

  @override
  String get registerCodeStepTitle => 'Gib den Code ein';

  @override
  String registerCodeStepSubtitle(Object email) {
    return 'Wir haben einen 6-stelligen Code an $email geschickt.';
  }

  @override
  String get registerCodeHint =>
      'Schau in dein Postfach (und in den Spam, falls nötig).';

  @override
  String get registerPasswordStepTitle => 'Lege dein Passwort fest';

  @override
  String get registerPasswordStepSubtitle =>
      'Mindestens 8 Zeichen. Du kannst es später ändern.';

  @override
  String get registerEmailExists =>
      'Für diese E-Mail gibt es bereits ein Konto. Melde dich stattdessen an.';

  @override
  String get registerCodeInvalid =>
      'Der Code war nicht richtig. Bitte versuche es erneut.';

  @override
  String get registerCodeExpired =>
      'Der Code ist abgelaufen. Fordere einen neuen an.';

  @override
  String get registerSuccessTitle => 'Du bist drin! 🎉';

  @override
  String get registerSuccessSubtitle =>
      'Dein Konto wurde erstellt. Lass uns dein Business einrichten.';

  @override
  String get registerContinue => 'Weiter';

  @override
  String get resendCode => 'Code erneut senden';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get passwordMismatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get registerHaveAccount => 'Schon ein Konto?';

  @override
  String get reRegisterCta => 'Anmelden';

  @override
  String get forgotTitle => 'Passwort zurücksetzen';

  @override
  String get forgotSubtitle =>
      'Wir senden dir einen Code, mit dem du ein neues Passwort wählen kannst.';

  @override
  String get forgotCodeStepTitle => 'Gib den Code ein';

  @override
  String forgotCodeStepSubtitle(Object email) {
    return 'Wir haben dir einen 6-stelligen Code an $email geschickt.';
  }

  @override
  String get forgotPasswordStepTitle => 'Wähle ein neues Passwort';

  @override
  String get forgotPasswordStepSubtitle =>
      'Mindestens 8 Zeichen. Verwende am besten kein altes Passwort erneut.';

  @override
  String get forgotSendCode => 'Reset-Code senden';

  @override
  String get forgotSubmit => 'Passwort aktualisieren';

  @override
  String get forgotBackToLogin => 'Zurück zur Anmeldung';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonOrContinueWith => 'oder weiter mit';

  @override
  String get commonComingSoon => 'Bald verfügbar';

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get commonGoogle => 'Google';

  @override
  String get commonApple => 'Apple';

  @override
  String get commonFacebook => 'Facebook';

  @override
  String get commonSocialUnavailable =>
      'Anmeldung mit einem Klick ist bald verfügbar.';

  @override
  String get homeDashboard => 'Start';

  @override
  String get homeInvoicing => 'Rechnungen';

  @override
  String get homeTimeTracking => 'Zeit';

  @override
  String get homeAccounting => 'Buchhaltung';

  @override
  String get moduleComingSoonTitle => 'In Arbeit!';

  @override
  String get moduleComingSoonSubtitle =>
      'Dieses Modul steht als Nächstes auf unserer Roadmap und kommt schon bald.';

  @override
  String get invoicesCreateTitle => 'Neue Rechnung';

  @override
  String get invoicesCreateSubtitle =>
      'Rechnungsdaten und Positionen werden hier bearbeitet.';

  @override
  String get invoicesDetailTitle => 'Rechnung';

  @override
  String get invoicesDetailSubtitle =>
      'Ein fertiges Rechnungsdokument wird hier geöffnet.';

  @override
  String get timeProjectsTitle => 'Projekte';

  @override
  String get timeProjectsSubtitle => 'Projekte und Aufgaben erscheinen hier.';

  @override
  String get timeTimerTitle => 'Zeiterfassung';

  @override
  String get timeTimerSubtitle =>
      'Eine Stoppuhr-basierte Erfassung wohnt hier.';

  @override
  String get timeEntryCreateTitle => 'Manuelle Zeiterfassung';

  @override
  String get timeEntryCreateSubtitle =>
      'Erfasste Zeiten werden hier sekundenschnell hinzugefügt.';

  @override
  String get accountingReportTitle => 'Bericht';

  @override
  String get accountingReportSubtitle =>
      'Eine einfache Gewinn- und Verlustübersicht erscheint hier.';

  @override
  String get accountingEntryCreateTitle => 'Buchung hinzufügen';

  @override
  String get accountingEntryCreateSubtitle =>
      'Einnahmen und Ausgaben werden hier erfasst.';

  @override
  String get guidesTitle => 'Ratgeber';

  @override
  String get guidesSubtitle =>
      'Checklisten und Tipps für Ihr Gewerbe erscheinen hier.';

  @override
  String get checklistTitle => 'Checkliste';

  @override
  String get checklistSubtitle =>
      'Eine Schritt-für-Schritt-Checkliste erscheint hier.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsBusinessProfile => 'Firmendaten';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsGuides => 'Ratgeber';

  @override
  String get settingsAbout => 'Über die App';

  @override
  String get settingsSignOut => 'Abmelden';

  @override
  String get businessProfileTitle => 'Firmendaten';

  @override
  String get businessProfileSubtitle =>
      'Name, Anschrift und Steuerregeln werden hier bearbeitet.';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get languageSystemHint => 'Folgt der Sprache deines Geräts.';

  @override
  String get themeTitle => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemHint => 'Folgt den Einstellungen deines Geräts.';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get aboutTitle => 'Über Gewerber';

  @override
  String get aboutSubtitle =>
      'Version, Lizenzen und Hinweise zum Datenschutz folgen hier.';
}
