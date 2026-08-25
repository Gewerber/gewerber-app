# Golden tests

Pixel-regression goldens for the core screens, captured through the real app
shell (mock DI, demo sign-in) at two viewport sizes:

- `390x844` (phone) — the narrow side of every layout breakpoint
- `900x1280` (wide) — exactly on the app's `>= 900` breakpoints
  (shell navigation rail, dashboard two-column layout, settings master-detail)

## Run / regenerate

Goldens are **generated on Linux** (Flutter's default test renderer); other
platforms may produce slightly different rasterization.

```bash
# Re-baseline after an intentional UI change (regenerates the PNGs):
flutter test test/goldens --update-goldens

# Verify (plain run, no regeneration):
flutter test
```

## Determinism

The suite is built to produce byte-identical output regardless of machine and
calendar date:

- **Fonts** — the production theme resolves Inter/Roboto Mono through
  `google_fonts` at runtime. The tests set
  `GoogleFonts.config.allowRuntimeFetching = false`
  (`golden_test_helper.dart`), so no network I/O happens and all text renders
  with the Flutter engine's deterministic test font. The repo bundles no font
  assets; if real font files are added under `assets/`, load them via
  `FontLoader` in `configureGoldenEnvironment()` and the goldens will pick up
  real glyphs (re-baseline required).
- **Dates** — every wall-clock input is pinned through the existing
  repository/DI seams, without touching production code:
  - Dashboard: `installGoldenDashboardRepository()` wraps the mock
    `DashboardRepository`, passes a fixed anchor (`goldenAnchor`,
    2026-08-25) to trends/activity, and returns a fully fixed receivables
    fixture (the overdue rows render absolute due dates and the mock's
    `receivables()` has no anchor seam).
  - Documents: `installGoldenDocumentRepository()` rewrites the rendered
    `createdAt` of every document to a fixed date (the mock stamps uploads
    with `DateTime.now()` internally).
  - Invoices / invoice detail: fixed fixture entities with absolute dates.
  - Report: fixture transactions are placed at noon of the **first day of
    the current calendar month**, which is inside the "this month" window on
    every possible run date; the screen itself renders no dates.
- **Known remaining clock dependency** — `DashboardScreen._load()`,
  `ReportScreen` and `TimeReportScreen` call `DateTime.now()` directly to
  compute their period ranges; there is no clock injection seam at the
  screen/cubit level. The goldens neutralize this at the repository layer as
  described above. If a future change renders a wall-clock-derived value on
  one of these screens, the affected golden will need the same
  wrapper/fixture treatment (or a clock seam in production code).

## Inventory

| Screen | File | Phone (390x844) | Wide (900x1280) |
|---|---|---|---|
| Dashboard (single vs two-column at >= 900) | `dashboard_golden_test.dart` | `dashboard_phone_390x844.png` | `dashboard_wide_900x1280.png` |
| Invoicing list (fixture invoices) | `invoicing_golden_test.dart` | `invoicing_list_phone_390x844.png` | `invoicing_list_wide_900x1280.png` |
| Invoice detail (fixture invoice + payment) | `invoice_detail_golden_test.dart` | `invoice_detail_phone_390x844.png` | `invoice_detail_wide_900x1280.png` |
| Accounting report (P&L, this month) | `report_golden_test.dart` | `report_phone_390x844.png` | `report_wide_900x1280.png` |
| Documents list (fixture uploads, pinned dates) | `documents_golden_test.dart` | `documents_phone_390x844.png` | `documents_wide_900x1280.png` |
| Settings master-detail (list vs two panes at >= 600) | `settings_about_golden_test.dart` | `settings_phone_390x844.png` | `settings_wide_900x1280.png` |
| About | `settings_about_golden_test.dart` | `about_phone_390x844.png` | — |
