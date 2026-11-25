import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';

const _uuid = Uuid();

class SavingsGoalsRepository {
  SavingsGoalsRepository(this._db);
  final AppDatabase _db;

  Stream<List<SavingsGoal>> watchAll() => (_db.select(_db.savingsGoals)
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();

  Future<List<SavingsGoal>> getAll() => (_db.select(_db.savingsGoals)
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();

  Future<void> create({required String name, required int targetMinor}) async {
    await _db.into(_db.savingsGoals).insert(SavingsGoalsCompanion.insert(
          id: _uuid.v4(),
          name: name,
          targetMinor: targetMinor,
          createdAt: DateTime.now(),
        ));
  }

  /// Add to the saved amount (never below zero).
  Future<void> addToSaved(String id, int amountMinor) async {
    final goal = await (_db.select(_db.savingsGoals)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (goal == null) return;
    final updated = (goal.savedMinor + amountMinor).clamp(0, 1 << 62).toInt();
    await (_db.update(_db.savingsGoals)..where((t) => t.id.equals(id))).write(
      SavingsGoalsCompanion(savedMinor: Value(updated)),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.savingsGoals)..where((t) => t.id.equals(id))).go();
  }
}
