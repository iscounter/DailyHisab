# 💰 DailyHisab

> Modern, offline-first, cross-platform personal finance app (Android-first) built with Flutter, Dart, and Rust.

## Decisions (confirmed)
- App type: **Personal Hisab** (income, expense, savings). Architecture kept extensible for business/family later.
- Primary currency: **BDT (৳)** (multi-currency-ready schema optional later).
- Backend: **Offline-first**, no backend in v1; **cloud sync planned** later (Rust/Axum + Postgres).

## Tech stack
- Flutter + Dart (UI, navigation, state, DB access)
- Riverpod, GoRouter
- SQLite + Drift
- Rust core (`dailyhisab_core`) via `flutter_rust_bridge` for financial calcs/report helpers
- fl_chart for analytics (added later)

## Repo layout (target)
```
DailyHisab/
  apps/mobile/        # Flutter app
  rust/dailyhisab_core/
  packages/           # design_system, shared_models, local_database (optional)
  docs/
  scripts/
  .github/workflows/
```

## Money rules
- Store amounts in **integer minor units** (e.g. ৳100.50 = `10050` poisha).
- Never use floating point for money math.
- Validate inputs; preserve history.

## Getting started (when Flutter/Rust installed)
```bash
cd apps/mobile
flutter pub get
flutter run
```

Rust core:
```bash
cd rust/dailyhisab_core
cargo test
```

## License
TBD

## CI/CD (GitHub Actions)
- `.github/workflows/flutter_ci.yml`: `flutter pub get`, `build_runner`, `flutter analyze`, `flutter test` (on push/PR).
- `.github/workflows/android_debug_apk.yml`: builds debug APK on push to `main`/`master` (or manual) and uploads artifact `dailyhisab-debug-apk`.
- `.github/workflows/rust_ci.yml`: `cargo fmt --check`, `cargo clippy`, `cargo test` for `rust/dailyhisab_core`.

## Release notes (honest)
This repo is a working MVP scaffold+codebase. For a **store release**, you must still: generate/platform projects configured, set app id/signing, run full QA on devices, review manifests/permissions, decide on encryption/backups policy, and complete store listings. No production deploy is performed by CI.

## Production release (Android) — what you must do
CI can build an **unsigned** release AAB via **Actions → Android Release AAB (unsigned artifact)** (`workflow_dispatch`). A Play Store uploadable AAB requires:
1. `apps/mobile/android` configured (package/applicationId, versionCode/versionName in `pubspec.yaml`/Gradle), icons, and release signing (`key.properties`, keystore) — **never commit keystores**.
2. Run locally or in a secured pipeline: `flutter build appbundle --release` after signing config.
3. Test on real devices, complete Play Console listing, data safety, permissions review.
I cannot sign or publish to any store without your credentials and explicit approval.
