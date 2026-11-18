import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';

const _uuid = Uuid();

class TransactionsRepository {
  TransactionsRepository(this._db);
  final AppDatabase _db;

  /// Recent, non-deleted transactions (newest first).
  Stream<List<Transaction>> watchRecent({int limit = 100}) {
    return (_db.select(_db.transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
          ..limit(limit))
        .watch();
  }

  Future<int> sumIncomeMinor(DateTime from, DateTime to) async {
    final q = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amountMinor.sum()])
          ..where(
              _db.transactions.kind.equalsValue(TxnKind.income) &
                  _db.transactions.deletedAt.isNull() &
                  _db.transactions.occurredAt.isBetweenValues(from, to)))
        .getSingle();
    return q.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<int> sumExpenseMinor(DateTime from, DateTime to) async {
    final q = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amountMinor.sum()])
          ..where(
              _db.transactions.kind.equalsValue(TxnKind.expense) &
                  _db.transactions.deletedAt.isNull() &
                  _db.transactions.occurredAt.isBetweenValues(from, to)))
        .getSingle();
    return q.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<int> sumAllIncomeMinor() async {
    final q = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amountMinor.sum()])
          ..where(_db.transactions.kind.equalsValue(TxnKind.income) &
              _db.transactions.deletedAt.isNull()))
        .getSingle();
    return q.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<int> sumAllExpenseMinor() async {
    final q = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amountMinor.sum()])
          ..where(_db.transactions.kind.equalsValue(TxnKind.expense) &
              _db.transactions.deletedAt.isNull()))
        .getSingle();
    return q.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<void> add({
    required TxnKind kind,
    required int amountMinor,
    String? fromAccountId,
    String? toAccountId,
    String? categoryId,
    required DateTime occurredAt,
    String note = '',
  }) async {
    if (amountMinor <= 0) throw ArgumentError('amountMinor must be > 0');
    if (kind == TxnKind.expense && fromAccountId == null) {
      throw ArgumentError('expense requires a source account');
    }
    if (kind == TxnKind.income && toAccountId == null) {
      throw ArgumentError('income requires a destination account');
    }
    if (kind == TxnKind.transfer) {
      if (fromAccountId == null || toAccountId == null) {
        throw ArgumentError('transfer requires both accounts');
      }
      if (fromAccountId == toAccountId) {
        throw ArgumentError('transfer accounts must differ');
      }
    }
    await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
          id: _uuid.v4(),
          kind: kind,
          amountMinor: amountMinor,
          fromAccountId: Value(fromAccountId),
          toAccountId: Value(toAccountId),
          categoryId: Value(categoryId),
          occurredAt: occurredAt,
          note: Value(note),
          createdAt: DateTime.now(),
        ));
  }

  Future<void> update({
    required String id,
    required TxnKind kind,
    required int amountMinor,
    String? fromAccountId,
    String? toAccountId,
    String? categoryId,
    required DateTime occurredAt,
    String note = '',
  }) async {
    if (amountMinor <= 0) throw ArgumentError('amountMinor must be > 0');
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        kind: Value(kind),
        amountMinor: Value(amountMinor),
        fromAccountId: Value(fromAccountId),
        toAccountId: Value(toAccountId),
        categoryId: Value(categoryId),
        occurredAt: Value(occurredAt),
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Soft-delete: hidden from lists/sums, recoverable from the database file.
  Future<void> delete(String id) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(deletedAt: Value(DateTime.now())),
    );
  }
}