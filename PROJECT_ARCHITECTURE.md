# DailyHisab — Project Architecture

**Document status:** Architecture baseline for v1  
**Product:** Personal finance / personal hisab  
**Primary currency:** BDT (Bangladeshi Taka)  
**Initial platform:** Android  
**Expansion targets:** iOS, Windows, macOS, Linux  
**Data strategy:** Offline-first, local source of truth  
**Backend:** None in v1; cloud sync is a future milestone

---

## 1. Product goals

DailyHisab is a personal finance application for recording and understanding an individual's money. The initial product should make it easy to record income and expenses, understand account balances, set budgets, and review spending without requiring an account or internet connection.

### 1.1 Product requirements

- Create, edit, view and explicitly delete income and expense transactions.
- Keep data on the user's device in v1.
- Support more than one local account, such as cash, bank and mobile wallet.
- Support standard and user-created categories.
- Show account balances and a combined balance for the selected currency.
- Provide date, category and transaction-type filtering.
- Provide basic monthly budget tracking and summary reports.
- Support Bengali and English UI and correct BDT formatting.
- Support light, dark and system themes.
- Provide a user-controlled local backup and restore workflow.
- Remain extensible for savings goals, recurring transactions, debt tracking and later cloud sync.

### 1.2 Non-goals for v1

- No mandatory registration, authentication or cloud account.
- No bank account aggregation or automatic bank synchronization.
- No payment processing or money transfer to real financial institutions.
- No multi-user household collaboration.
- No mandatory subscription, paid API or advertising integration.
- No mandatory Rust dependency for ordinary UI or database operations.

### 1.3 Architecture principles

1. Offline-first: the app's core workflows must work with airplane mode enabled.
2. Flutter-first: Dart owns app orchestration and UI behavior.
3. Feature-first: code is organized around user-facing product capabilities.
4. Explicit boundaries: UI, domain rules, data access and native code remain separate.
5. Deterministic money math: use integer minor units and testable rules.
6. Migration discipline: every database schema change has an upgrade path.
7. Privacy by default: do not collect or transmit financial data in v1.
8. Measured optimization: introduce Rust only where reuse or measured performance justifies it.
9. Platform-aware: native plugins and UI must be checked on every target platform.
10. Tested behavior: financial calculations and data mutations require automated tests.

## 2. Technology decisions

| Layer | Choice | Why / boundary |
|---|---|---|
| Cross-platform UI | Flutter | One UI codebase for Android, iOS and desktop targets |
| Main language | Dart | UI, workflows, validation, repositories and local database integration |
| UI design | Material 3 + app design tokens | Consistent components, spacing, typography and theme |
| State management | Riverpod | State composition and dependency injection |
| Navigation | GoRouter | Declarative routes and future deep-link support |
| Relational storage | SQLite | Durable local relational data |
| Dart database toolkit | Drift | Typed tables/queries, reactive queries and migration support |
| Rust core | Rust stable | Pure calculations and selected shared native processing |
| Dart/Rust bridge | flutter_rust_bridge 2.x | Generated binding layer when native core integration is implemented |
| Charts | fl_chart (later) | Dashboard and reporting visualization |
| Local reminders | flutter_local_notifications (later) | Optional on-device reminders |
| Future server | Rust + Axum | Potential HTTPS sync API; not part of v1 |
| Future cloud DB | PostgreSQL | Server-side storage if/when sync is approved |
| Automation | GitHub Actions | Static checks and tests |

### 2.1 Version policy

- Use stable Flutter and Dart releases compatible with the selected packages.
- Use stable Rust unless a documented dependency requires another channel.
- Resolve package versions at implementation time; do not blindly pin versions from this document.
- Commit `pubspec.lock` for the application and `Cargo.lock` for the Rust workspace/application crate.
- Upgrade dependencies in small batches and run the full test suite after upgrades.
- Record significant choices in Architecture Decision Records (ADRs).

### 2.2 Why not Kotlin + Jetpack Compose?

Kotlin + Jetpack Compose is an excellent choice for an Android-only native app. DailyHisab's confirmed roadmap includes iOS and desktop, so Flutter is selected to share most UI and application code across those targets. Native platform code may still be needed for selected integrations.

### 2.3 Why not Rust for the whole app?

Rust is valuable for a portable native core, but it is not a replacement for Flutter's UI layer or the app's database orchestration. For the first release, Rust should remain a small, isolated library. Do not route simple form validation, navigation or ordinary database CRUD through FFI.

## 3. Layered architecture

```text
┌──────────────────────────────────────────────────────────┐
│                 Presentation / Flutter                    │
│ Pages • Widgets • Responsive UI • Accessibility • Theme  │
└──────────────────────────────┬───────────────────────────┘
                               │ user intent / state
┌──────────────────────────────▼───────────────────────────┐
│                  Application / Dart                       │
│ Riverpod • Use cases • Validation • App orchestration    │
└──────────────────────────────┬───────────────────────────┘
                               │ repository contracts
┌──────────────────────────────▼───────────────────────────┐
│                     Domain Layer                           │
│ Entities • Value rules • Repository interfaces            │
└───────────────────────┬─────────────────────┬─────────────┘
                        │                     │
┌───────────────────────▼──────────┐  ┌───────▼─────────────┐
│ Data Layer / Dart                │  │ Optional Rust Core  │
│ Drift • SQLite • mappers         │  │ Pure deterministic  │
│ repositories • backup adapters   │  │ calculations        │
└───────────────────────┬──────────┘  └─────────┬───────────┘
                        │                       │
                        └───────────┬───────────┘
                                    │
                         Optional future sync port
                                    │
                         HTTPS API (future only)
                                    │
                         Axum + PostgreSQL (future)
```

### 3.1 Presentation layer

Contains pages, reusable widgets, responsive layouts, form state presentation, accessibility labels and theme-aware design. Widgets must not contain SQL queries or financial calculation rules.

### 3.2 Application layer

Coordinates user actions through use cases/services. Examples:

- `CreateTransaction`
- `UpdateTransaction`
- `DeleteTransaction`
- `GetAccountBalance`
- `GetDashboardSummary`
- `SetMonthlyBudget`
- `ExportLocalBackup`
- `RestoreLocalBackup`

The application layer calls repository interfaces and converts domain/data failures into user-understandable states.

### 3.3 Domain layer

Contains platform-independent entities, enums, validation rules and repository contracts. It must not import Flutter widgets, Drift generated database classes, Riverpod or Rust bridge implementation details.

### 3.4 Data layer

Contains Drift table definitions, DAOs/queries, repository implementations, persistence models, mappers, migrations, and backup serialization. SQLite remains the v1 source of truth.

### 3.5 Rust core boundary

Rust is a pure library with a small public API. It may provide deterministic calculations or batch processing. It must not own the app's database, navigation, UI state or network session.

## 4. Monorepo structure

```text
DailyHisab/
├── apps/
│   └── mobile/
│       ├── android/
│       ├── ios/                       # add in iOS milestone
│       ├── windows/                   # add in desktop milestone
│       ├── macos/                     # add in desktop milestone
│       ├── linux/                     # add in desktop milestone
│       ├── lib/
│       │   ├── main.dart
│       │   ├── bootstrap/
│       │   │   ├── bootstrap.dart
│       │   │   ├── app_initializer.dart
│       │   │   └── error_reporting.dart
│       │   ├── app/
│       │   │   ├── app.dart
│       │   │   ├── app_theme.dart
│       │   │   ├── app_router.dart
│       │   │   └── app_providers.dart
│       │   ├── core/
│       │   │   ├── errors/
│       │   │   ├── formatting/
│       │   │   ├── localization/
│       │   │   ├── logging/
│       │   │   ├── platform/
│       │   │   ├── security/
│       │   │   ├── utils/
│       │   │   └── widgets/
│       │   └── features/
│       │       ├── dashboard/
│       │       │   ├── data/
│       │       │   ├── domain/
│       │       │   └── presentation/
│       │       ├── transactions/
│       │       │   ├── data/
│       │       │   ├── domain/
│       │       │   └── presentation/
│       │       ├── accounts/
│       │       ├── categories/
│       │       ├── budgets/
│       │       ├── reports/
│       │       ├── backup/
│       │       └── settings/
│       ├── test/
│       ├── integration_test/
│       ├── assets/
│       │   ├── icons/
│       │   ├── images/
│       │   └── fonts/
│       └── pubspec.yaml
├── rust/
│   └── dailyhisab_core/
│       ├── Cargo.toml
│       ├── Cargo.lock
│       ├── src/
│       │   ├── lib.rs
│       │   ├── money.rs
│       │   ├── aggregation.rs
│       │   ├── validation.rs
│       │   └── error.rs
│       └── tests/
├── docs/
│   ├── PROJECT_ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── SECURITY.md
│   └── adr/
│       ├── 0001-flutter-cross-platform.md
│       ├── 0002-offline-first-sqlite.md
│       ├── 0003-integer-money-storage.md
│       └── 0004-rust-core-boundary.md
├── scripts/
│   ├── analyze.sh
│   ├── test.sh
│   └── build_android.sh
├── .github/
│   └── workflows/
│       ├── flutter_ci.yml
│       └── rust_ci.yml
├── .editorconfig
├── .gitignore
├── README.md
└── LICENSE
```

The tree describes the intended target layout. Platform runners and optional modules can be created when their milestone starts. Avoid empty modules and premature packages.

## 5. Feature modules

Each feature uses a simple three-layer structure. Keep files small and name them by responsibility.

```text
features/transactions/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

Feature ownership:

| Feature | Responsibilities |
|---|---|
| Dashboard | Combined balances, income/expense totals, current-period summary |
| Transactions | Create/edit/delete/list income, expense and transfers |
| Accounts | Cash, bank and wallet accounts; opening balance and account archive |
| Categories | Income and expense categories, system defaults and custom categories |
| Budgets | Monthly budget limits and spent/remaining calculations |
| Reports | Period summaries and category-based analysis |
| Backup | Export, validate and restore local data |
| Settings | Language, theme, currency display, reminders and app preferences |

## 6. Money and accounting rules

This section is critical. Financial data must not rely on floating-point arithmetic.

### 6.1 Currency representation

- Currency code: `BDT`.
- Currency display symbol: `৳`.
- Base storage unit: poisha (1 BDT = 100 poisha).
- Example: `৳1,234.56` is stored as integer `123456`.
- Database type: SQLite `INTEGER` (signed 64-bit integer).
- Dart representation: `int` within the supported 64-bit monetary range.
- Rust representation: `i64` for values crossing the Rust boundary.

Do not parse user-entered decimals through binary floating point. Parse the decimal string, validate the allowed precision, and convert directly to integer poisha.

### 6.2 Transaction model

Use a positive `amount_minor` with a transaction type and account direction:

| Type | Source account | Destination account | Account effect |
|---|---|---|---|
| Income | `NULL` | required | Destination increases |
| Expense | required | `NULL` | Source decreases |
| Transfer | required | required, different from source | Source decreases and destination increases |

For v1, all accounts and transactions use BDT. Keep `currency_code` in the schema to make future migration explicit, but reject unsupported currencies in the v1 UI and domain rules.

### 6.3 Balance formula

For a single account:

```text
balance_minor = opening_balance_minor
              + sum(income posted to this account)
              - sum(expenses paid from this account)
              + sum(transfers received)
              - sum(transfers sent)
```

Combined balance is the sum of account balances for the same currency. Do not sum different currencies without an explicit exchange-rate and valuation model.

### 6.4 Invariants

- `amount_minor > 0` for every posted transaction.
- An income transaction has a destination account and no source account.
- An expense transaction has a source account and no destination account.
- A transfer has both accounts, and the accounts must differ.
- A transfer has equal debit and credit amounts in the same currency.
- Account IDs and category IDs must reference existing records.
- A category used by a transaction must have a compatible type (income or expense); transfers do not require a category in v1.
- An archived account cannot be selected for new transactions, but historical transactions remain visible.
- Every create/update/delete operation that affects multiple records runs in one SQLite transaction.

## 7. Local database design

Use SQLite through Drift. Define tables in Dart and manage all schema updates through Drift migrations. Keep a human-readable `docs/DATABASE.md` synchronized with the actual table definitions.

### 7.1 Tables for v1

#### `accounts`

| Column | Type | Rule |
|---|---|---|
| `id` | TEXT | Primary key; UUID string |
| `name` | TEXT | Required, non-empty |
| `account_type` | TEXT | `cash`, `bank`, `mobile_wallet`, `other` |
| `opening_balance_minor` | INTEGER | Required; signed integer poisha |
| `currency_code` | TEXT | Default `BDT`; v1 supports BDT only |
| `created_at_utc` | INTEGER | UTC epoch milliseconds |
| `updated_at_utc` | INTEGER | UTC epoch milliseconds |
| `archived_at_utc` | INTEGER NULL | Null while active |

#### `categories`

| Column | Type | Rule |
|---|---|---|
| `id` | TEXT | Primary key |
| `name` | TEXT | Required |
| `kind` | TEXT | `income` or `expense` |
| `icon_key` | TEXT NULL | App-owned icon identifier, not arbitrary executable content |
| `color_key` | TEXT NULL | Theme token identifier |
| `is_system` | INTEGER | Boolean 0/1 |
| `sort_order` | INTEGER | Default 0 |
| `created_at_utc` | INTEGER | UTC epoch milliseconds |
| `updated_at_utc` | INTEGER | UTC epoch milliseconds |

#### `transactions`

| Column | Type | Rule |
|---|---|---|
| `id` | TEXT | Primary key |
| `kind` | TEXT | `income`, `expense`, `transfer` |
| `amount_minor` | INTEGER | Required and greater than 0 |
| `currency_code` | TEXT | Default `BDT` |
| `category_id` | TEXT NULL | Required for income/expense if policy requires; null for transfer |
| `from_account_id` | TEXT NULL | Required for expense/transfer |
| `to_account_id` | TEXT NULL | Required for income/transfer |
| `note` | TEXT NULL | User-entered free text |
| `occurred_at_utc` | INTEGER | UTC epoch milliseconds |
| `created_at_utc` | INTEGER | UTC epoch milliseconds |
| `updated_at_utc` | INTEGER | UTC epoch milliseconds |
| `deleted_at_utc` | INTEGER NULL | Soft-delete marker; useful for recovery/future sync |

Add foreign keys to accounts and categories. Use `ON DELETE RESTRICT` for financial records where possible; archive accounts/categories rather than deleting referenced history. A deliberate transaction deletion should use an explicit repository operation and preserve a recoverable backup path.

#### `budgets`

| Column | Type | Rule |
|---|---|---|
| `id` | TEXT | Primary key |
| `category_id` | TEXT NULL | Null can represent an overall monthly budget |
| `period_year` | INTEGER | Required |
| `period_month` | INTEGER | 1–12 |
| `limit_minor` | INTEGER | Positive integer poisha |
| `currency_code` | TEXT | Default `BDT` |
| `created_at_utc` | INTEGER | UTC epoch milliseconds |
| `updated_at_utc` | INTEGER | UTC epoch milliseconds |

Add a unique constraint to prevent duplicate budgets for the same category and month. Decide whether the overall budget and category budgets can coexist; document the calculation rule in the UI and tests.

#### `app_settings`

| Column | Type | Rule |
|---|---|---|
| `key` | TEXT | Primary key |
| `value` | TEXT | Serialized simple setting value; never store secrets here |
| `updated_at_utc` | INTEGER | UTC epoch milliseconds |

### 7.2 Future tables (not required for v1)

- `savings_goals`
- `recurring_transactions`
- `debts` / `loans`
- `sync_metadata`
- `audit_events`

Do not create these tables until their user workflows and data rules are designed. Cloud sync requires revisions, tombstones, conflict handling and idempotency; a placeholder table alone does not make an app sync-ready.

### 7.3 Indexes

Add indexes based on actual query patterns, likely:

- `transactions(occurred_at_utc)`
- `transactions(kind, occurred_at_utc)`
- `transactions(category_id, occurred_at_utc)`
- `transactions(from_account_id, occurred_at_utc)`
- `transactions(to_account_id, occurred_at_utc)`
- `budgets(period_year, period_month)`

Use `EXPLAIN QUERY PLAN` before adding more indexes. Avoid indexes that duplicate a unique constraint or add write overhead without benefit.

### 7.4 Migration policy

- Increment the schema version for every schema change.
- Write and test a migration from each supported prior version.
- Never use destructive table recreation for a production database unless data loss is explicitly intended and approved.
- Test empty database creation and upgrades with representative existing records.
- Keep migration tests in CI.

## 8. State management and dependency injection

Use Riverpod for dependency wiring and reactive feature state.

Recommended flow:

```text
Widget
  -> Riverpod notifier/provider
      -> Use case
          -> Repository interface
              -> Drift repository implementation
                  -> SQLite
```

Guidelines:

- Keep providers focused on one responsibility.
- Keep business rules in domain/use-case code, not in widget build methods.
- Use immutable state models where practical.
- Expose loading, data, empty and error states in every data-driven screen.
- Dispose stream subscriptions and controllers correctly.
- Do not put the entire application into one global notifier.

## 9. Navigation plan

Use GoRouter with stable paths. Example route map:

```text
/
├── onboarding
├── dashboard
├── transactions
│   ├── new
│   └── :transactionId
├── accounts
│   ├── new
│   └── :accountId
├── categories
├── budgets
├── reports
├── backup
└── settings
```

Onboarding can be skipped or completed locally. Routes must handle missing or archived records without crashing.

## 10. Design system and accessibility

### 10.1 Visual system

- Material 3 components with a distinctive DailyHisab identity.
- Light, dark and system themes.
- Centralized color, spacing, radius, typography and elevation tokens.
- Reusable buttons, cards, dialogs, empty states, amount inputs and error messages.
- Responsive layouts for narrow phones, tablets and desktop windows.
- Avoid hardcoded color values and spacing inside feature widgets.

### 10.2 Finance-specific UI rules

- Format amounts with BDT symbol and locale-aware grouping.
- Distinguish income, expense and transfer using both labels/icons and color; never rely on color alone.
- Make the amount field easy to edit and validate before saving.
- Show confirmation before destructive operations.
- Make opening balances and account transfer direction clear.
- Do not hide negative balances or failed saves.

### 10.3 Accessibility

- Provide semantic labels for icons and charts.
- Support dynamic text scaling.
- Maintain adequate contrast in both themes.
- Use keyboard navigation and focus order on desktop.
- Ensure important status is conveyed through text/icons as well as color.

## 11. Localization and formatting

- Initial UI languages: Bengali (`bn`) and English (`en`).
- Keep display text in localization resources; do not hardcode user-facing strings in widgets.
- Store canonical numeric values, not formatted currency strings.
- Format amounts only at the presentation boundary.
- Keep database timestamps in UTC and render them in the device's local timezone.
- Define whether the app follows the device locale or an explicit in-app language preference.

## 12. Backup and restore

A useful offline app needs a safe way to move or recover local data.

### 12.1 Export

- Export a versioned archive containing database data and a manifest.
- Include schema/export format version, app version and export timestamp.
- Validate relationships and record counts before declaring export successful.
- Do not include logs, secrets or unrelated device data.
- Do not claim a backup is encrypted unless encryption is actually implemented and tested.

### 12.2 Restore

- Validate archive structure, size, version and data before replacing current records.
- Show the user what will be replaced.
- Require explicit confirmation before destructive restore.
- Restore inside a controlled database transaction or a temporary database swap.
- Keep a recovery path if restore fails.
- Test malformed, truncated, old-version and oversized backup files.

### 12.3 Encryption

Before adding encrypted backups, choose a reviewed authenticated-encryption design and a key recovery strategy. Store key material using platform-backed secure storage. A local PIN or biometric prompt alone does not encrypt the database or backup file.

## 13. Rust core design

### 13.1 Purpose

The Rust crate `dailyhisab_core` is reserved for pure, deterministic logic that may be reused across native platforms or benefit from Rust's performance and safety characteristics.

Potential modules:

- `money.rs`: checked arithmetic helpers over integer minor units.
- `aggregation.rs`: batch period/category aggregation over input records.
- `validation.rs`: domain-level validation that is intentionally shared across native clients.
- `error.rs`: stable error types suitable for conversion through the bridge.

Do not use Rust merely to calculate `income - expense` for a small list if Dart already handles it clearly and safely. Benchmark and document the reason before moving a function into Rust.

### 13.2 Crate baseline

A minimal starting `Cargo.toml` can be:

```toml
[package]
name = "dailyhisab_core"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["lib", "cdylib", "staticlib"]

[dependencies]
thiserror = "2"

[dev-dependencies]
proptest = "1"
```

Treat this as a starting point, not a pinned dependency prescription. Add Serde or other crates only when the API actually requires serialization. Do not add Tokio unless the Rust core has real asynchronous I/O or task-runtime needs; pure calculation functions do not need an async runtime.

### 13.3 Rust API rules

- Accept integer minor units (`i64`), never floating-point currency values.
- Use checked arithmetic and return errors for overflow/invalid input.
- Avoid panics across an FFI boundary.
- Keep public bridge functions small and stable.
- Batch inputs to avoid excessive Dart↔Rust round trips.
- Keep database and UI details out of the Rust crate.
- Unit-test Rust independently from Flutter.

### 13.4 Bridge integration

Use `flutter_rust_bridge` 2.x when the Rust functions are ready to expose. Generate bindings using the currently documented workflow and keep the Rust crate, bridge runtime, code generator and Flutter/Dart SDK mutually compatible.

Conceptual call flow:

```text
Dart use case
    -> RustCore interface
        -> generated flutter_rust_bridge binding
            -> Rust public API
                -> pure calculation function
```

The rest of the app should depend on a Dart interface, not generated bridge classes directly. This makes it possible to use a Dart implementation in tests or disable the Rust adapter on a target where it is not configured.

## 14. Future cloud synchronization

Cloud sync is explicitly out of scope for v1. Keep repository interfaces clean so a remote sync layer can be added later without changing presentation code.

Potential future server stack:

| Component | Planned technology |
|---|---|
| API language | Rust |
| HTTP framework | Axum |
| Async runtime | Tokio, if required by server workload |
| Database | PostgreSQL |
| Database access | SQLx or another reviewed Rust data layer |
| API style | HTTPS REST / JSON |

Before implementing sync, define:

- User identity and authentication provider.
- Device identity and multi-device behavior.
- Stable IDs and record ownership.
- Revision/version model.
- Conflict-resolution policy.
- Idempotency keys for retryable requests.
- Deletion tombstones and retention policy.
- Retry/backoff and offline queue behavior.
- Encryption in transit and data protection at rest.
- Export, account deletion and recovery behavior.

Do not assume that a later `updated_at` timestamp is sufficient to resolve every conflict.

## 15. Security and privacy

### 15.1 v1 baseline

- No analytics or crash-reporting SDK by default.
- No network calls required for the core finance experience.
- Validate all form and imported data at the application boundary.
- Use parameterized SQL / Drift query APIs.
- Keep user notes and monetary data out of diagnostic logs.
- Do not commit signing keys, private credentials or local backups.
- Request the minimum platform permissions required.
- Review each plugin's data practices and platform support.

### 15.2 Local data protection

SQLite is local storage, not automatically an encrypted vault. Document the actual protection model. If database encryption is introduced, select a maintained implementation, handle key lifecycle safely, and test backup/restore compatibility. Do not create a homemade cryptographic format.

### 15.3 App lock

PIN or biometric protection may reduce casual access, but it must not be described as database encryption. Use platform authentication APIs and a secure storage mechanism for any secret material. Provide a clear recovery model.

### 15.4 Rust safety

- Avoid `unsafe` unless there is a documented, necessary reason.
- Keep unsafe blocks small and explain their invariants.
- Validate all data crossing the bridge.
- Convert Rust errors to predictable Dart errors.
- Never let an unhandled panic unwind across FFI.
- Audit dependencies and keep the toolchain current.

## 16. Error handling and observability

Use typed application errors such as:

```text
AppError
├── ValidationError
├── NotFoundError
├── DatabaseError
├── BackupFormatError
├── PermissionError
└── PlatformIntegrationError
```

Guidelines:

- Present understandable messages to users.
- Keep technical details in debug diagnostics only.
- Never log monetary notes or private financial records.
- Distinguish a failed save from a successful save followed by a failed screen refresh.
- Do not swallow database or restore errors.

## 17. Testing strategy

### 17.1 Dart unit tests

- Decimal input to integer poisha conversion.
- Amount validation and overflow boundaries.
- Income, expense and transfer balance behavior.
- Budget spent/remaining calculations.
- Date-range and month-boundary behavior.
- Repository and use-case logic.
- Backup format validation.

### 17.2 Database tests

- Fresh schema creation.
- Upgrade migrations from every supported schema version.
- Foreign-key behavior.
- Unique budget constraints.
- Transaction atomicity.
- Account archive behavior.
- Soft-delete and recovery behavior.

### 17.3 Widget and integration tests

- Add and edit transaction flows.
- Validation errors and cancelled actions.
- Dashboard totals after transaction changes.
- Search/filter combinations.
- Offline cold start and persistent data after restart.
- Backup export and restore.
- Theme and localization switching.

### 17.4 Rust tests

- Integer arithmetic and overflow.
- Property-based tests for aggregation invariants.
- Invalid input handling.
- Boundary and empty-input behavior.
- Bridge-level tests for public API conversion.

### 17.5 Critical accounting test cases

1. Opening balance `৳1,000.00` + income `৳250.00` = `৳1,250.00`.
2. Then expense `৳125.50` = `৳1,124.50`.
3. Transfer `৳100.00` from Wallet A to Bank B decreases A and increases B by exactly the same amount.
4. Sum of all same-currency account balances is unchanged by a transfer.
5. A rejected/failed transaction write changes neither account balance nor transaction history.
6. Values near the supported integer limit fail safely rather than wrapping.

## 18. Performance guidelines

- Use lazy lists for long transaction histories.
- Paginate or load more history when appropriate.
- Keep expensive database work out of widget build methods.
- Use Drift streams selectively; avoid watching the entire database from every screen.
- Use database indexes based on query plans.
- Profile in release/profile mode on representative Android hardware.
- Batch Rust calls for large calculations; do not cross FFI for every table row.
- Optimize only after measurement identifies a real bottleneck.

## 19. Platform strategy

### Stage 1 — Android

- Create Flutter Android runner and application ID.
- Implement local database and core finance flows.
- Test on a physical Android device as well as an emulator.
- Review storage, notification and backup behavior.
- Configure launcher icon, signing and release build only after QA.

### Stage 2 — iOS

- Build from macOS with Xcode.
- Add and validate iOS runner configuration.
- Review every plugin and permission for iOS support.
- Compile Rust for required iOS architectures if Rust integration is enabled.
- Test iPhone/iPad layout, accessibility, background behavior and local notifications.
- Configure Apple signing and App Store release requirements.

### Stage 3 — Windows

- Enable the Windows desktop runner on a Windows development environment.
- Install the required Visual Studio C++ desktop build tools.
- Adapt navigation and layout for keyboard, mouse and resizable windows.
- Validate local file paths, backup flow and installer/package format.

### Stage 4 — macOS

- Build on macOS with Xcode.
- Validate macOS runner and plugin compatibility.
- Adapt window behavior, menu/keyboard interactions and file access.
- Configure Apple signing and notarization where required for distribution.

### Stage 5 — Linux

- Enable Linux desktop dependencies and runner.
- Validate supported distributions and packaging formats.
- Test file permissions, application data paths and desktop integration.

### Optional Stage 6 — Web

Web is not a committed v1 target. If it becomes a requirement:

- Review Flutter Web constraints and browser storage behavior.
- Replace native-only plugins with web-compatible adapters.
- Treat browser persistence and user data export carefully.
- Compile Rust separately to WebAssembly where suitable; native dynamic libraries cannot be loaded directly by a browser.
- Verify Rust and bridge support for the specific Dart/Flutter web compilation mode being targeted.

A shared codebase does not mean every plugin, notification, backup path or background feature behaves the same across all targets.

## 20. Development setup

### 20.1 Environment checks

```bash
flutter doctor -v
flutter --version
dart --version
```

When Rust work begins:

```bash
rustc --version
cargo --version
rustup show
```

For Android, install Android Studio and the Android SDK, then accept licenses:

```bash
flutter doctor --android-licenses
```

### 20.2 Create the Android-first app

From the parent folder:

```bash
mkdir DailyHisab
cd DailyHisab
mkdir -p apps rust docs scripts
flutter create --org com.yourdomain --platforms android apps/mobile
```

Then:

```bash
cd apps/mobile
flutter pub get
flutter run
```

Replace `com.yourdomain` with a reverse-domain identifier you control. Do not use a placeholder application ID in a public release.

### 20.3 Add initial dependencies

From `apps/mobile`:

```bash
flutter pub add flutter_riverpod go_router
flutter pub add drift drift_flutter path_provider path
flutter pub add intl
flutter pub add --dev build_runner drift_dev flutter_lints mocktail
```

Optional feature packages should be added only when implemented:

```bash
flutter pub add fl_chart
flutter pub add flutter_local_notifications
```

Re-check package platform support, maintenance status and license before adoption.

### 20.4 Create Rust crate later

From repository root:

```bash
cargo new rust/dailyhisab_core --lib
cd rust/dailyhisab_core
cargo check
cargo test
```

Add a Rust/Dart bridge after a small, stable Rust API exists. Use the current `flutter_rust_bridge` quickstart and generated integration rather than copying legacy manual FFI instructions.

## 21. CI/CD

### Flutter CI

On every pull request:

1. Install a pinned Flutter stable toolchain for reproducibility.
2. Run `flutter pub get`.
3. Run `dart format --output=none --set-exit-if-changed .`.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Run database migration tests.

### Rust CI

When the Rust crate exists:

1. Install the selected stable Rust toolchain.
2. Run `cargo fmt --check`.
3. Run `cargo clippy --all-targets --all-features -- -D warnings`.
4. Run `cargo test`.

### Release pipeline

- Trigger release builds from an approved release tag or manual protected workflow.
- Keep signing keys and credentials in encrypted CI secrets or a secure local environment.
- Never commit keystores, certificates, provisioning profiles or passwords.
- Upload build artifacts for review before publishing.
- Do not automatically publish to an app store without an explicit release approval process.

## 22. Release checklist

### Product and data

- [ ] Core income/expense flows work offline.
- [ ] Account balances reconcile against transaction history.
- [ ] Transfer invariants pass automated tests.
- [ ] BDT input and display are correct for Bengali and English locales.
- [ ] Database migration and backup/restore tests pass.
- [ ] Empty, loading and error states are handled.

### Security and privacy

- [ ] Permission list reviewed and minimized.
- [ ] No sensitive values in logs.
- [ ] Backup protection and limitations documented.
- [ ] Data handling/privacy disclosures reviewed.
- [ ] Dependencies and licenses reviewed.

### Android release

- [ ] Final application ID and app name configured.
- [ ] Version number and launcher assets configured.
- [ ] Release signing configured securely.
- [ ] Physical-device QA completed.
- [ ] Store listing, screenshots and policy declarations completed.

## 23. Definition of done

A feature is done only when:

- The behavior and acceptance criteria are documented.
- UI has loading, empty, success and failure states where relevant.
- Domain rules are outside widgets.
- Data writes are atomic and validated.
- Database changes include migrations.
- Offline behavior is tested.
- Unit/widget/integration tests appropriate to the feature pass.
- Accessibility and localization are reviewed.
- Flutter analysis passes; Rust checks pass when Rust is involved.
- The feature works on the target platform/device.

## 24. Development roadmap

| Phase | Deliverable | Exit criteria |
|---|---|---|
| 0. Foundation | Repository, Flutter app, linting and CI baseline | App boots on Android; checks run in CI |
| 1. Design system | Material 3 theme, navigation, reusable components | Light/dark theme and responsive shell work |
| 2. Local data | Drift schema, migrations, repositories, seed categories | Database tests pass; data survives restart |
| 3. Finance MVP | Accounts, income, expense and transfers | Balance invariants pass; flows work offline |
| 4. Useful insights | Dashboard, budgets, search and basic reports | Totals reconcile with transaction data |
| 5. Recovery and quality | Backup/restore, localization, accessibility, hardening | Restore and localization tests pass |
| 6. Android release | Signed Android release and store preparation | Physical-device QA and release checklist complete |
| 7. Rust integration | Rust core + generated bridge, only if justified | Cross-language tests and target builds pass |
| 8. iOS | iOS runner and App Store readiness | Xcode build and real-device QA pass |
| 9. Desktop | Windows, macOS and Linux runners | Platform-specific QA and packaging pass |
| 10. Cloud sync (future) | Auth, API, server DB and conflict-safe sync | Sync/security design approved and tested |

## 25. Architecture decision records

Keep important decisions in `docs/adr/`. Each ADR should contain:

- Context: the problem and constraints.
- Decision: what was chosen.
- Alternatives: credible options considered.
- Consequences: trade-offs and migration impact.

Initial ADRs:

1. Flutter as the cross-platform UI framework.
2. SQLite + Drift as the offline-first persistence layer.
3. Integer poisha as the money storage representation.
4. Rust as an optional isolated native core, not the UI or database layer.

## 26. Final architecture summary

| Concern | Final decision |
|---|---|
| Product name | DailyHisab |
| Product scope v1 | Personal finance: income, expenses, accounts, budgets and summaries |
| Primary currency | BDT, stored as integer poisha |
| Initial platform | Android |
| Future platforms | iOS, Windows, macOS, Linux |
| UI | Flutter + Material 3 |
| Main language | Dart |
| State management | Riverpod |
| Navigation | GoRouter |
| Local database | SQLite + Drift |
| Native core | Rust, selectively and behind an interface |
| Rust/Dart bridge | flutter_rust_bridge 2.x, when implemented |
| Backend v1 | None |
| Future backend | Rust + Axum + PostgreSQL, subject to a later design decision |
| Architecture | Feature-first layered / Clean Architecture |
| Delivery | Automated checks, staged platform releases and manual approval |

**Guiding rule:** Build a dependable Android finance app first. Keep Flutter/Dart responsible for the product experience, SQLite responsible for local persistence, and Rust reserved for well-defined shared native logic. Expand one platform at a time and prove each release with tests.
