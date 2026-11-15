# Build & run (DailyHisab)

## Prerequisites
- Flutter SDK (stable, Dart >=3.3) matching `apps/mobile/pubspec.yaml`
- Rust stable (for `rust/dailyhisab_core`)
- Android Studio + SDK for Android runs

## Flutter app
```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

If `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` folders are missing under `apps/mobile`, generate them:
```bash
cd apps/mobile
flutter create . --org com.example --project-name dailyhisab
```
(Adjust org/package before release.)

## Rust core
```bash
cd rust/dailyhisab_core
cargo test
```

## Notes
- Drift generates `lib/data/drift/app_database.g.dart` via build_runner. Do not hand-edit generated files.
- Money: integer minor units (BDT poisha). No floating point for money math.
