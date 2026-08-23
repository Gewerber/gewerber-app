# TODO — gewerber-app

План по итогам аудита (2026-08). Приоритеты согласованы с `gewerber-backend-core/TODO.md`.

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
      как `templateId` ✅ 2026-08-23
- [x] **Recurring invoices**: UI управления ✅ 2026-08-23 (полный слой
      domain→data→cubit→UI поверх `recurringSchedule.*`: список «upcoming-first»
      из раздела invoicing, attach/edit-форма с интервальным селектором,
      end-date/maxOccurrences и клиентскими валидациями (endDate > nextDate,
      maxOccurrences ≥ 1), cancel с подтверждением «существующие счета останутся»;
      ConflictException/NotFoundException → понятные сообщения; live+mock
      репозитории; 12 тестов)
      SDK-эндпоинты: `recurringSchedule.create/get/list/update/cancel` ✅ бэкенд 2026-08-22
- [ ] **Time entries → Invoice**: flow конвертации через `timeEntry.createInvoice`
      (`billable`-флаги есть, flow не построен)
- [ ] **Receipt upload**: file picker → `document.upload` для транзакций
      (сейчас только passthrough `receiptDocumentId`)
- [ ] **Payment history view** по счёту (запись платежей есть, истории нет)
- [ ] **Documents**: общий список/загрузка документов (используется только download PDF)

## Этап 2 — Качество

- [ ] E2E-тесты accounting / guidance / timer flows (сейчас только auth+invoicing)
- [ ] Golden-тесты ключевых экранов
- [ ] Систематический a11y-проход (Semantics, контраст, focus)
- [ ] Решение по social auth (единственный TODO в репо — stub бросает исключение)

## Этап 3 — Офлайн (совместно с бэкендом, квартал 2)

- [ ] Локальная БД (drift) + sync по курсорам `updatedAt` (эндпоинты — см. backend TODO этап 3)
- [ ] Очередь мутаций офлайн (создание записей времени без сети — критично для выездных работ)

---

## Заметки
- Ветка `implement-new-features` — актуальная рабочая.
- Web-сборка: рассмотреть `--wasm` после стабилизации зависимостей.
- (2026-08-22) Даты в UI теперь локале-зависимые (de → `22.08.2026`); ISO оставлен только в именах файлов экспорта.
- (2026-08-22) CI на fork-PR: секрет `COMMERCIAL_REPO_TOKEN` недоступен — `pub get` приватной зависимости упадёт by design.
