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
}
