import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';

const _uuid = Uuid();

class AccountsRepository {
  AccountsRepository(this._db);
  final AppDatabase _db;

  Stream<List<Account>> watchAll() => (_db.select(_db.accounts)
        ..where((t) => t.isArchived.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<List<Account>> getAll() => (_db.select(_db.accounts)
        ..where((t) => t.isArchived.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  Future<void> create({required String name, required AccountKind kind}) async {
    await _db.into(_db.accounts).insert(AccountsCompanion.insert(
          id: _uuid.v4(),
          name: name,
          kind: kind,
          createdAt: DateTime.now(),
        ));
  }

  Future<void> archive(String id) async {
    await (_db.update(_db.accounts)..where((t) => t.id.equals(id))).write(
      const AccountsCompanion(isArchived: Value(true)),
    );
  }
}
