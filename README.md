# 💰 DailyHisab

> A modern, offline-first personal finance app for tracking income, expenses, balances, budgets and savings — Android first, with a shared-codebase path to iOS and desktop.

![Flutter](https://img.shields.io/badge/UI-Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Language-Dart-0175C2?logo=dart&logoColor=white)
![Rust](https://img.shields.io/badge/Core-Rust-000000?logo=rust&logoColor=white)
![SQLite](https://img.shields.io/badge/Storage-SQLite-003B57?logo=sqlite&logoColor=white)
![Status](https://img.shields.io/badge/Status-v1%20feature%20complete%20(analyze%2Ftests%20green)-success)

## 1. Product vision

DailyHisab helps an individual understand and manage personal money. The first release focuses on dependable income and expense tracking, account balances, categories, budgets and useful summaries. It must remain useful without an internet connection.

**Initial product decisions**

- Product: Personal finance / personal hisab.
- Primary currency: Bangladeshi Taka (`BDT`, ৳).
- Money precision: Store amounts as integer poisha; never use floating-point values for money.
- Initial platform: Android.
- Planned platforms: iOS, Windows, macOS and Linux.
- Initial data model: Local-first; SQLite is the source of truth.
- Cloud: No backend required for v1. Design repository boundaries so cloud sync can be added later.
- Native core: Rust is planned for deterministic calculations and selected data-processing tasks; keep the first release functional without Rust FFI if integration adds unnecessary risk.

## 2. Technology stack

| Area | Technology | Responsibility |
|---|---|---|
| UI framework | Flutter | Cross-platform screens, adaptive layouts, animation and accessibility |
| Main language | Dart | App workflows, validation, repositories, state and platform orchestration |
| Design | Material 3 + custom design tokens | Consistent visual system and theming |
| State / dependency injection | Riverpod | Feature state and dependency wiring |
| Navigation | GoRouter | Declarative routes and deep-link-ready navigation |
| Local database | SQLite + Drift | Typed queries, reactive reads and schema migrations |
| Native shared core | Rust | Pure calculations and heavier deterministic processing where justified |
| Dart ↔ Rust | flutter_rust_bridge 2.x | Generated bindings when Rust integration is enabled |
| Charts | fl_chart (optional, analytics phase) | Dashboard and report visualizations |
| Notifications | flutter_local_notifications (optional, reminder phase) | Local reminders; no cloud push needed for v1 |
| Future API | Rust + Axum (planned only) | Future cloud sync API |
| Future cloud database | PostgreSQL (planned only) | Future server-side data storage |
| CI | GitHub Actions | Formatting, analysis, tests and build checks |

Use the latest mutually compatible **stable** package versions when implementation begins. Commit `pubspec.lock` and `Cargo.lock`; do not copy version numbers from an old template without checking compatibility.

## 3. Core v1 features

- Dashboard with total balance, income, expense and selected-period summary.
- Add, edit and view income and expense transactions.
- Multiple local accounts (cash, bank and mobile wallet).
- Default and user-created income / expense categories.
- Transaction history with search, date range and category filters.
- Favorites are not a financial requirement; avoid adding them unless there is a clear product use case.
- Monthly budget tracking.
- Basic spending breakdown and reports.
- Bengali and English UI, with BDT formatting.
- Light, dark and system theme.
- Local backup and restore.
- Optional daily reminder notifications.

### Planned after the first stable release

Recurring transactions, debt/loan tracking, richer charts, PDF export, biometric app lock, encrypted backup, and cloud synchronization. Treat these as separate milestones rather than blocking the first usable release.

## Verification status (2026-11-25)

- Flutter 3.50.1 stable: `flutter analyze` — **no issues**; `flutter test` — **32/32 pass** (unit, repository, backup codec/restore, widget smoke tests).
- Rust stable (1.100): `cargo test` — **10/10 pass**; `cargo clippy -D warnings` and `cargo fmt --check` clean.
- Android runner committed (`applicationId com.dailyhisab.app`, adaptive launcher icon).
- Debug/release APK and AAB builds run in GitHub Actions (`android_debug_apk.yml`, `android_release.yml`); store release still needs signing keys and device QA.

## 4. Architecture at a glance

```text
                 Flutter Presentation (Material 3)
                              |
                              v
                    Dart Application Layer
                 Riverpod • Use cases • Routing
                              |
                    Repository interfaces
                              |
                  +-----------+-----------+
                  |                       |
                  v                       v
           Local data source        Optional Rust core
             Drift / SQLite        pure calculations / reports
                  |                       |
                  +-----------+-----------+
                              |
                     Local application state
                              |
                    Future Sync Adapter
                              |
                    Future HTTPS API
                              |
                    Rust / Axum + PostgreSQL
```

**Important boundary:** Dart owns application workflows and database access. Rust does not directly open the app database, draw UI, or own navigation. Rust is introduced only behind a small Dart-facing interface and only for work that benefits from it.

## 5. Financial data rules

1. Store BDT as integer poisha: `৳100.50 = 10050`.
2. Never use `double` / floating point for money calculations or persisted amounts.
3. Keep transaction amounts positive; transaction type and account direction determine whether the amount increases or decreases an account.
4. An expense reduces the source account; income increases the destination account; a transfer reduces one account and increases another by the same amount.
5. A transfer must not change the user's overall net worth / total cash balance.
6. Use SQLite database transactions when one user action changes multiple rows.
7. Validate input, currency and account references before writing.
8. Store event timestamps in UTC; convert to local time only for display and reminder scheduling.
9. Do not silently rewrite historical transactions. Edits and deletions must be explicit and tested.
10. Do not persist a second mutable account balance unless there is a carefully tested reconciliation strategy. Derive balances from opening balances and posted transactions in v1.

## 6. Repository layout

```text
DailyHisab/
├── apps/
│   └── mobile/
│       ├── android/
│       ├── ios/                     # enable/configure for iOS milestone
│       ├── windows/                 # enable/configure for desktop milestone
│       ├── macos/                   # enable/configure for desktop milestone
│       ├── linux/                   # enable/configure for desktop milestone
│       ├── lib/
│       │   ├── main.dart
│       │   ├── bootstrap/
│       │   ├── app/
│       │   ├── core/
│       │   └── features/
│       ├── test/
│       ├── integration_test/
│       ├── assets/
│       └── pubspec.yaml
├── rust/
│   └── dailyhisab_core/
│       ├── Cargo.toml
│       └── src/
├── docs/
│   ├── PROJECT_ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── SECURITY.md
│   └── adr/
├── scripts/
├── .github/workflows/
├── .editorconfig
├── .gitignore
├── README.md
└── LICENSE
```

Do not create empty packages just to make the tree look enterprise-scale. Extract `design_system`, `local_database` or other packages only when they have stable boundaries or need independent reuse.

## 7. Quick start

### Prerequisites

- Flutter SDK (stable channel) and its bundled Dart SDK.
- Android Studio / Android SDK / Android emulator or a physical Android device.
- Rust stable toolchain (`rustup`, `rustc`, `cargo`) only when starting Rust work.
- Git and an editor such as VS Code or Android Studio.

Run environment checks:

```bash
flutter doctor -v
flutter --version
dart --version
```

When Rust is needed:

```bash
rustc --version
cargo --version
rustup show
```

### Create the Android-first Flutter app

Run from the repository parent directory:

```bash
mkdir DailyHisab
cd DailyHisab
mkdir -p apps rust docs scripts
flutter create --org com.yourdomain --platforms android apps/mobile
cd apps/mobile
flutter pub get
flutter run
```

Replace `com.yourdomain` with an application ID you control before release. The command above intentionally creates Android first; add other Flutter platform runners when each platform milestone begins.

### Add core Flutter packages

From `apps/mobile`:

```bash
flutter pub add flutter_riverpod go_router drift drift_flutter path_provider path intl
flutter pub add --dev build_runner drift_dev flutter_lints mocktail
```

Add packages such as `fl_chart`, `flutter_local_notifications`, `share_plus`, `file_picker` or localization helpers only when the corresponding feature is implemented. Verify each plugin's supported platforms before adopting it.

### Create the Rust crate (later milestone)

From the repository root:

```bash
cargo new rust/dailyhisab_core --lib
```

Keep the first Rust crate independent and testable. Add `flutter_rust_bridge` only when there is a defined Rust API to expose. Follow the current bridge quickstart rather than manually copying old v1 setup instructions.

## 8. Quality gates

Before merging a change:

```bash
cd apps/mobile
 dart format --output=none --set-exit-if-changed .
 flutter analyze
 flutter test
```

For the Rust crate:

```bash
cd rust/dailyhisab_core
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test
```

A feature is not complete until its data behavior, failure states, accessibility, offline behavior and relevant tests have been checked.

## 9. Platform roadmap

| Stage | Platform | Main work |
|---|---|---|
| 1 | Android | MVP, database, finance workflows, backup and device QA |
| 2 | iOS | Xcode setup, iOS plugin review, signing, iPhone/iPad QA |
| 3 | Windows | Desktop navigation/layout, keyboard/mouse, Windows build tooling |
| 4 | macOS | macOS runner, Apple signing/notarization and desktop QA |
| 5 | Linux | Linux dependencies, packaging and desktop QA |
| Optional | Web | Browser-compatible storage and a separate Rust/Wasm integration path if Rust is used there |

A shared Flutter codebase does not guarantee every plugin or native feature works identically on every platform. iOS and macOS builds require macOS with Xcode; Windows desktop builds require Windows build tooling. Validate plugin support on each target.

## 10. Security and privacy baseline

- Collect no account or personal information that the offline app does not need.
- Do not log financial notes, balances, PINs, credentials or backup contents.
- Use parameterized database queries and validate all imported data.
- Protect future credentials and encryption keys with platform secure storage; ordinary preferences are not a secure vault.
- A PIN/biometric screen lock is not the same as encrypting the database or backups.
- Define backup encryption, key recovery and data-loss behavior before advertising backups as secure.
- Review permissions and third-party dependencies before each release.

## 11. Scope and release honesty

This repository blueprint is a design and implementation guide, not a claim that a working app, Rust integration, CI pipeline or store-ready build already exists. A production release still requires implementation, device testing, app identifiers, signing, privacy review, store assets and release validation.

See [`docs/PROJECT_ARCHITECTURE.md`](docs/PROJECT_ARCHITECTURE.md) for the detailed technical blueprint.

---

**DailyHisab — Know your money. Plan your future.**
