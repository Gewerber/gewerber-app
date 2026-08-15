// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Gewerber';

  @override
  String get tagline => 'İşiniz. Artık çok kolay.';

  @override
  String get splashTitle => 'İşiniz, nihayet basit.';

  @override
  String get splashSubtitle =>
      'Faturalar, zaman takibi ve ön muhasebe — Almanya\'daki bireysel girişimciler için samimi bir yazılım.';

  @override
  String get splashGetStarted => 'Başla';

  @override
  String get splashLogIn => 'Zaten hesabım var';

  @override
  String get splashPrivacy =>
      'Açık kaynak · GDPR dostu · Bireysel girişimciler için';

  @override
  String get panelTrustCreate => 'İki dakikadan kısa sürede hesap oluşturun';

  @override
  String get panelTrustInvoices => 'İlk faturanızı bugün gönderin';

  @override
  String get panelTrustTax => 'Sizi ilgilendiren vergileri anlayın';

  @override
  String get panelTrustOpenSource => 'Verileriniz, işiniz — açık kaynak';

  @override
  String get loginTitle => 'Tekrar hoş geldiniz';

  @override
  String get loginSubtitle => 'İşinizi yönetmeye devam etmek için giriş yapın.';

  @override
  String get emailLabel => 'E-posta adresi';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordShow => 'Şifreyi göster';

  @override
  String get passwordHide => 'Şifreyi gizle';

  @override
  String get loginCta => 'Giriş yap';

  @override
  String get loginForgotPassword => 'Şifrenizi mi unuttunuz?';

  @override
  String get loginNoAccount => 'Gewerber\'de yeni misiniz?';

  @override
  String get loginCreateAccount => 'Hesabınızı oluşturun';

  @override
  String get loginInvalidCredentials =>
      'E-posta adresi veya şifre hatalı. Lütfen tekrar deneyin.';

  @override
  String get loginTooManyAttempts =>
      'Çok fazla başarısız deneme. Lütfen birkaç dakika sonra tekrar deneyin.';

  @override
  String get loginDemoCta => 'Demoyu keşfet';

  @override
  String get loginDemoHint =>
      'Gerçek bir hesap olmadan giriş yapar, böylece uygulamayı gezebilirsin.';

  @override
  String get authUserBlocked =>
      'Bu hesap engellendi. Bunun bir hata olduğunu düşünüyorsanız destek ile iletişime geçin.';

  @override
  String get authValidationError => 'Lütfen girdiğiniz bilgileri kontrol edin.';

  @override
  String get authNetworkError =>
      'Sunucuya ulaşamadık. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get authPasswordPolicy => 'Bu şifre gereksinimleri karşılamıyor.';

  @override
  String get registerTitle => 'Hesabınızı oluşturun';

  @override
  String get registerSubtitle => 'Birkaç hızlı adım ve hazırsınız.';

  @override
  String get registerEmailStepTitle => 'E-posta adresinizle başlayın';

  @override
  String get registerEmailStepSubtitle =>
      'Gerçekten siz olduğunuzu doğrulamak için size bir kod göndereceğiz.';

  @override
  String get registerCodeStepTitle => 'Kodu girin';

  @override
  String registerCodeStepSubtitle(Object email) {
    return '$email adresine 6 haneli bir kod gönderdik.';
  }

  @override
  String get registerCodeHint =>
      'Gelen kutunuzu kontrol edin (ve ihtimal olarak spam klasörünü).';

  @override
  String get registerPasswordStepTitle => 'Şifrenizi belirleyin';

  @override
  String get registerPasswordStepSubtitle =>
      'En az 8 karakter. Bunu daha sonra değiştirebilirsiniz.';

  @override
  String get registerEmailExists =>
      'Bu e-posta adresine ait bir hesap zaten var. Bunun yerine giriş yapın.';

  @override
  String get registerCodeInvalid =>
      'Bu kod işe yaramadı. Lütfen tekrar deneyin.';

  @override
  String get registerCodeExpired =>
      'Bu kodun süresi doldu. Yeni bir kod isteyin.';

  @override
  String get registerSuccessTitle => 'Aramızdasınız! 🎉';

  @override
  String get registerSuccessSubtitle =>
      'Hesabınız oluşturuldu. Şimdi işletmenizi kuralım.';

  @override
  String get registerContinue => 'Devam';

  @override
  String get resendCode => 'Kodu tekrar gönder';

  @override
  String get confirmPasswordLabel => 'Şifreyi onayla';

  @override
  String get passwordMismatch => 'Şifreler eşleşmiyor.';

  @override
  String get registerHaveAccount => 'Zaten bir hesabınız var mı?';

  @override
  String get reRegisterCta => 'Giriş yap';

  @override
  String get forgotTitle => 'Şifrenizi sıfırlayın';

  @override
  String get forgotSubtitle =>
      'Yeni bir şifre seçebilmeniz için size e-posta ile bir kod göndereceğiz.';

  @override
  String get forgotCodeStepTitle => 'Kodu girin';

  @override
  String forgotCodeStepSubtitle(Object email) {
    return '$email adresine 6 haneli bir kod gönderdik.';
  }

  @override
  String get forgotPasswordStepTitle => 'Yeni bir şifre seçin';

  @override
  String get forgotPasswordStepSubtitle =>
      'En az 8 karakter. Eski şifreleri tekrar kullanmaktan kaçının.';

  @override
  String get forgotSendCode => 'Sıfırlama kodu gönder';

  @override
  String get forgotSubmit => 'Şifreyi güncelle';

  @override
  String get forgotBackToLogin => 'Girişe dön';

  @override
  String get forgotSuccessTitle => 'Şifre güncellendi';

  @override
  String get forgotSuccessSubtitle =>
      'Artık yeni şifrenizle giriş yapabilirsiniz.';

  @override
  String get commonContinue => 'Devam';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonOrContinueWith => 'veya şununla devam edin';

  @override
  String get commonComingSoon => 'Yakında';

  @override
  String get commonAdd => 'Ekle';

  @override
  String get commonGoogle => 'Google';

  @override
  String get commonApple => 'Apple';

  @override
  String get commonFacebook => 'Facebook';

  @override
  String get commonSocialUnavailable => 'Tek dokunuşla giriş yakında geliyor.';

  @override
  String get betaBannerTitle => 'Açık beta';

  @override
  String get betaBannerText =>
      'Gewerber geliştirme aşamasında – bazı bölümler henüz yer tutucu. Geri bildirim: github.com/Gewerber/gewerber-app';

  @override
  String get homeDashboard => 'Genel Bakış';

  @override
  String get homeInvoicing => 'Faturalama';

  @override
  String get homeTimeTracking => 'Zaman';

  @override
  String get homeAccounting => 'Muhasebe';

  @override
  String get moduleComingSoonTitle => 'Üzerinde çalışıyoruz!';

  @override
  String get moduleComingSoonSubtitle =>
      'Bu modül yol haritamızda sırada ve yakında burada olacak.';

  @override
  String get invoicesCreateTitle => 'Yeni fatura';

  @override
  String get invoicesCreateSubtitle =>
      'Fatura verileri ve kalemleri burada düzenlenecek.';

  @override
  String get invoicesDetailTitle => 'Fatura';

  @override
  String get invoicesDetailSubtitle =>
      'Hazır bir fatura belgesi burada açılacak.';

  @override
  String get timeProjectsTitle => 'Projeler';

  @override
  String get timeProjectsSubtitle => 'Projeler ve görevler burada görünecek.';

  @override
  String get timeTimerTitle => 'Kronometre';

  @override
  String get timeTimerSubtitle =>
      'Kronometre tabanlı bir zaman kaydedici burada olacak.';

  @override
  String get timeEntryCreateTitle => 'Manuel giriş';

  @override
  String get timeEntryCreateSubtitle =>
      'Takip edilen süre buraya saniyeler içinde eklenecek.';

  @override
  String get accountingReportTitle => 'Rapor';

  @override
  String get accountingReportSubtitle =>
      'Basit bir kâr-zarar görünümü burada görünecek.';

  @override
  String get accountingEntryCreateTitle => 'Kayıt ekle';

  @override
  String get accountingEntryCreateSubtitle =>
      'Gelir ve giderler buraya kaydedilecek.';

  @override
  String get guidesTitle => 'Rehberler';

  @override
  String get guidesSubtitle =>
      'İşletmenizi yönetmek için kontrol listeleri ve ipuçları burada görünür.';

  @override
  String get checklistTitle => 'Kontrol listesi';

  @override
  String get checklistSubtitle =>
      'Adım adım bir kontrol listesi burada görünecek.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsBusinessProfile => 'İşletme profili';

  @override
  String get settingsBusinessSettings => 'İşletme ayarları';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsGuides => 'Rehberler';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsSignOut => 'Çıkış yap';

  @override
  String get businessProfileTitle => 'İşletme profili';

  @override
  String get businessProfileSubtitle =>
      'Şirket adı, adres ve vergi kuralları burada düzenlenecek.';

  @override
  String get languageTitle => 'Dil';

  @override
  String get languageSystemDefault => 'Sistem varsayılanı';

  @override
  String get languageSystemHint => 'Cihazınızın dilini kullanır.';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeSystemHint => 'Cihaz ayarlarınızı takip eder.';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get aboutTitle => 'Gewerber hakkında';

  @override
  String get aboutSubtitle =>
      'Sürüm, lisanslar ve gizlilik bilgileri buraya gelecek.';

  @override
  String get onboardingTitle => 'İşletmenizi kurun';

  @override
  String get onboardingSubtitle =>
      'Birkaç bilgi yeterli, ilk faturanızı gönderebilirsiniz.';

  @override
  String get onboardingBusinessName => 'İşletme adı';

  @override
  String get onboardingBusinessNameHint => 'Faturalarınızda görünecek ad.';

  @override
  String get onboardingLegalForm => 'Hukuki yapı';

  @override
  String get onboardingLegalFormEinzelunternehmen =>
      'Şahıs şirketi (Einzelunternehmen)';

  @override
  String get onboardingLegalFormKleingewerbe => 'Küçük işletme (Kleingewerbe)';

  @override
  String get onboardingLegalFormFreiberufler =>
      'Serbest çalışan (Freiberufler)';

  @override
  String get onboardingLegalFormGbr => 'GbR (adi ortaklık)';

  @override
  String get onboardingLegalFormOther => 'Diğer';

  @override
  String get onboardingKleinunternehmer => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get onboardingKleinunternehmerHint =>
      'Ciro limitin altında — faturalarda KDV gösterilmez.';

  @override
  String get onboardingVatId => 'KDV numarası (USt-IdNr.)';

  @override
  String get onboardingVatIdHint => 'KDV uygulamıyorsanız isteğe bağlı.';

  @override
  String get onboardingAddressSection => 'Adres';

  @override
  String get onboardingStreet => 'Cadde/Sokak';

  @override
  String get onboardingZip => 'Posta kodu';

  @override
  String get onboardingCity => 'Şehir';

  @override
  String get onboardingEmail => 'İş e-postası';

  @override
  String get onboardingPhone => 'Telefon';

  @override
  String get onboardingOptional => 'isteğe bağlı';

  @override
  String get onboardingCreate => 'İşletme oluştur';

  @override
  String get onboardingCreating => 'Oluşturuluyor…';

  @override
  String get onboardingError =>
      'İşletmeniz oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String get businessFormName => 'İşletme adı';

  @override
  String get businessFormLegalForm => 'Hukuki yapı';

  @override
  String get businessFormKleinunternehmer => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get businessFormVatId => 'KDV numarası';

  @override
  String get businessFormEmail => 'İş e-postası';

  @override
  String get businessFormPhone => 'Telefon';

  @override
  String get businessFormStreet => 'Cadde/Sokak';

  @override
  String get businessFormZip => 'Posta kodu';

  @override
  String get businessFormCity => 'Şehir';

  @override
  String get businessFormSave => 'Kaydet';

  @override
  String get businessFormSaving => 'Kaydediliyor…';

  @override
  String get businessFormSaved => 'İşletme profili güncellendi.';

  @override
  String get businessFormError =>
      'İşletme kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get businessSettingsTitle => 'İşletme ayarları';

  @override
  String get businessSettingsSubtitle =>
      'Fatura numaralandırma ve ödeme koşulları.';

  @override
  String get businessSettingsPaymentTerms => 'Ödeme koşulları';

  @override
  String get businessSettingsDueDays => 'Vade günü';

  @override
  String get businessSettingsInvoiceNumber => 'Fatura numaralandırma';

  @override
  String get businessSettingsNumberPrefix => 'Numara öneki';

  @override
  String get businessSettingsNumberPrefixHint => 'İsteğe bağlı, örn. \"RE-\".';

  @override
  String get businessSettingsIncludeYear => 'Yılı dahil et';

  @override
  String get businessSettingsMinDigits => 'Minimum hane';

  @override
  String get businessSettingsSave => 'Kaydet';

  @override
  String get businessSettingsSaved => 'Ayarlar güncellendi.';

  @override
  String get businessSettingsError =>
      'Ayarlar kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get customersTitle => 'Müşteriler';

  @override
  String get customersEmpty =>
      'Henüz müşteri yok. Fatura oluşturmak için ilk müşterinizi ekleyin.';

  @override
  String get customersAdd => 'Müşteri ekle';

  @override
  String get customerNewTitle => 'Yeni müşteri';

  @override
  String get customerEditTitle => 'Müşteriyi düzenle';

  @override
  String get customerName => 'Müşteri adı';

  @override
  String get customerCompany => 'Şirket (isteğe bağlı)';

  @override
  String get customerEmail => 'E-posta';

  @override
  String get customerPhone => 'Telefon';

  @override
  String get customerStreet => 'Cadde/Sokak';

  @override
  String get customerZip => 'Posta kodu';

  @override
  String get customerCity => 'Şehir';

  @override
  String get customerVatId => 'KDV numarası';

  @override
  String get customerSave => 'Kaydet';

  @override
  String get customerSaved => 'Müşteri kaydedildi.';

  @override
  String get customerError => 'Müşteri kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get customersArchive => 'Arşivle';

  @override
  String get customersArchived => 'Müşteri arşivlendi.';

  @override
  String get invoicesTitle => 'Faturalar';

  @override
  String get invoicesEmpty => 'Henüz fatura yok. İlk faturanızı oluşturun.';

  @override
  String get invoicesNew => 'Yeni fatura';

  @override
  String get invoiceStatusDraft => 'Taslak';

  @override
  String get invoiceStatusSent => 'Gönderildi';

  @override
  String get invoiceStatusPaid => 'Ödendi';

  @override
  String get invoiceStatusOverdue => 'Vadesi geçti';

  @override
  String get invoiceStatusCancelled => 'İptal edildi';

  @override
  String get invoiceNewTitle => 'Yeni fatura';

  @override
  String get invoiceEditTitle => 'Faturayı düzenle';

  @override
  String get invoiceCustomer => 'Müşteri';

  @override
  String get invoiceNoCustomer => 'Müşteri yok';

  @override
  String get invoiceIssueDate => 'Fatura tarihi';

  @override
  String get invoiceDueDate => 'Son ödeme tarihi';

  @override
  String get invoiceServicePeriod => 'Hizmet dönemi';

  @override
  String get invoiceServiceFrom => 'Başlangıç';

  @override
  String get invoiceServiceTo => 'Bitiş';

  @override
  String get invoiceItems => 'Kalemler';

  @override
  String get invoiceItemDescription => 'Açıklama';

  @override
  String get invoiceItemQuantity => 'Adet';

  @override
  String get invoiceItemUnitPrice => 'Birim fiyat';

  @override
  String get invoiceItemAmount => 'Tutar';

  @override
  String get invoiceAddItem => 'Kalem ekle';

  @override
  String get invoiceSubtotal => 'Ara toplam';

  @override
  String get invoiceVat => 'KDV';

  @override
  String get invoiceTotal => 'Toplam';

  @override
  String get invoiceNotes => 'Notlar';

  @override
  String get invoiceNotesHint => 'Faturanın altında görünür.';

  @override
  String get invoiceSave => 'Kaydet';

  @override
  String get invoiceSaving => 'Kaydediliyor…';

  @override
  String get invoiceSaved => 'Fatura kaydedildi.';

  @override
  String get invoiceError => 'Fatura kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get invoiceDelete => 'Faturayı sil';

  @override
  String get invoiceDeleteConfirm =>
      'Bu fatura silinsin mi? Bu işlem geri alınamaz.';

  @override
  String get invoiceDeleted => 'Fatura silindi.';

  @override
  String get invoiceDeleteDraftOnly => 'Yalnızca taslak faturalar silinebilir.';

  @override
  String get invoiceMissingCustomer => 'Lütfen bir müşteri seçin.';

  @override
  String get invoiceMissingItems =>
      'Lütfen açıklamalı en az bir kalem ekleyin.';

  @override
  String get invoiceNumber => 'Fatura';

  @override
  String get invoiceNumberLabel => 'Numara';

  @override
  String get invoiceNotFound => 'Fatura bulunamadı.';
}
