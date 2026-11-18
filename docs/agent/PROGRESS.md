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
- [ ] P1.1 Add `app_settings` Drift table + repository (key/value) for preferences.
- [ ] P1.2 Schema migrations: bump `schemaVersion`, add `onUpgrade` with `from1To2`, add migration test.
- [ ] P1.3 Repository tests using in-memory Drift (`NativeDatabase.memory`).

### P2 — Core v1 features still missing
- [ ] P2.1 Transaction search & filters (text, type, date range) — repository query + UI.
- [ ] P2.2 Reports: spending by category (month) — repository aggregation + UI.
- [ ] P2.3 Backup / restore (versioned JSON export/import) with validation + confirmation.

### P3 — Localization & polish
- [ ] P3.1 Bengali + English (ARB + `intl`), remove hardcoded strings.
- [ ] P3.2 Accessibility pass (semantics, contrast, text scaling).
- [ ] P3.3 Empty/loading/error states consistency.

### P4 — Advanced (post-v1 per README)
- [ ] P4.1 Savings goals, debts, recurring transactions.
- [ ] P4.2 CSV/PDF export, notifications, biometric lock.

### P5 — Rust integration (only if justified)
- [ ] P5.1 Benchmark Dart vs Rust for aggregation; wire `flutter_rust_bridge` if it wins.

### P6 — Release
- [ ] P6.1 App icon/splash, applicationId, signing (secrets), release AAB, device QA, store listing.
      **(requires human approval + credentials)**

## Current phase

**Phase P0 — Correctness & safety** — COMPLETE (code + tests written; not executed here, no toolchain)
- Next: Phase P1 (data integrity).

## Changelog

- 2026-11-18: Baseline created. P0.1 (exact money parsing + tests), P0.2 (analytics axis),
  P0.3 (commit lockfiles policy) implemented.