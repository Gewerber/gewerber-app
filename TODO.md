# TODO — gewerber-app

План по итогам аудита (2026-08). Приоритеты согласованы с `gewerber-backend/TODO.md`.

---

## Этап 0 — Быстрые победы (P1, ~по 1–2 дня) — ✅ реализовано 2026-08-22

- [x] **NavigationRail** для широких экранов в `lib/presentation/shell/home_shell.dart`
      (≥900px rail / extended ≥1400px, узкие → NavigationBar) ✅
- [x] **`intl` для форматирования**: валюты/даты через NumberFormat/DateFormat (de_DE),
      дубль `_formatCents` удалён ✅
- [x] **Reduced VAT rate (0.07)**: SegmentedButton селектор в `invoice_create_screen.dart`;
      при Kleinunternehmer скрыт с пояснением ✅
- [x] **Customer search + UI удаления** (архивирование — hard-delete эндпоинта на бэкенде нет);
      limit/offset проброшены в CustomerCubit и InvoiceCubit → datasource ✅
- [x] **User profile edit screen** (`userProfile.getMyProfile/update`, полный слой entity→cubit→UI,
      встроен в настройки master-detail) ✅
- [x] **CI workflow** `.github/workflows/ci.yml`: gen-l10n → format → analyze → test;
      deploy.yml получил `ci-gate` job + `needs: ci` ✅

## Этап 1 — Закрытие разрывов «бэкенд ↔ UI» (готово на сервере, нет интерфейса)

- [x] **Delete account UI** ✅ 2026-08-22: пункт в настройках (danger zone) → диалог
      необратимого подтверждения → `deleteMyAccount()` → sign-out;
      `AccountDeletedFailure` от профильных запросов → диалог «Аккаунт удалён» с выходом
      (перехват scoped в UserProfileCubit → app-level listener, без глобального
      переписывания обработки ошибок); widget-тест flow
- [x] **Invoice templates**: UI редактора ✅ 2026-08-22 (полный слой domain→data→cubit→UI;
      список + create/edit, роуты `/app/invoicing/templates*`; logoDocumentId проводится,
      upload-logo UI ждёт общего documents-флоу — решение владельца; 12 тестов)
      + **prefill**: дефолтный шаблон лениво подтягивается при создании счёта и передаётся
      как `templateId` ✅ 2026-08-23 + чип «Применяется шаблон „{name}“» на новой форме ✅
- [x] **Recurring invoices**: UI управления ✅ 2026-08-23 (полный слой
      domain→data→cubit→UI поверх `recurringSchedule.*`: список «upcoming-first»
      из раздела invoicing, attach/edit-форма с интервальным селектором,
      end-date/maxOccurrences и клиентскими валидациями (endDate > nextDate,
      maxOccurrences ≥ 1), cancel с подтверждением «существующие счета останутся»;
      ConflictException/NotFoundException → понятные сообщения; live+mock
      репозитории; 12 тестов)
      SDK-эндпоинты: `recurringSchedule.create/get/list/update/cancel` ✅ бэкенд 2026-08-22
      + clear-флаги `clearRecurrenceEndDate`/`clearMaxOccurrences` в update
      (кнопки очистки у заполненных ограничений; пустое поле без флага = «оставить
      как есть») ✅ 2026-08-23
- [x] **Time entries → Invoice**: flow конвертации ✅ 2026-08-23
      (`/app/time/billing`: проект + опциональный период, превью незабилленных
      billable-записей с суммарным временем, «Создать счёт» → переход к счёту;
      SDK-эндпоинт билдит по проекту/периоду — поштучный выбор записей API не
      поддерживает, поэтому список read-only превью)
      + **оценка сумм** ✅ 2026-08-23: € по каждой записи
      (часы × ставка задачи ?? ставка проекта; нет обеих → «—»),
      итоговая строка по выбранным записям + дисклеймер «только оценка»
      SDK-эндпоинт: `timeEntry.createInvoice` ✅ бэкенд 2026-08-22
- [x] **Receipt upload**: file picker → `document.upload` для транзакций ✅ 2026-08-23
      («Приложить квитанцию» в форме создания транзакции; клиентская валидация
      лимита 512 KB; upload kind=receipt при сохранении, полученный documentId →
      `receiptDocumentId`; имя файла + удаление вложения до сохранения)
- [x] **Transaction edit**: экран редактирования транзакций ✅ 2026-08-23
      (`accounting.update`; общая форма create/edit — tap по записи в списке
      открывает `/app/accounting/edit`, поля предзаполнены; квитанция: текущий
      файл через `document.get`, замена = upload нового, снятие = clear-null;
      `document.get` добавлен в repository/datasource/cubit)
- [x] **Payment history view** по счёту ✅ 2026-08-23: секция «Платежи» на экране
      счёта из `payment.status` (дата, сумма, метод, референс; метод добавлен в
      entity+маппер); запись платежей — без изменений
- [x] **Documents**: общий список/загрузка/скачивание ✅ 2026-08-23
      (`document.list/upload/download`; полный слой domain→data→cubit→UI;
      вход из настроек — секция Documents (мастер-деталь + маршрут);
      file_picker ^12.0.0 за сервисным интерфейсом; переиспользуется для
      будущих логотипов шаблонов)

## Этап 2 — Качество

- [ ] E2E-тесты accounting / guidance / timer flows (сейчас только auth+invoicing)
- [ ] Golden-тесты ключевых экранов
- [x] Систематический a11y-проход (Semantics, контраст, focus) ✅ 2026-08-25,
      ветка `feat/a11y-pass`: исправлено — заголовки секций (Semantics header),
      тултипы NavigationBar, merged-узлы «значение+тренд/строка» (дашборд,
      отчёт P&L, платежи, должники), текстовые эквиваленты статусов
      (billable в таймере, danger zone в настройках, прогресс загрузки
      документов), точный тултип «удалить позицию»; 4 новых arb-ключа ×4
      языка; 10 widget-тестов на семантику. Flag-only: контраст брендовых
      цветов (см. Заметки), long-press-only удаления, фокус-обход.
- [ ] Решение по social auth (единственный TODO в репо — stub бросает исключение)

## Этап 3 — Офлайн (совместно с бэкендом, квартал 2)

- [ ] Локальная БД (drift) + sync по курсорам `updatedAt` (эндпоинты — см. backend TODO этап 3)
- [ ] Очередь мутаций офлайн (создание записей времени без сети — критично для выездных работ)

## Бэклог (добавлено 2026-08-25)

- [x] **Выбор языка и цветовой схемы до регистрации** ✅ 2026-08-25:
      переключатели языка (system/en/de/ru/tr) и темы (system/light/dark)
      в общем хедере `presentation/widgets/layout/auth_panel_layout.dart`
      (одна реализация покрывает login/register/forgot-password); действуют на
      глобальный `AppSettingsCubit` — тот же state, что и пост-логин настройки.
      Персистирование: `AppearancePreferencesRepository` поверх
      shared_preferences, кубит сеется синхронно при конструировании
      (bootstrap прогревает SharedPreferences до DI → выбор применяется с
      первого кадра, без вспышки дефолтной темы); все мутации кубита пишутся
      в девайс-стор, `syncFromServer` зеркалит серверные предпочтения,
      sign-out сохраняет девайс-выбор. Строки переиспользованы из arb
      (languageTitle/themeTitle/themeSystem/Light/Dark/languageSystemDefault),
      новых ключей нет — l10n-guard зелёный; одинаково в authMock/authLive.
      15 тестов (unit roundtrip + pre-auth widget + persistence через app shell).
      Ветка `feat/pre-auth-appearance`.

---

## Заметки
- Ветка `implement-new-features` — актуальная рабочая.
- Web-сборка: рассмотреть `--wasm` после стабилизации зависимостей.
- (2026-08-22) Даты в UI теперь локале-зависимые (de → `22.08.2026`); ISO оставлен только в именах файлов экспорта.
- (2026-08-22) CI на fork-PR: секрет `COMMERCIAL_REPO_TOKEN` недоступен — `pub get` приватной зависимости упадёт by design.
- (2026-08-25, a11y-pass, flag-only) Контраст vs белый фон (WCAG AA 4.5:1 текст / 3:1 крупный текст и UI): `GewerberColors.success #3BB273` = 2.69 (тренд-бейджи «+x %»), `accentDark #2DB387` = 2.66 (расходные бары графика), `textMuted #9AA5B1` = 2.50, `warning #F5A623` = 2.03; `error #E54848` = 3.92 (проходит только как крупный/UI) — есть тёмные варианты (`errorDark` 5.23, `successDark`, `primary` 4.86 ✓). Нужен продуктовый редизайн палитры, не трогал.
- (2026-08-25, a11y-pass, flag-only) Удаление транзакций и time-записей доступно только через long-press (`onLongPress`) — нет видимого действия; нужна архитектурная доработка (swipe/dispose menu), не трогал.
- (2026-08-25, a11y-pass, flag-only) Закрывающий IconButton в `auth_error_banner.dart` без tooltip (auth-зона вне скоупа пост-логин прохода); focus traversal порядок не проверялся глубоко — требует отдельного прохода с реальным screen reader.
