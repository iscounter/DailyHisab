Daily Tips — Production Project Architecture

Project Type: Cross-platform application
Architecture: Flutter + Dart + Rust
Initial Platform: Android
Future Platforms: iOS, Windows, macOS, Linux
Backend: None initially; cloud-ready architecture
Database: SQLite
Rust Integration: flutter_rust_bridge
Architecture Style: Feature-first, Clean Architecture, Modular Monorepo
Development Approach: Offline-first, test-driven, platform-independent core

1. Project Vision

Build a modern, scalable, high-performance Daily Tips application using Flutter, Dart and Rust.

The application must:

Work completely offline.
Have a modern, responsive user interface.
Support Android initially.
Be ready for future iOS and desktop releases.
Use Rust for reusable business logic and performance-intensive operations.
Use Dart for application logic and UI orchestration.
Use SQLite for local persistent storage.
Support future cloud synchronization without redesigning the application.
Have maintainable, testable and modular architecture.
1.1 Core Principles
Offline-first.
Feature-first architecture.
Separation of concerns.
Type safety.
Memory safety.
Dependency injection.
Repository pattern.
Immutable state where practical.
Platform independence.
Automated testing and CI/CD.
Secure local storage.
Backward-compatible database migrations.
2. Technology Stack
2.1 Main Programming Languages
Language	Responsibility
Dart	Application logic and UI orchestration
Rust	Shared business logic and native processing
SQL	Local database queries
YAML	Configuration and dependency management
JSON	Serialization and data interchange
Bash / PowerShell	Development automation
2.2 Frontend
Technology	Purpose
Flutter	Cross-platform UI framework
Dart	Main application language
Material 3	Design system
Riverpod	State management and dependency injection
GoRouter	Navigation and routing
Freezed	Immutable models and unions
json_serializable	JSON serialization
2.3 Rust Core
Technology	Purpose
Rust	Native shared core
Cargo	Package and build manager
flutter_rust_bridge	Dart-Rust communication
Tokio	Asynchronous runtime when needed
Serde	Serialization and deserialization
Thiserror	Structured error definitions
Tracing	Structured diagnostics
UUID	Stable identifiers

Avoid adding unnecessary Rust dependencies. Prefer the standard library where appropriate.

2.4 Database
Technology	Purpose
SQLite	Local database
Drift	Type-safe Dart database layer
SQL migrations	Database version management
SQLite FTS5	Full-text search, where supported
2.5 Development Tools
Flutter SDK
Dart SDK (bundled with Flutter)
Rust stable toolchain
Android Studio
Visual Studio Code
Rust Analyzer
Git
GitHub
Android SDK
Xcode for future iOS builds
Visual Studio C++ build tools for Windows desktop builds
3. High-Level Architecture
text
                  USER
                   |
                   v
          FLUTTER PRESENTATION
                   |
             DART APPLICATION
                   |
          +--------+---------+
          |                  |
          v                  v
    LOCAL DATA LAYER     RUST CORE
          |                  |
          v                  v
       SQLITE             RUST LOGIC
          |                  |
          +--------+---------+
                   |
             APPLICATION API
                   |
           FUTURE CLOUD SYNC
                   |
             FUTURE BACKEND

3.1 Architecture Responsibilities
Flutter

Responsible for:

Screens
Widgets
Responsive layouts
Themes
Animations
Navigation
Accessibility
Platform presentation
Dart

Responsible for:

Application use cases
State management
Repository interfaces
Repository implementations
Local database integration
Notifications
API communication
Dependency injection
Data validation
Rust

Responsible for:

Shared domain algorithms
Advanced text processing
Search ranking
Complex filtering
Data transformations
Performance-intensive operations
Portable domain functionality
SQLite

Responsible for:

Tips
Categories
Favorites
User preferences
Reading history
Local content metadata

Important: Dart owns the application workflow. Rust owns only the functionality that benefits from a shared native implementation or measurable performance improvement.

Do not duplicate the same business logic in Dart and Rust.

4. Monorepo Folder Structure

Use a modular monorepo.

text
daily_tips/
│
├── apps/
│   │
│   └── mobile/
│       │
│       ├── android/
│       ├── ios/
│       ├── windows/
│       ├── macos/
│       ├── linux/
│       ├── web/
│       │
│       ├── lib/
│       │   │
│       │   ├── main.dart
│       │   │
│       │   ├── bootstrap/
│       │   │   ├── bootstrap.dart
│       │   │   ├── initialization.dart
│       │   │   └── error_handler.dart
│       │   │
│       │   ├── app/
│       │   │   ├── app.dart
│       │   │   ├── app_theme.dart
│       │   │   ├── app_router.dart
│       │   │   └── app_providers.dart
│       │   │
│       │   ├── core/
│       │   │   ├── constants/
│       │   │   ├── errors/
│       │   │   ├── extensions/
│       │   │   ├── logging/
│       │   │   ├── network/
│       │   │   ├── platform/
│       │   │   ├── security/
│       │   │   ├── storage/
│       │   │   ├── utils/
│       │   │   └── widgets/
│       │   │
│       │   ├── features/
│       │   │   │
│       │   │   ├── home/
│       │   │   │   ├── data/
│       │   │   │   ├── domain/
│       │   │   │   └── presentation/
│       │   │   │
│       │   │   ├── tips/
│       │   │   │   ├── data/
│       │   │   │   ├── domain/
│       │   │   │   └── presentation/
│       │   │   │
│       │   │   ├── categories/
│       │   │   ├── favorites/
│       │   │   ├── search/
│       │   │   ├── history/
│       │   │   ├── notifications/
│       │   │   ├── settings/
│       │   │   └── onboarding/
│       │   │
│       │   ├── generated/
│       │   │
│       │   └── l10n/
│       │
│       ├── test/
│       ├── integration_test/
│       ├── assets/
│       │   ├── images/
│       │   ├── icons/
│       │   ├── fonts/
│       │   └── translations/
│       │
│       └── pubspec.yaml
│
├── packages/
│   │
│   ├── design_system/
│   ├── shared_models/
│   ├── local_database/
│   └── app_utilities/
│
├── rust/
│   │
│   └── daily_tips_core/
│       │
│       ├── Cargo.toml
│       ├── Cargo.lock
│       │
│       ├── src/
│       │   ├── lib.rs
│       │   │
│       │   ├── api/
│       │   │   ├── mod.rs
│       │   │   ├── tips_api.rs
│       │   │   └── search_api.rs
│       │   │
│       │   ├── domain/
│       │   │   ├── mod.rs
│       │   │   ├── tip.rs
│       │   │   ├── category.rs
│       │   │   └── favorite.rs
│       │   │
│       │   ├── services/
│       │   │   ├── mod.rs
│       │   │   ├── search.rs
│       │   │   └── recommendation.rs
│       │   │
│       │   ├── errors/
│       │   │   ├── mod.rs
│       │   │   └── core_error.rs
│       │   │
│       │   └── utils/
│       │       ├── mod.rs
│       │       └── text.rs
│       │
│       ├── tests/
│       └── benches/
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── RUST_INTEGRATION.md
│   ├── SECURITY.md
│   ├── DEPLOYMENT.md
│   └── CONTRIBUTING.md
│
├── scripts/
│   ├── setup.sh
│   ├── generate_bridge.sh
│   ├── test.sh
│   └── release.sh
│
├── .github/
│   └── workflows/
│       ├── flutter_ci.yml
│       ├── rust_ci.yml
│       └── android_release.yml
│
├── .gitignore
├── .editorconfig
├── .env.example
├── LICENSE
├── README.md
└── PROJECT_ARCHITECTURE.md


This structure is designed for gradual growth. Do not create every package immediately; introduce modules when they have real responsibilities.

5. Flutter Dependencies

Add dependencies based on actual requirements.

Core dependencies
bash
flutter pub add flutter_riverpod
flutter pub add go_router
flutter pub add freezed_annotation
flutter pub add json_annotation

Database
bash
flutter pub add drift
flutter pub add sqlite3_flutter_libs
flutter pub add path_provider
flutter pub add path

Networking
bash
flutter pub add dio
flutter pub add connectivity_plus


Connectivity status is only a hint. Always handle actual network request failures.

Local preferences
bash
flutter pub add shared_preferences


Use it for simple preferences, not as a replacement for the main database.

Notifications
bash
flutter pub add flutter_local_notifications

Internationalization

Use Flutter's built-in localization tools:

bash
flutter pub add flutter_localizations --sdk flutter
flutter pub add intl

UI and utilities
bash
flutter pub add cached_network_image
flutter pub add flutter_svg
flutter pub add package_info_plus
flutter pub add device_info_plus
flutter pub add uuid

Development dependencies
bash
flutter pub add --dev build_runner
flutter pub add --dev freezed
flutter pub add --dev json_serializable
flutter pub add --dev drift_dev
flutter pub add --dev flutter_lints
flutter pub add --dev mocktail


Use the current stable compatible versions resolved by Pub. Commit pubspec.lock for the application.

6. Rust Dependencies

Example rust/daily_tips_core/Cargo.toml:

toml
[package]
name = "daily_tips_core"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["lib", "cdylib", "staticlib"]

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
thiserror = "2"
tracing = "0.1"
uuid = { version = "1", features = ["v4", "serde"] }

[dev-dependencies]
proptest = "1"
criterion = "0.7"


Add the bridge generator and runtime versions according to the flutter_rust_bridge documentation and keep them compatible.

Do not add Tokio unless you actually need asynchronous Rust tasks.

Rust module responsibilities
Module	Responsibility
api	Dart-facing API
domain	Core business models
services	Search and recommendation logic
errors	Structured error types
utils	Shared utilities
tests	Unit and integration tests
benches	Performance benchmarks
7. Rust and Flutter Communication

Use flutter_rust_bridge.

Documentation:

https://cjycode.com/flutter_rust_bridge/

The bridge should expose a small, stable API.

Example Rust function:

rust
pub fn normalize_tip_text(input: String) -> String {
    input.trim().to_string()
}


Expose this through the generated bridge API rather than manually maintaining native bindings.

Example Dart usage:

dart
final normalized = await api.normalizeTipText(
  input: rawText,
);


The generated API names depend on your bridge configuration.

Integration rules
Keep bridge functions small.
Do not expose internal Rust implementation details.
Convert Rust errors into predictable application errors.
Avoid excessive Dart-Rust calls.
Batch operations when appropriate.
Never block the UI thread with expensive synchronous work.
Test Rust independently of Flutter.
Regenerate bridge bindings after changing public Rust APIs.

For web, plan a separate WebAssembly integration. Native FFI libraries cannot simply be reused in a browser.

8. Application Architecture

Use Clean Architecture with feature-first organization.

Each feature has three layers.

Presentation

Contains:

Pages
Widgets
Providers
UI state
User interactions
Domain

Contains:

Entities
Repository interfaces
Use cases
Business rules
Data

Contains:

Repository implementations
Database queries
DTOs
Data sources
Mappers

Example:

text
features/tips/

├── presentation/
│   ├── pages/
│   │   └── tips_page.dart
│   ├── widgets/
│   └── providers/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── data/
    ├── datasources/
    ├── models/
    ├── repositories/
    └── mappers/


The domain layer should not depend on Flutter, SQLite, Riverpod or Rust bridge implementation details.

9. Database Architecture

Use SQLite with Drift.

The initial application must work without an internet connection.

9.1 Database Tables
tips
Column	Type	Description
id	TEXT	Primary key
title	TEXT	Tip title
content	TEXT	Tip content
category_id	TEXT	Category reference
language_code	TEXT	Content language
created_at	INTEGER	Creation timestamp
updated_at	INTEGER	Update timestamp
is_active	INTEGER	Active status
categories
Column	Type	Description
id	TEXT	Primary key
name	TEXT	Category name
description	TEXT	Description
icon	TEXT	Icon identifier
sort_order	INTEGER	Display order
favorites
Column	Type	Description
id	TEXT	Primary key
tip_id	TEXT	Tip reference
created_at	INTEGER	Favorite timestamp
reading_history
Column	Type	Description
id	TEXT	Primary key
tip_id	TEXT	Tip reference
viewed_at	INTEGER	Last viewed time
app_settings
Column	Type	Description
key	TEXT	Primary key
value	TEXT	Setting value
updated_at	INTEGER	Last updated
content_sync_metadata

Reserve this table for future synchronization.

Column	Type	Description
entity_type	TEXT	Entity category
entity_id	TEXT	Entity identifier
updated_at	INTEGER	Last modification
sync_status	TEXT	Pending / synced / conflict
revision	INTEGER	Content revision

Do not implement a cloud sync engine until a backend exists.

9.2 SQL Schema
sql
PRAGMA foreign_keys = ON;

CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE tips (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category_id TEXT,
    language_code TEXT NOT NULL DEFAULT 'en',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,

    FOREIGN KEY(category_id)
        REFERENCES categories(id)
        ON DELETE SET NULL
);

CREATE INDEX idx_tips_category
ON tips(category_id);

CREATE INDEX idx_tips_updated
ON tips(updated_at);

CREATE TABLE favorites (
    id TEXT PRIMARY KEY,
    tip_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,

    UNIQUE(tip_id),

    FOREIGN KEY(tip_id)
        REFERENCES tips(id)
        ON DELETE CASCADE
);

CREATE TABLE reading_history (
    id TEXT PRIMARY KEY,
    tip_id TEXT NOT NULL,
    viewed_at INTEGER NOT NULL,

    FOREIGN KEY(tip_id)
        REFERENCES tips(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_history_viewed
ON reading_history(viewed_at);

CREATE TABLE app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at INTEGER NOT NULL
);


For Drift, implement these tables as typed Dart table definitions and manage schema changes with explicit migrations.

Store timestamps in UTC. Use local timezone conversion only for presentation and daily notification scheduling.

10. State Management

Use Riverpod.

Recommended separation:

text
UI
 |
 v
Riverpod Provider
 |
 v
Use Case
 |
 v
Repository Interface
 |
 v
Repository Implementation
 |
 +------> Drift Database
 |
 +------> Rust Bridge


Example:

dart
final tipsProvider = FutureProvider((ref) async {
  final repository = ref.watch(tipsRepositoryProvider);
  return repository.getDailyTips();
});


Keep providers focused. Avoid placing database queries or complex business rules directly inside widgets.

11. Navigation

Use GoRouter.

Suggested routes:

text
/
├── onboarding
├── home
├── tips
│   └── :id
├── categories
│   └── :id
├── favorites
├── search
├── history
└── settings


Support deep links from the beginning, even if external links are introduced later.

12. Design System

Use Material 3 with a custom design system.

Theme
Light theme
Dark theme
System theme
Dynamic color where supported
Consistent typography
Consistent spacing
Accessible contrast
Design tokens
text
design_system/

├── colors/
├── typography/
├── spacing/
├── radius/
├── shadows/
├── components/
│   ├── app_button.dart
│   ├── app_card.dart
│   ├── app_dialog.dart
│   ├── app_text_field.dart
│   └── app_loading.dart
└── theme/


Avoid hardcoding colors and spacing throughout the application.

13. Offline-First Strategy

SQLite is the source of truth for application content.

Initial data flow:

text
User Action
    |
    v
Application Use Case
    |
    v
Repository
    |
    v
SQLite Database
    |
    v
Riverpod State
    |
    v
Flutter UI


Benefits:

No internet requirement.
Fast content loading.
Persistent favorites.
Search without a network.
Reliable application behavior.

When cloud support is added:

text
Local Database
      |
      v
Sync Engine
      |
      v
Backend API
      |
      v
Cloud Database


Future sync requirements:

Stable UUID identifiers.
Revision tracking.
Conflict resolution.
Retry with exponential backoff.
Idempotent requests.
Deletion tombstones.
Last successful sync timestamp.

Never assume that the newest timestamp alone resolves every data conflict.

14. Security Architecture

Security should be included from the beginning.

Application security
Validate user inputs.
Use parameterized SQL queries.
Avoid logging private information.
Keep secrets out of source control.
Use HTTPS for future APIs.
Keep dependencies updated.
Apply least-privilege permissions.
Use secure storage for future credentials.
Avoid storing authentication tokens in ordinary preferences.
Use platform-supported backup and encryption policies.
Rust security
Avoid unsafe Rust unless necessary.
Keep unsafe blocks small and documented.
Validate FFI inputs.
Handle errors explicitly.
Avoid panics crossing FFI boundaries.
Audit third-party crates.

Rust memory safety does not replace application-level security.

15. Error Handling and Logging

Use structured errors.

Dart:

text
AppError
├── DatabaseError
├── ValidationError
├── NetworkError
├── StorageError
└── PlatformError


Rust:

rust
use thiserror::Error;

#[derive(Debug, Error)]
pub enum CoreError {
    #[error("Invalid input")]
    InvalidInput,

    #[error("Processing failed")]
    ProcessingFailed,
}


Logging:

Use structured logs.
Separate debug and release logging.
Never log passwords, tokens or private content.
Add crash reporting only after choosing a privacy-appropriate provider.
16. Testing Strategy
Dart tests
Unit tests
Widget tests
Repository tests
Provider tests
Database migration tests
Rust tests
Unit tests
Integration tests
Property-based tests
Error-handling tests
Benchmark tests
Application tests
Offline behavior
Favorites persistence
Search
Notifications
Database upgrades
App startup
Platform integration

Recommended commands:

bash
flutter analyze
flutter test

cd rust/daily_tips_core
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test


Add integration tests for important end-to-end user journeys.

17. Performance Strategy
Flutter
Use const widgets where possible.
Avoid unnecessary rebuilds.
Use lazy lists.
Paginate large datasets.
Profile in release or profile mode.
Avoid expensive work in build methods.
Dart
Use isolates for CPU-intensive Dart workloads.
Use asynchronous database operations.
Avoid excessive serialization.
Rust
Benchmark before optimizing.
Minimize FFI calls.
Batch processing.
Avoid unnecessary allocations.
Use efficient algorithms.
Avoid unnecessary thread creation.

Performance should be measured rather than assumed.

18. Platform Strategy
Phase 1: Android

Initial release:

Android application
SQLite storage
Offline content
Favorites
Search
Notifications
Rust integration
Android permissions
Release APK/AAB
Phase 2: iOS

Requirements:

macOS development machine
Xcode
iOS Rust compilation targets
iOS native plugin configuration
iPhone and iPad testing
App Store signing
Phase 3: Desktop
Windows
Windows desktop runner
MSVC build tools
Native library compilation
Window resizing and keyboard support
macOS
macOS runner
Xcode
Apple signing and notarization
Linux
Linux desktop dependencies
Native library compilation
Package distribution

Desktop layouts should adapt to large screens rather than simply stretching mobile screens.

Phase 4: Web (Optional)

Web requires additional engineering:

Flutter Web
Web-compatible persistence
Rust compiled to WebAssembly
Browser-specific integration
Web security restrictions

Do not assume the native Rust FFI implementation works in a browser.

19. Project Setup Commands
Install Flutter

Follow:

https://docs.flutter.dev/get-started/install

Verify:

bash
flutter doctor -v
flutter --version
dart --version

Install Rust

Follow:

https://www.rust-lang.org/tools/install

Verify:

bash
rustc --version
cargo --version
rustup show

Install Android requirements

Install Android Studio and the Android SDK.

Accept licenses:

bash
flutter doctor --android-licenses

Create the project
bash
mkdir daily_tips
cd daily_tips

mkdir apps packages rust docs scripts

flutter create \
  --org com.example \
  --platforms android,ios,windows,macos,linux \
  apps/mobile


Replace com.example with your own reverse-domain application identifier before release.

Create Rust core
bash
cargo new rust/daily_tips_core --lib

Run Flutter
bash
cd apps/mobile

flutter pub get
flutter run

Run Rust

From the repository root:

bash
cd rust/daily_tips_core

cargo check
cargo test

Initialize Rust integration

Follow the current flutter_rust_bridge setup guide:

https://cjycode.com/flutter_rust_bridge/

Configure the Rust crate, Dart package and generated bindings using the same compatible bridge version.

20. CI/CD Architecture

Use GitHub Actions.

Suggested workflows:

Flutter CI

On every pull request:

Install Flutter.
Resolve dependencies.
Run formatter checks.
Run static analysis.
Run unit tests.
Run widget tests.
Rust CI
Install stable Rust.
Run rustfmt.
Run Clippy.
Run Rust tests.
Build supported host targets.
Android Release
Trigger from a release tag.
Build Flutter release.
Compile and package Rust dependencies.
Sign the Android App Bundle.
Store the build artifact securely.
Publish to Google Play through a controlled release process.

Never commit signing keys or release credentials.

Example local release command:

bash
flutter build appbundle --release


For iOS:

bash
flutter build ipa --release


For Windows:

bash
flutter build windows --release


For macOS:

bash
flutter build macos --release


For Linux:

bash
flutter build linux --release


Build each target on a compatible host environment.

21. Release Management

Use semantic versioning:

text
MAJOR.MINOR.PATCH

1.0.0
1.0.1
1.1.0
2.0.0


Suggested release stages:

Development
Internal testing
Beta
Production
Maintenance

Use release notes and database migration testing for every production release.

22. Development Roadmap
Stage 1: Foundation
Initialize monorepo.
Configure Flutter.
Configure Rust.
Configure code formatting.
Configure Git.
Add CI.
Stage 2: Application Foundation
Configure Material 3.
Configure Riverpod.
Configure GoRouter.
Add design tokens.
Implement application bootstrap.
Stage 3: Local Data
Implement Drift.
Create database tables.
Add migrations.
Seed initial tips.
Implement repositories.
Stage 4: Core Features
Home screen.
Daily tips.
Categories.
Favorites.
Search.
Reading history.
Settings.
Stage 5: Rust Integration
Configure flutter_rust_bridge.
Add Rust domain functions.
Generate bindings.
Add integration tests.
Benchmark the Rust implementation.
Stage 6: Production Quality
Error handling.
Logging.
Accessibility.
Offline testing.
Database migration testing.
Performance profiling.
Security review.
Stage 7: Android Release
Configure app identifier.
Configure app icon.
Configure signing.
Generate release AAB.
Test on physical Android devices.
Publish to Google Play.
Stage 8: Platform Expansion
iOS.
Windows.
macOS.
Linux.
Optional Web.
23. Future Backend Architecture

Do not build a backend in version 1.

Keep the application ready for a future backend using repository interfaces.

Potential future stack:

Component	Technology
Backend language	Rust
Web framework	Axum
Async runtime	Tokio
Database	PostgreSQL
Database access	SQLx
Authentication	OIDC-compatible provider
API	REST
Serialization	Serde
Deployment	Container-based hosting

Future architecture:

text
Flutter + Dart
      |
      v
Application Repository
      |
      v
Sync Service
      |
      v
HTTPS REST API
      |
      v
Rust + Axum
      |
      v
PostgreSQL


This is a future phase, not a version 1 requirement.

24. Dependency Management Policy

Follow these rules:

Prefer stable releases.
Avoid unnecessary dependencies.
Commit Flutter application lockfiles.
Commit Rust Cargo.lock.
Review breaking changes before upgrades.
Update dependencies in controlled batches.
Run tests after upgrades.
Audit Rust dependencies.
Review package licenses.
Document important dependency decisions.

Do not blindly use the newest version of every dependency. Use the newest mutually compatible stable versions at the time of implementation.

25. Architecture Decision Records

Keep important architectural decisions in:

text
docs/adr/

001-flutter-frontend.md
002-rust-shared-core.md
003-offline-first-storage.md
004-drift-database.md
005-rust-bridge.md
006-future-cloud-sync.md


Each record should explain:

Context
Decision
Alternatives
Consequences

This prevents architecture decisions from becoming undocumented assumptions.

26. Definition of Done

A feature is ready when:

Its requirements are documented.
Its UI is implemented.
Its business logic is separated from UI.
Its repository is tested.
Database changes have migrations.
Offline behavior works.
Errors are handled.
Accessibility has been checked.
Flutter analysis passes.
Rust tests pass where relevant.
The feature works on the target Android devices.
27. Final Technology Decisions
Layer	Final choice
Primary UI	Flutter
Main language	Dart
Native shared core	Rust
Rust bridge	flutter_rust_bridge
State management	Riverpod
Routing	GoRouter
Architecture	Feature-first Clean Architecture
Database	SQLite
Database toolkit	Drift
Serialization	Freezed + json_serializable
Search	SQLite FTS5 where available
Preferences	SharedPreferences
Notifications	flutter_local_notifications
Backend initially	None
Future backend	Rust + Axum
Future cloud database	PostgreSQL
Version control	Git
Repository hosting	GitHub
CI/CD	GitHub Actions
Android release	Google Play AAB
iOS release	App Store
Desktop release	Native desktop packages
28. Final Architecture Philosophy

The goal is not to use as many programming languages and frameworks as possible.

The goal is to build a stable, maintainable and extensible application.

Flutter and Dart should own the application experience.

Rust should provide shared native functionality where it offers real value.

SQLite should make the application reliable without internet access.

A future Rust backend should provide cloud synchronization when the product actually needs it.

Start with Android, establish a strong architecture, and expand platform by platform.

Build once, share intelligently, test everywhere, and optimize only when needed.
