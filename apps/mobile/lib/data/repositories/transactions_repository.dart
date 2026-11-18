import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';

const _uuid = Uuid();

class TransactionsRepository {
  TransactionsRepository(this._db);
  final AppDatabase _db;

  Stream<List<Transaction>> watchRecent({int limit = 100}) {
    return (_db.select(_db.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
          ..limit(limit))
        .watch();
  }

  Future<int> sumIncomeMinor(DateTime from, DateTime to) async {
    final q = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amountMinor.sum()])
          ..where(_db.transactions.type.equalsValue(TxnType.income) &
              _db.transactions.occurredAt.isBetweenValues(from, to)))
        .getSingle();
    return q.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<int> sumExpenseMinor(DateTime from, DateTime to) async {
    final q = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amountMinor.sum()])
          ..where(_db.transactions.type.equalsValue(TxnType.expense) &
              _db.transactions.occurredAt.isBetweenValues(from, to)))
        .getSingle();
    return q.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<int> sumAllIncomeMinor() async {
    final q = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amountMinor.sum()])
          ..where(_db.transactions.type.equalsValue(TxnType.income)))
        .getSingle();
    return q.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<int> sumAllExpenseMinor() async {
    final q = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amountMinor.sum()])
          ..where(_db.transactions.type.equalsValue(TxnType.expense)))
        .getSingle();
    return q.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<void> add({
    required TxnType type,
    required int amountMinor,
    required String accountId,
    required String categoryId,
    required DateTime occurredAt,
    String note = '',
  }) async {
    if (amountMinor <= 0) throw ArgumentError('amountMinor must be > 0');
    await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
          id: _uuid.v4(),
          type: type,
          amountMinor: amountMinor,
          accountId: accountId,
          categoryId: categoryId,
          occurredAt: occurredAt,
          note: Value(note),
          createdAt: DateTime.now(),
        ));
  }

  Future<void> update({
    required String id,
    required TxnType type,
    required int amountMinor,
    required String accountId,
    required String categoryId,
    required DateTime occurredAt,
    String note = '',
  }) async {
    if (amountMinor <= 0) throw ArgumentError('amountMinor must be > 0');
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        type: Value(type),
        amountMinor: Value(amountMinor),
        accountId: Value(accountId),
        categoryId: Value(categoryId),
        occurredAt: Value(occurredAt),
        note: Value(note),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }
}