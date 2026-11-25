# DailyHisab — Agent Progress & Roadmap

**Source:** `docs/agent/BASELINE.md`
**Rule:** Update after each phase. Never mark a phase complete without a real working implementation
and verification evidence (CI logs, since no local toolchain).

## Priority order (highest first)

### P0 — Correctness & safety (do first)
- [x] **P0.1 Exact money parsing (no float).** Added `parseBdtToMinor` + `minorToBdtInput` in
      `lib/core/utils/money.dart`; replaced `double.tryParse()*100` in transactions/accounts/budgets.
      Added unit tests in `test/money_test.dart`.
- [x] P0.2 Analytics Y-axis now plots major units (BDT), not poisha.
- [x] P0.3 `.gitignore` no longer ignores `pubspec.lock` / `Cargo.lock` (lockfiles still need to be
      generated once with a local toolchain to be committed — blocked in this env).
- [x] P0.4 (2026-11-25) `.5`-style leading-dot accepted; `.` / `100.` now correctly rejected
      (previously parsed as `0`); verified by tests.

### P1 — Data integrity
- [x] P1.1 `app_settings` Drift table + `AppSettingsRepository` (get/set/remove); wired to Settings
      currency display via `currencyCodeProvider`.
- [x] P1.2 Migrations: `schemaVersion` 2 + `onUpgrade` `from1To2` (creates `app_settings`).
- [x] P1.3 In-memory Drift repository tests: income/expense balances, transfer invariant,
      soft-delete exclusion, invalid-input rejection (`test/repositories_test.dart`).
- [x] P1.4 Testable DB constructor: `AppDatabase(QueryExecutor)` + `AppDatabase.forProduction()`.
- [x] P1.5 (2026-11-25) Archived accounts now count toward net worth (`sumOpeningBalanceMinor`
      includes archived; balances computed over all accounts; `unarchive` added). Budget spent
      is per-category (`sumExpenseMinorByCategory`), overall budgets use month totals.

### P2 — Core v1 features still missing
- [x] P2.1 Transaction search (notes) + type filter chips (client-side).
- [x] P2.2 Reports: spending by category for the month (`monthExpenseByCategoryProvider`) shown in Analytics.
- [x] P2.4 Per-account current balance shown on Accounts page (`accountBalancesProvider`, `balancesByAccount`).
- [x] P2.5 CSV export of transactions to clipboard (built-in `Clipboard`, no new dependency).
- [x] **P2.3 (2026-11-25) Backup / restore.** `lib/core/backup/backup_codec.dart` (versioned,
      fully validated JSON: types, enums, duplicates, referential integrity, BDT-only) +
      `BackupRepository` (export incl. archived accounts & soft-deleted rows; atomic full-replace
      restore inside one SQLite transaction). Settings page: export via `share_plus` file share,
      restore via `file_picker` + explicit confirmation dialog with row counts. Tests:
      `test/backup_codec_test.dart` (15 cases), `test/backup_repository_test.dart` (round-trip +
      malformed-rejection).

### P3 — Localization & polish
- [x] **P3.1 (2026-11-25) Bengali + English.** Standard `flutter gen-l10n` (ARB in `lib/l10n/`,
      generated classes in `lib/l10n/generated/`, ~100 strings × 2 locales). All 8 screens,
      router and dialogs localized. In-app language picker (System / English / বাংলা) persisted
      via SharedPreferences; system locale by default.
- [x] P3.2 Accessibility pass: tooltips on all icon buttons, `Semantics` labels on balances,
      progress bars, chart and transaction icons; both kinds conveyed by icon + label + color.
- [x] P3.3 Consistent empty/loading/error states via shared `EmptyStateView` / `ErrorStateView`
      (`lib/core/widgets/state_views.dart`); friendly headline + secondary technical details.
- [x] P3.4 (2026-11-25) Transaction delete now confirms first, then offers **Undo** (soft-delete
      `restore()`), replacing instant swipe-delete.

### P4 — Advanced (post-v1 per README)
- [x] P4.1 Savings goals (table v3 + repo + `SavingsPage`, linked from Dashboard).
- [ ] P4.1b Debts, recurring transactions.
- [ ] P4.2 CSV file/PDF export (CSV-to-clipboard done), notifications, biometric lock.

### P5 — Rust integration (only if justified)
- [x] P5.0 (2026-11-25) Rust crate repaired & green: tests were not compiling (`CoreError`
      missing `PartialEq`); fixed, unused `serde`/`serde_json` deps removed, clippy `-D warnings`
      and `cargo fmt --check` clean. `cargo test`: **10/10 pass**. Bridge still deferred (P5.1).

### P6 — Release
- [x] P6.0 (2026-11-25) Android runner committed (`flutter create --org com.dailyhisab.app`),
      `applicationId`/namespace = `com.dailyhisab.app`, label "DailyHisab", adaptive launcher
      icon generated (white ৳ on #1B6B4A, all densities + anydpi-v26). Version bumped to
      **1.0.0+1**. `pubspec.lock` + `Cargo.lock` generated with real toolchains and committed.
- [ ] P6.1 Signing, release AAB, device QA, store listing. **(requires human approval + credentials)**

## Current phase

**v1 feature-complete (code-complete).** Verified locally with Flutter 3.50.1 stable:
`flutter analyze` → no issues; `flutter test` → 32/32 pass (incl. widget smoke tests);
Rust `cargo test` → 10/10. Remaining for store release: signing + device QA (P6.1),
optional post-v1 features (P4.x), optional Rust bridge (P5.1).

## Changelog

- 2026-11-18: Baseline created. P0.1 (exact money parsing + tests), P0.2 (analytics axis),
  P0.3 (commit lockfiles policy) implemented.
- 2026-11-18: P1.1–P1.4 (app_settings table + repo, migrations v2, testable constructor,
  repository/invariant tests); P2.1 (search + filters); P2.2 (category reports in Analytics).
- 2026-11-25: Production-readiness pass. P0.4 money parser edge cases; P1.5 archived-account
  balance correctness + per-category budget spend; P2.3 backup/restore (codec + repository +
  settings UI + tests); P3.1 full BN/EN localization with in-app language switch; P3.2/P3.3
  polish (shared empty/error states, semantics, confirm+undo delete); P5.0 Rust crate fixed
  (compiling tests, clean clippy/fmt); P6.0 Android runner, appId, adaptive icon, version
  1.0.0+1, lockfiles committed. Widget smoke tests added (`test/widget_test.dart`).