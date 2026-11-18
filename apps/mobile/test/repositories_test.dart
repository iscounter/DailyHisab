import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dailyhisab/core/utils/money.dart';
import 'package:dailyhisab/data/drift/app_database.dart';
import 'package:dailyhisab/data/repositories/accounts_repository.dart';
import 'package:dailyhisab/data/repositories/categories_repository.dart';
import 'package:dailyhisab/data/repositories/transactions_repository.dart';

void main() {
  late AppDatabase db;
  late AccountsRepository accounts;
  late CategoriesRepository categories;
  late TransactionsRepository txns;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    accounts = AccountsRepository(db);
    categories = CategoriesRepository(db);
    txns = TransactionsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('income increases, expense decreases account balance', () async {
    await accounts.create(name: 'Cash', kind: AccountKind.cash, openingBalanceMinor: 100000);
    final account = (await accounts.getAll()).first;

    await categories.seedDefaultsIfEmpty();
    final cats = await categories.getAll();
    final incomeCat = cats.firstWhere((c) => c.kind == CategoryKind.income);
    final expenseCat = cats.firstWhere((c) => c.kind == CategoryKind.expense);

    await txns.add(
      kind: TxnKind.income,
      amountMinor: 25000,
      toAccountId: account.id,
      categoryId: incomeCat.id,
      occurredAt: DateTime.utc(2026, 1, 2),
    );
    expect(await txns.accountBalanceMinor(account.id, 100000), 125000);

    await txns.add(
      kind: TxnKind.expense,
      amountMinor: 12550,
      fromAccountId: account.id,
      categoryId: expenseCat.id,
      occurredAt: DateTime.utc(2026, 1, 3),
    );
    expect(await txns.accountBalanceMinor(account.id, 100000), 112450);
  });

  test('transfer preserves combined balance (invariant)', () async {
    await accounts.create(name: 'A', kind: AccountKind.cash);
    await accounts.create(name: 'B', kind: AccountKind.bank);
    final list = await accounts.getAll();
    final a = list.firstWhere((x) => x.name == 'A');
    final b = list.firstWhere((x) => x.name == 'B');

    await txns.add(
      kind: TxnKind.transfer,
      amountMinor: 10000,
      fromAccountId: a.id,
      toAccountId: b.id,
      occurredAt: DateTime.utc(2026, 1, 4),
    );

    final balA = await txns.accountBalanceMinor(a.id, 0);
    final balB = await txns.accountBalanceMinor(b.id, 0);
    expect(balA, -10000);
    expect(balB, 10000);
    expect(balA + balB, 0);
  });

  test('soft delete hides a transaction from reads and balances', () async {
    await accounts.create(name: 'Cash', kind: AccountKind.cash, openingBalanceMinor: 0);
    final account = (await accounts.getAll()).first;
    await categories.seedDefaultsIfEmpty();
    final cats = await categories.getAll();
    final expenseCat = cats.firstWhere((c) => c.kind == CategoryKind.expense);

    await txns.add(
      kind: TxnKind.expense,
      amountMinor: 5000,
      fromAccountId: account.id,
      categoryId: expenseCat.id,
      occurredAt: DateTime.utc(2026, 2, 1),
    );
    expect((await txns.getAll()).length, 1);

    await txns.delete((await txns.getAll()).first.id);
    expect((await txns.getAll()).length, 0);
    expect(await txns.accountBalanceMinor(account.id, 0), 0);
  });

  test('rejects non-positive amounts and invalid transfers', () async {
    await accounts.create(name: 'Cash', kind: AccountKind.cash);
    final account = (await accounts.getAll()).first;
    await categories.seedDefaultsIfEmpty();
    final cats = await categories.getAll();
    final expenseCat = cats.firstWhere((c) => c.kind == CategoryKind.expense);

    expect(
      () => txns.add(
        kind: TxnKind.expense,
        amountMinor: 0,
        fromAccountId: account.id,
        categoryId: expenseCat.id,
        occurredAt: DateTime.now(),
      ),
      throwsArgumentError,
    );

    expect(
      () => txns.add(
        kind: TxnKind.transfer,
        amountMinor: 100,
        fromAccountId: account.id,
        toAccountId: account.id,
        occurredAt: DateTime.now(),
      ),
      throwsArgumentError,
    );
  });

  test('exact money parsing', () {
    expect(parseBdtToMinor('100.50'), 10050);
    expect(parseBdtToMinor('0.01'), 1);
    expect(parseBdtToMinor('100.509'), isNull);
  });
}