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

  Future<List<Category>> getAll() => (_db.select(_db.categories)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<void> create({required String name, required TxnType type, String? iconKey}) async {
    await _db.into(_db.categories).insert(CategoriesCompanion.insert(
          id: _uuid.v4(),
          name: name,
          type: type,
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
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Salary', type: TxnType.income, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Freelance', type: TxnType.income, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Food', type: TxnType.expense, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Transport', type: TxnType.expense, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Bills', type: TxnType.expense, isDefault: const Value(true), createdAt: now),
        CategoriesCompanion.insert(id: _uuid.v4(), name: 'Shopping', type: TxnType.expense, isDefault: const Value(true), createdAt: now),
      ]);
    });
  }
}
