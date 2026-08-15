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
  String get authUserBlocked =>
      'Этот аккаунт заблокирован. Обратись в поддержку, если это ошибка.';

  @override
  String get authValidationError => 'Пожалуйста, проверь введённые данные.';

  @override
  String get authNetworkError =>
      'Не удалось связаться с сервером. Проверь подключение и попробуй ещё раз.';

  @override
  String get authPasswordPolicy => 'Этот пароль не соответствует требованиям.';

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
  String get forgotSuccessTitle => 'Пароль обновлён';

  @override
  String get forgotSuccessSubtitle => 'Теперь ты можешь войти с новым паролем.';

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
  String get betaBannerTitle => 'Открытая бета';

  @override
  String get betaBannerText =>
      'Gewerber в разработке — некоторые разделы пока заглушки. Обратная связь: github.com/Gewerber/gewerber-app';

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
  String get settingsBusinessSettings => 'Настройки бизнеса';

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

  @override
  String get onboardingTitle => 'Настройте свой бизнес';

  @override
  String get onboardingSubtitle =>
      'Несколько данных — и можно выставить первый счёт.';

  @override
  String get onboardingBusinessName => 'Название компании';

  @override
  String get onboardingBusinessNameHint =>
      'Название, которое будет на ваших счетах.';

  @override
  String get onboardingLegalForm => 'Организационно-правовая форма';

  @override
  String get onboardingLegalFormEinzelunternehmen =>
      'Индивидуальный предприниматель (Einzelunternehmen)';

  @override
  String get onboardingLegalFormKleingewerbe => 'Малый бизнес (Kleingewerbe)';

  @override
  String get onboardingLegalFormFreiberufler => 'Фрилансер (Freiberufler)';

  @override
  String get onboardingLegalFormGbr => 'GbR (товарищество)';

  @override
  String get onboardingLegalFormOther => 'Другое';

  @override
  String get onboardingKleinunternehmer => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get onboardingKleinunternehmerHint =>
      'Оборот ниже лимита — НДС в счетах не указывается.';

  @override
  String get onboardingVatId => 'НДС-номер (USt-IdNr.)';

  @override
  String get onboardingVatIdHint => 'Необязательно, если вы не платите НДС.';

  @override
  String get onboardingAddressSection => 'Адрес';

  @override
  String get onboardingStreet => 'Улица';

  @override
  String get onboardingZip => 'Почтовый индекс';

  @override
  String get onboardingCity => 'Город';

  @override
  String get onboardingEmail => 'Рабочая почта';

  @override
  String get onboardingPhone => 'Телефон';

  @override
  String get onboardingOptional => 'необязательно';

  @override
  String get onboardingCreate => 'Создать бизнес';

  @override
  String get onboardingCreating => 'Создание…';

  @override
  String get onboardingError =>
      'Не удалось создать бизнес. Попробуйте ещё раз.';

  @override
  String get businessFormName => 'Название компании';

  @override
  String get businessFormLegalForm => 'Организационно-правовая форма';

  @override
  String get businessFormKleinunternehmer => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get businessFormVatId => 'НДС-номер';

  @override
  String get businessFormEmail => 'Рабочая почта';

  @override
  String get businessFormPhone => 'Телефон';

  @override
  String get businessFormStreet => 'Улица';

  @override
  String get businessFormZip => 'Почтовый индекс';

  @override
  String get businessFormCity => 'Город';

  @override
  String get businessFormSave => 'Сохранить';

  @override
  String get businessFormSaving => 'Сохранение…';

  @override
  String get businessFormSaved => 'Профиль бизнеса обновлён.';

  @override
  String get businessFormError =>
      'Не удалось сохранить бизнес. Попробуйте ещё раз.';

  @override
  String get businessSettingsTitle => 'Настройки бизнеса';

  @override
  String get businessSettingsSubtitle => 'Нумерация счетов и условия оплаты.';

  @override
  String get businessSettingsPaymentTerms => 'Условия оплаты';

  @override
  String get businessSettingsDueDays => 'Срок оплаты, дней';

  @override
  String get businessSettingsInvoiceNumber => 'Нумерация счетов';

  @override
  String get businessSettingsNumberPrefix => 'Префикс номера';

  @override
  String get businessSettingsNumberPrefixHint =>
      'Необязательно, например «RE-».';

  @override
  String get businessSettingsIncludeYear => 'Включать год';

  @override
  String get businessSettingsMinDigits => 'Мин. число цифр';

  @override
  String get businessSettingsSave => 'Сохранить';

  @override
  String get businessSettingsSaved => 'Настройки обновлены.';

  @override
  String get businessSettingsError =>
      'Не удалось сохранить настройки. Попробуйте ещё раз.';

  @override
  String get customersTitle => 'Клиенты';

  @override
  String get customersEmpty =>
      'Пока нет клиентов. Добавьте первого клиента, чтобы выставлять счета.';

  @override
  String get customersAdd => 'Добавить клиента';

  @override
  String get customerNewTitle => 'Новый клиент';

  @override
  String get customerEditTitle => 'Изменить клиента';

  @override
  String get customerName => 'Имя клиента';

  @override
  String get customerCompany => 'Компания (необязательно)';

  @override
  String get customerEmail => 'Эл. почта';

  @override
  String get customerPhone => 'Телефон';

  @override
  String get customerStreet => 'Улица';

  @override
  String get customerZip => 'Почтовый индекс';

  @override
  String get customerCity => 'Город';

  @override
  String get customerVatId => 'НДС-номер';

  @override
  String get customerSave => 'Сохранить';

  @override
  String get customerSaved => 'Клиент сохранён.';

  @override
  String get customerError =>
      'Не удалось сохранить клиента. Попробуйте ещё раз.';

  @override
  String get customersArchive => 'В архив';

  @override
  String get customersArchived => 'Клиент перемещён в архив.';

  @override
  String get invoicesTitle => 'Счета';

  @override
  String get invoicesEmpty => 'Счетов пока нет. Создайте первый счёт.';

  @override
  String get invoicesNew => 'Новый счёт';

  @override
  String get invoiceStatusDraft => 'Черновик';

  @override
  String get invoiceStatusSent => 'Отправлен';

  @override
  String get invoiceStatusPaid => 'Оплачен';

  @override
  String get invoiceStatusOverdue => 'Просрочен';

  @override
  String get invoiceStatusCancelled => 'Отменён';

  @override
  String get invoiceNewTitle => 'Новый счёт';

  @override
  String get invoiceEditTitle => 'Изменить счёт';

  @override
  String get invoiceCustomer => 'Клиент';

  @override
  String get invoiceNoCustomer => 'Нет клиента';

  @override
  String get invoiceIssueDate => 'Дата счёта';

  @override
  String get invoiceDueDate => 'Срок оплаты';

  @override
  String get invoiceServicePeriod => 'Период оказания услуг';

  @override
  String get invoiceServiceFrom => 'С';

  @override
  String get invoiceServiceTo => 'По';

  @override
  String get invoiceItems => 'Позиции';

  @override
  String get invoiceItemDescription => 'Описание';

  @override
  String get invoiceItemQuantity => 'Кол-во';

  @override
  String get invoiceItemUnitPrice => 'Цена за ед.';

  @override
  String get invoiceItemAmount => 'Сумма';

  @override
  String get invoiceAddItem => 'Добавить позицию';

  @override
  String get invoiceSubtotal => 'Промежуточный итог';

  @override
  String get invoiceVat => 'НДС';

  @override
  String get invoiceTotal => 'Итого';

  @override
  String get invoiceNotes => 'Примечания';

  @override
  String get invoiceNotesHint => 'Появляются внизу счёта.';

  @override
  String get invoiceSave => 'Сохранить';

  @override
  String get invoiceSaving => 'Сохранение…';

  @override
  String get invoiceSaved => 'Счёт сохранён.';

  @override
  String get invoiceError => 'Не удалось сохранить счёт. Попробуйте ещё раз.';

  @override
  String get invoiceDelete => 'Удалить счёт';

  @override
  String get invoiceDeleteConfirm =>
      'Удалить этот счёт? Это действие необратимо.';

  @override
  String get invoiceDeleted => 'Счёт удалён.';

  @override
  String get invoiceDeleteDraftOnly => 'Удалять можно только черновики.';

  @override
  String get invoiceMissingCustomer => 'Выберите клиента.';

  @override
  String get invoiceMissingItems =>
      'Добавьте хотя бы одну позицию с описанием.';

  @override
  String get invoiceNumber => 'Счёт';

  @override
  String get invoiceNumberLabel => 'Номер';

  @override
  String get invoiceNotFound => 'Счёт не найден.';
}
