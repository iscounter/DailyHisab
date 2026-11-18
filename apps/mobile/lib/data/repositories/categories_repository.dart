import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';

const _uuid = Uuid();

class CategoriesRepository {
  CategoriesRepository(this._db);
  final AppDatabase _db;

  Stream<List<Category>> watchAll() => (_db.select(_db.categories)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<List<Category>> getAll() =>
      (_db.select(_db.categories)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<void> create({
    required String name,
    required CategoryKind kind,
    String? iconKey,
  }) async {
    await _db.into(_db.categories).insert(CategoriesCompanion.insert(
          id: _uuid.v4(),
          name: name,
          kind: kind,
          iconKey: Value(iconKey),
          createdAt: DateTime.now(),
        ));
  }

  Future<void> seedDefaultsIfEmpty() async {
    final existing = await _db.select(_db.categories).get();
    if (existing.isNotEmpty) return;
    final now = DateTime.now();
    await _db.batch((b) {
      b.insertAll(_db.categories, [
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Salary', kind: CategoryKind.income, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Freelance', kind: CategoryKind.income, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Food', kind: CategoryKind.expense, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Transport', kind: CategoryKind.expense, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Bills', kind: CategoryKind.expense, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Shopping', kind: CategoryKind.expense, isDefault: const Value(true), createdAt: now),
      ]);
    });
  }
}