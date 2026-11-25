import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dailyhisab/core/backup/backup_codec.dart';
import 'package:dailyhisab/data/drift/app_database.dart';
import 'package:dailyhisab/data/repositories/accounts_repository.dart';
import 'package:dailyhisab/data/repositories/backup_repository.dart';
import 'package:dailyhisab/data/repositories/categories_repository.dart';
import 'package:dailyhisab/data/repositories/transactions_repository.dart';

void main() {
  late AppDatabase db;
  late AccountsRepository accounts;
  late CategoriesRepository categories;
  late TransactionsRepository txns;
  late BackupRepository backup;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    accounts = AccountsRepository(db);
    categories = CategoriesRepository(db);
    txns = TransactionsRepository(db);
    backup = BackupRepository(db, appVersion: 'test');
  });

  tearDown(() async {
    await db.close();
  });

  test('export -> restore round-trip preserves all data', () async {
    // Seed.
    await accounts.create(
        name: 'Cash', kind: AccountKind.cash, openingBalanceMinor: 100000);
    await accounts.create(name: 'Bank', kind: AccountKind.bank);
    await categories.seedDefaultsIfEmpty();
    final accs = await accounts.getAll();
    final cash = accs.firstWhere((a) => a.name == 'Cash');
    final cats = await categories.getAll();
    final incomeCat = cats.firstWhere((c) => c.kind == CategoryKind.income);
    final expenseCat = cats.firstWhere((c) => c.kind == CategoryKind.expense);

    await txns.add(
      kind: TxnKind.income,
      amountMinor: 25000,
      toAccountId: cash.id,
      categoryId: incomeCat.id,
      occurredAt: DateTime.utc(2026, 1, 2),
    );
    await txns.add(
      kind: TxnKind.expense,
      amountMinor: 12550,
      fromAccountId: cash.id,
      categoryId: expenseCat.id,
      occurredAt: DateTime.utc(2026, 1, 3),
    );
    // Soft-deleted row must survive backup too.
    await txns.add(
      kind: TxnKind.expense,
      amountMinor: 999,
      fromAccountId: accs.first.id,
      categoryId: expenseCat.id,
      occurredAt: DateTime.utc(2026, 1, 4),
      note: 'to delete',
    );
    final doomed =
        (await txns.getAll()).firstWhere((t) => t.note == 'to delete');
    await txns.delete(doomed.id);

    await db.into(db.budgets).insert(BudgetsCompanion.insert(
          id: 'b1',
          name: 'Monthly',
          monthYear: 202601,
          limitMinor: 100000,
          createdAt: DateTime.utc(2026, 1, 1).toUtc(),
        ));
    await db.into(db.savingsGoals).insert(SavingsGoalsCompanion.insert(
          id: 'g1',
          name: 'Bike',
          targetMinor: 500000,
          createdAt: DateTime.utc(2026, 1, 1).toUtc(),
        ));

    // Export.
    final content = await backup.exportContent();
    final json = backup.exportToJson(content);

    // Destructively change current data.
    final current = await txns.getAll();
    for (final t in current) {
      await txns.delete(t.id);
    }
    await accounts.archive(accs.last.id);
    expect((await txns.getAll()), isEmpty);

    // Restore and verify everything is back.
    await backup.restoreFromJson(json);

    final restoredAccounts = await accounts.getAllIncludingArchived();
    expect(restoredAccounts.length, 2);
    final restoredCash = restoredAccounts.firstWhere((a) => a.name == 'Cash');

    final restoredTxns = await txns.getAll();
    expect(restoredTxns.length, 2); // soft-deleted one stays hidden

    expect(
      await txns.accountBalanceMinor(
          restoredCash.id, restoredCash.openingBalanceMinor),
      100000 + 25000 - 12550, // soft-deleted 999 stays excluded
    );

    // Soft-deleted row survives the backup as a deleted row.
    final rawDeleted = await (db.select(db.transactions)
          ..where((t) => t.note.equals('to delete')))
        .get();
    expect(rawDeleted.length, 1);
    expect(rawDeleted.first.deletedAt, isNotNull);

    final budgets = await db.select(db.budgets).get();
    expect(budgets.length, 1);
    expect(budgets.first.id, 'b1');

    final goals = await db.select(db.savingsGoals).get();
    expect(goals.length, 1);
    expect(goals.first.name, 'Bike');
  });

  test('restore rejects malformed backups without touching the db', () async {
    await accounts.create(name: 'Cash', kind: AccountKind.cash);
    expect((await accounts.getAll()).length, 1);

    expect(
      () => backup.restoreFromJson('{"format":"wrong"}'),
      throwsA(isA<BackupFormatException>()),
    );

    // Database untouched.
    expect((await accounts.getAll()).length, 1);
  });
}
