// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Gewerber';

  @override
  String get tagline => 'Бизнес. Просто.';

  @override
  String get splashTitle => 'Твой бизнес, наконец, просто.';

  @override
  String get splashSubtitle =>
      'Счета, учёт времени и бухгалтерия — дружелюбное ПО для индивидуальных предпринимателей в Германии.';

  @override
  String get splashGetStarted => 'Начать';

  @override
  String get splashLogIn => 'У меня уже есть аккаунт';

  @override
  String get splashPrivacy =>
      'Open Source · GDPR · Сделано для солопредпринимателей';

  @override
  String get panelTrustCreate => 'Создай аккаунт меньше чем за две минуты';

  @override
  String get panelTrustInvoices => 'Выставь первый счёт уже сегодня';

  @override
  String get panelTrustTax => 'Разберись, какие налоги тебя касаются';

  @override
  String get panelTrustOpenSource => 'Твои данные, твой бизнес — open source';

  @override
  String get loginTitle => 'С возвращением';

  @override
  String get loginSubtitle => 'Войди, чтобы управлять своим бизнесом дальше.';

  @override
  String get emailLabel => 'Адрес эл. почты';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordShow => 'Показать пароль';

  @override
  String get passwordHide => 'Скрыть пароль';

  @override
  String get loginCta => 'Войти';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginNoAccount => 'Впервые в Gewerber?';

  @override
  String get loginCreateAccount => 'Создать аккаунт';

  @override
  String get loginInvalidCredentials =>
      'Адрес или пароль неверны. Попробуй ещё раз.';

  @override
  String get loginTooManyAttempts =>
      'Слишком много неудачных попыток. Попробуй через несколько минут.';

  @override
  String get loginDemoCta => 'Открыть демо';

  @override
  String get loginDemoHint =>
      'Вход без реального аккаунта, чтобы посмотреть все экраны приложения.';

  @override
  String get registerTitle => 'Создать аккаунт';

  @override
  String get registerSubtitle => 'Пара быстрых шагов — и всё готово.';

  @override
  String get registerEmailStepTitle => 'Начни с адреса почты';

  @override
  String get registerEmailStepSubtitle =>
      'Мы отправим тебе код, чтобы убедиться, что это ты.';

  @override
  String get registerCodeStepTitle => 'Введи код';

  @override
  String registerCodeStepSubtitle(Object email) {
    return 'Мы отправили 6-значный код на $email.';
  }

  @override
  String get registerCodeHint => 'Проверь входящие (и спам, на всякий случай).';

  @override
  String get registerPasswordStepTitle => 'Придумай пароль';

  @override
  String get registerPasswordStepSubtitle =>
      'Минимум 8 символов. Его можно изменить позже.';

  @override
  String get registerEmailExists =>
      'На эту почту уже зарегистрирован аккаунт. Войди вместо этого.';

  @override
  String get registerCodeInvalid => 'Код не подошёл. Попробуй ещё раз.';

  @override
  String get registerCodeExpired => 'Код истёк. Запроси новый.';

  @override
  String get registerSuccessTitle => 'Ты внутри! 🎉';

  @override
  String get registerSuccessSubtitle =>
      'Аккаунт создан. Давай настроим твой бизнес.';

  @override
  String get registerContinue => 'Продолжить';

  @override
  String get resendCode => 'Отправить код ещё раз';

  @override
  String get confirmPasswordLabel => 'Подтверди пароль';

  @override
  String get passwordMismatch => 'Пароли не совпадают.';

  @override
  String get registerHaveAccount => 'Уже есть аккаунт?';

  @override
  String get reRegisterCta => 'Войти';

  @override
  String get forgotTitle => 'Сброс пароля';

  @override
  String get forgotSubtitle =>
      'Мы отправим тебе код, чтобы ты мог выбрать новый пароль.';

  @override
  String get forgotCodeStepTitle => 'Введи код';

  @override
  String forgotCodeStepSubtitle(Object email) {
    return 'Мы отправили 6-значный код на $email.';
  }

  @override
  String get forgotPasswordStepTitle => 'Выбери новый пароль';

  @override
  String get forgotPasswordStepSubtitle =>
      'Минимум 8 символов. Не используй повторно старые пароли.';

  @override
  String get forgotSendCode => 'Отправить код сброса';

  @override
  String get forgotSubmit => 'Обновить пароль';

  @override
  String get forgotBackToLogin => 'Вернуться ко входу';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonOrContinueWith => 'или войти через';

  @override
  String get commonComingSoon => 'Скоро';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonGoogle => 'Google';

  @override
  String get commonApple => 'Apple';

  @override
  String get commonFacebook => 'Facebook';

  @override
  String get commonSocialUnavailable => 'Вход в один клик скоро появится.';

  @override
  String get homeDashboard => 'Обзор';

  @override
  String get homeInvoicing => 'Счета';

  @override
  String get homeTimeTracking => 'Время';

  @override
  String get homeAccounting => 'Учёт';

  @override
  String get moduleComingSoonTitle => 'Уже в работе!';

  @override
  String get moduleComingSoonSubtitle =>
      'Этот модуль следующий в нашем плане и появится здесь совсем скоро.';

  @override
  String get invoicesCreateTitle => 'Новый счёт';

  @override
  String get invoicesCreateSubtitle =>
      'Здесь будут редактироваться реквизиты и позиции счёта.';

  @override
  String get invoicesDetailTitle => 'Счёт';

  @override
  String get invoicesDetailSubtitle =>
      'Здесь откроется готовый документ счёта.';

  @override
  String get timeProjectsTitle => 'Проекты';

  @override
  String get timeProjectsSubtitle => 'Здесь появятся проекты и задачи.';

  @override
  String get timeTimerTitle => 'Таймер';

  @override
  String get timeTimerSubtitle => 'Здесь будет встроен таймер учёта времени.';

  @override
  String get timeEntryCreateTitle => 'Ручная запись';

  @override
  String get timeEntryCreateSubtitle =>
      'Здесь будут добавляться записи времени.';

  @override
  String get accountingReportTitle => 'Отчёт';

  @override
  String get accountingReportSubtitle =>
      'Здесь появится простой отчёт о прибылях и убытках.';

  @override
  String get accountingEntryCreateTitle => 'Добавить запись';

  @override
  String get accountingEntryCreateSubtitle =>
      'Здесь будут учитываться доходы и расходы.';

  @override
  String get guidesTitle => 'Гиды';

  @override
  String get guidesSubtitle =>
      'Здесь появятся чек-листы и советы для вашего дела.';

  @override
  String get checklistTitle => 'Чек-лист';

  @override
  String get checklistSubtitle => 'Здесь появится пошаговый чек-лист.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsBusinessProfile => 'Профиль бизнеса';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsGuides => 'Гиды';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get businessProfileTitle => 'Профиль бизнеса';

  @override
  String get businessProfileSubtitle =>
      'Название компании, адрес и налоговые правила будут редактироваться здесь.';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get languageSystemHint => 'Следует языку устройства.';

  @override
  String get themeTitle => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeSystemHint => 'Следует настройкам устройства.';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get aboutTitle => 'О Gewerber';

  @override
  String get aboutSubtitle =>
      'Здесь появятся версия, лицензии и данные о конфиденциальности.';
}
