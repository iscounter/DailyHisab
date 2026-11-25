import 'package:drift/drift.dart';

import '../drift/app_database.dart';

/// Key/value app settings persisted in the `app_settings` table.
class AppSettingsRepository {
  AppSettingsRepository(this._db);
  final AppDatabase _db;

  Future<String?> get(String key) async {
    final row = await (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> remove(String key) async {
    await (_db.delete(_db.appSettings)..where((t) => t.key.equals(key))).go();
  }
}
