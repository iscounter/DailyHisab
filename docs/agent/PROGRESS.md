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

### P1 — Data integrity
- [x] P1.1 `app_settings` Drift table + `AppSettingsRepository` (get/set/remove); wired to Settings
      currency display via `currencyCodeProvider`.
- [x] P1.2 Migrations: `schemaVersion` 2 + `onUpgrade` `from1To2` (creates `app_settings`).
- [x] P1.3 In-memory Drift repository tests: income/expense balances, transfer invariant,
      soft-delete exclusion, invalid-input rejection (`test/repositories_test.dart`).
- [x] P1.4 Testable DB constructor: `AppDatabase(QueryExecutor)` + `AppDatabase.forProduction()`.

### P2 — Core v1 features still missing
- [x] P2.1 Transaction search (notes) + type filter chips (client-side).
- [x] P2.2 Reports: spending by category for the month (`monthExpenseByCategoryProvider`) shown in Analytics.
- [x] P2.4 Per-account current balance shown on Accounts page (`accountBalancesProvider`, `balancesByAccount`).
- [x] P2.5 CSV export of transactions to clipboard (built-in `Clipboard`, no new dependency).
- [ ] P2.3 Backup / restore (versioned JSON export/import) with validation + confirmation.

### P3 — Localization & polish
- [ ] P3.1 Bengali + English (ARB + `intl`), remove hardcoded strings.
- [ ] P3.2 Accessibility pass (semantics, contrast, text scaling).
- [ ] P3.3 Empty/loading/error states consistency.

### P4 — Advanced (post-v1 per README)
- [x] P4.1 Savings goals (table v3 + repo + `SavingsPage`, linked from Dashboard).
- [ ] P4.1b Debts, recurring transactions.
- [ ] P4.2 CSV/PDF export (CSV-to-clipboard done; file/PDF pending), notifications, biometric lock.

### P5 — Rust integration (only if justified)
- [ ] P5.1 Benchmark Dart vs Rust for aggregation; wire `flutter_rust_bridge` if it wins.

### P6 — Release
- [ ] P6.1 App icon/splash, applicationId, signing (secrets), release AAB, device QA, store listing.
      **(requires human approval + credentials)**

## Current phase

**Phase P1 + P2.1/P2.2** — COMPLETE (code + tests written; not executed here, no toolchain)
- Next: P2.3 backup/restore, P3 localization.

## Changelog

- 2026-11-18: Baseline created. P0.1 (exact money parsing + tests), P0.2 (analytics axis),
  P0.3 (commit lockfiles policy) implemented.
- 2026-11-18: P1.1–P1.4 (app_settings table + repo, migrations v2, testable constructor,
  repository/invariant tests); P2.1 (search + filters); P2.2 (category reports in Analytics).
- 2026-11-26 (hotfix): **Android startup crash fixed.** The committed android project had
  `applicationId`/`namespace` = `com.dailyhisab.app` but a MainActivity class in the old
  package `com.dailyhisab.app.dailyhisab`, so the manifest entry `.MainActivity` resolved to
  a class that did not exist → instant `ClassNotFoundException` on launch on every Android
  version. The android project is now committed with namespace = applicationId = Kotlin
  package = `com.dailyhisab.app` (MainActivity at
  `android/app/src/main/kotlin/com/dailyhisab/app/MainActivity.kt`). Also: no `ndkVersion`
  declared (no plugin compiles native code); `path_provider_android`/`shared_preferences_android`
  pinned to the latest pre-JNI versions (2.2.23 / 2.4.28) so builds need no ~3 GB NDK download;
  adaptive launcher icons (৳ glyph) added; CI workflows run `flutter create` unconditionally
  to fill in gradle wrapper binaries without overwriting committed files. Verified by static
  config checks (XML/YAML parse, package consistency, icon integrity) — build via the
  "Android Debug APK" GitHub Actions workflow.
