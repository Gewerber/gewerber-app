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
  String get authUserBlocked =>
      'Dieses Konto wurde gesperrt. Kontaktiere den Support, wenn das ein Fehler ist.';

  @override
  String get authValidationError => 'Bitte überprüfe die eingegebenen Angaben.';

  @override
  String get authNetworkError =>
      'Wir konnten den Server nicht erreichen. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get authPasswordPolicy =>
      'Dieses Passwort erfüllt die Anforderungen nicht.';

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
  String get forgotSuccessTitle => 'Passwort aktualisiert';

  @override
  String get forgotSuccessSubtitle =>
      'Du kannst dich jetzt mit deinem neuen Passwort anmelden.';

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
  String get betaBannerTitle => 'Öffentliche Beta';

  @override
  String get betaBannerText =>
      'Gewerber ist im Aufbau – einige Bereiche sind noch Platzhalter. Feedback: github.com/Gewerber/gewerber-app';

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
  String get settingsBusinessSettings => 'Firmeneinstellungen';

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

  @override
  String get onboardingTitle => 'Dein Business einrichten';

  @override
  String get onboardingSubtitle =>
      'Ein paar Angaben und du kannst deine erste Rechnung schreiben.';

  @override
  String get onboardingBusinessName => 'Firmenname';

  @override
  String get onboardingBusinessNameHint =>
      'Der Name, der auf deinen Rechnungen erscheint.';

  @override
  String get onboardingLegalForm => 'Rechtsform';

  @override
  String get onboardingLegalFormEinzelunternehmen => 'Einzelunternehmen';

  @override
  String get onboardingLegalFormKleingewerbe => 'Kleingewerbe';

  @override
  String get onboardingLegalFormFreiberufler => 'Freiberufler';

  @override
  String get onboardingLegalFormGbr => 'GbR';

  @override
  String get onboardingLegalFormOther => 'Sonstige';

  @override
  String get onboardingKleinunternehmer => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get onboardingKleinunternehmerHint =>
      'Umsatz unter der Grenze — auf deinen Rechnungen wird keine USt. ausgewiesen.';

  @override
  String get onboardingVatId => 'USt-IdNr.';

  @override
  String get onboardingVatIdHint =>
      'Optional, sofern du keine Umsatzsteuer ausweist.';

  @override
  String get onboardingAddressSection => 'Anschrift';

  @override
  String get onboardingStreet => 'Straße';

  @override
  String get onboardingZip => 'PLZ';

  @override
  String get onboardingCity => 'Ort';

  @override
  String get onboardingEmail => 'Geschäftliche E-Mail';

  @override
  String get onboardingPhone => 'Telefon';

  @override
  String get onboardingOptional => 'optional';

  @override
  String get onboardingCreate => 'Business erstellen';

  @override
  String get onboardingCreating => 'Wird erstellt…';

  @override
  String get onboardingError =>
      'Wir konnten dein Business nicht erstellen. Bitte versuche es erneut.';

  @override
  String get businessFormName => 'Firmenname';

  @override
  String get businessFormLegalForm => 'Rechtsform';

  @override
  String get businessFormKleinunternehmer => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get businessFormVatId => 'USt-IdNr.';

  @override
  String get businessFormEmail => 'Geschäftliche E-Mail';

  @override
  String get businessFormPhone => 'Telefon';

  @override
  String get businessFormStreet => 'Straße';

  @override
  String get businessFormZip => 'PLZ';

  @override
  String get businessFormCity => 'Ort';

  @override
  String get businessFormSave => 'Speichern';

  @override
  String get businessFormSaving => 'Wird gespeichert…';

  @override
  String get businessFormSaved => 'Firmendaten aktualisiert.';

  @override
  String get businessFormError =>
      'Wir konnten dein Business nicht speichern. Bitte versuche es erneut.';

  @override
  String get businessSettingsTitle => 'Firmeneinstellungen';

  @override
  String get businessSettingsSubtitle =>
      'Rechnungsnummerierung und Zahlungsbedingungen.';

  @override
  String get businessSettingsPaymentTerms => 'Zahlungsbedingungen';

  @override
  String get businessSettingsDueDays => 'Fälligkeit in Tagen';

  @override
  String get businessSettingsInvoiceNumber => 'Rechnungsnummerierung';

  @override
  String get businessSettingsNumberPrefix => 'Nummernpräfix';

  @override
  String get businessSettingsNumberPrefixHint => 'Optional, z. B. \"RE-\".';

  @override
  String get businessSettingsIncludeYear => 'Jahr einbeziehen';

  @override
  String get businessSettingsMinDigits => 'Mindeststellen';

  @override
  String get businessSettingsSave => 'Speichern';

  @override
  String get businessSettingsSaved => 'Einstellungen aktualisiert.';

  @override
  String get businessSettingsError =>
      'Wir konnten die Einstellungen nicht speichern. Bitte versuche es erneut.';

  @override
  String get customersTitle => 'Kunden';

  @override
  String get customersEmpty =>
      'Noch keine Kunden. Lege deinen ersten Kunden an, um Rechnungen zu erstellen.';

  @override
  String get customersAdd => 'Kunde hinzufügen';

  @override
  String get customerNewTitle => 'Neuer Kunde';

  @override
  String get customerEditTitle => 'Kunde bearbeiten';

  @override
  String get customerName => 'Kundenname';

  @override
  String get customerCompany => 'Firma (optional)';

  @override
  String get customerEmail => 'E-Mail';

  @override
  String get customerPhone => 'Telefon';

  @override
  String get customerStreet => 'Straße';

  @override
  String get customerZip => 'PLZ';

  @override
  String get customerCity => 'Ort';

  @override
  String get customerVatId => 'USt-IdNr.';

  @override
  String get customerSave => 'Speichern';

  @override
  String get customerSaved => 'Kunde gespeichert.';

  @override
  String get customerError =>
      'Wir konnten den Kunden nicht speichern. Bitte versuche es erneut.';

  @override
  String get customersArchive => 'Archivieren';

  @override
  String get customersArchived => 'Kunde archiviert.';

  @override
  String get invoicesTitle => 'Rechnungen';

  @override
  String get invoicesEmpty =>
      'Noch keine Rechnungen. Erstelle deine erste Rechnung.';

  @override
  String get invoicesNew => 'Neue Rechnung';

  @override
  String get invoiceStatusDraft => 'Entwurf';

  @override
  String get invoiceStatusSent => 'Gesendet';

  @override
  String get invoiceStatusPaid => 'Bezahlt';

  @override
  String get invoiceStatusOverdue => 'Überfällig';

  @override
  String get invoiceStatusCancelled => 'Storniert';

  @override
  String get invoiceNewTitle => 'Neue Rechnung';

  @override
  String get invoiceEditTitle => 'Rechnung bearbeiten';

  @override
  String get invoiceCustomer => 'Kunde';

  @override
  String get invoiceNoCustomer => 'Kein Kunde';

  @override
  String get invoiceIssueDate => 'Rechnungsdatum';

  @override
  String get invoiceDueDate => 'Fälligkeitsdatum';

  @override
  String get invoiceServicePeriod => 'Leistungszeitraum';

  @override
  String get invoiceServiceFrom => 'Von';

  @override
  String get invoiceServiceTo => 'Bis';

  @override
  String get invoiceItems => 'Positionen';

  @override
  String get invoiceItemDescription => 'Beschreibung';

  @override
  String get invoiceItemQuantity => 'Menge';

  @override
  String get invoiceItemUnitPrice => 'Einzelpreis';

  @override
  String get invoiceItemAmount => 'Betrag';

  @override
  String get invoiceAddItem => 'Position hinzufügen';

  @override
  String get invoiceSubtotal => 'Zwischensumme';

  @override
  String get invoiceVat => 'USt.';

  @override
  String get invoiceTotal => 'Gesamt';

  @override
  String get invoiceNotes => 'Anmerkungen';

  @override
  String get invoiceNotesHint => 'Erscheint am Ende der Rechnung.';

  @override
  String get invoiceSave => 'Speichern';

  @override
  String get invoiceSaving => 'Wird gespeichert…';

  @override
  String get invoiceSaved => 'Rechnung gespeichert.';

  @override
  String get invoiceError =>
      'Wir konnten die Rechnung nicht speichern. Bitte versuche es erneut.';

  @override
  String get invoiceDelete => 'Rechnung löschen';

  @override
  String get invoiceDeleteConfirm =>
      'Diese Rechnung löschen? Das kann nicht rückgängig gemacht werden.';

  @override
  String get invoiceDeleted => 'Rechnung gelöscht.';

  @override
  String get invoiceDeleteDraftOnly => 'Nur Entwürfe können gelöscht werden.';

  @override
  String get invoiceMissingCustomer => 'Bitte wähle einen Kunden.';

  @override
  String get invoiceMissingItems =>
      'Bitte füge mindestens eine Position mit Beschreibung hinzu.';

  @override
  String get invoiceNumber => 'Rechnung';

  @override
  String get invoiceNumberLabel => 'Nummer';

  @override
  String get invoiceNotFound => 'Rechnung nicht gefunden.';
}
