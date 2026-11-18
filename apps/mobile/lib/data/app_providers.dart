import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drift/app_database.dart';
import '../data/database_providers.dart';
import '../data/repositories/accounts_repository.dart';
import '../data/repositories/categories_repository.dart';
import '../data/repositories/transactions_repository.dart';
import '../data/repositories/app_settings_repository.dart';
import '../data/repositories/savings_goals_repository.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(ref.watch(databaseProvider));
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(databaseProvider));
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.watch(databaseProvider));
});

final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAll();
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchAll();
});

final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionsRepositoryProvider).watchRecent();
});

class MonthRange {
  const MonthRange(this.from, this.to);
  final DateTime from;
  final DateTime to;
}

MonthRange currentMonthRange() {
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, 1);
  final to = DateTime(now.year, now.month + 1, 1);
  return MonthRange(from, to);
}

final monthSummaryProvider = FutureProvider<({int incomeMinor, int expenseMinor})>((ref) async {
  final repo = ref.watch(transactionsRepositoryProvider);
  final r = currentMonthRange();
  final income = await repo.sumIncomeMinor(r.from, r.to);
  final expense = await repo.sumExpenseMinor(r.from, r.to);
  return (incomeMinor: income, expenseMinor: expense);
});

/// Total balance across all active accounts:
/// sum(opening balances) + all-time income - all-time expense.
final totalBalanceProvider = FutureProvider<int>((ref) async {
  final accounts = ref.watch(accountsRepositoryProvider);
  final txns = ref.watch(transactionsRepositoryProvider);
  final opening = await accounts.sumOpeningBalanceMinor();
  final income = await txns.sumAllIncomeMinor();
  final expense = await txns.sumAllExpenseMinor();
  return opening + income - expense;
});

/// Total expenses in the current month (used for budget spent/remaining).
final monthSpentProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(transactionsRepositoryProvider);
  final r = currentMonthRange();
  return repo.sumExpenseMinor(r.from, r.to);
});

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(ref.watch(databaseProvider));
});

final savingsGoalsRepositoryProvider = Provider<SavingsGoalsRepository>((ref) {
  return SavingsGoalsRepository(ref.watch(databaseProvider));
});

final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(savingsGoalsRepositoryProvider).watchAll();
});

/// Map of accountId -> current balance (opening + posted transactions).
final accountBalancesProvider = FutureProvider<Map<String, int>>((ref) async {
  final accRepo = ref.watch(accountsRepositoryProvider);
  final txnRepo = ref.watch(transactionsRepositoryProvider);
  final accounts = await accRepo.getAll();
  return txnRepo.balancesByAccount(accounts);
});

/// Free-text search query for the transactions list (client-side filter).
final transactionQueryProvider = StateProvider<String>((ref) => '');

/// Optional transaction type filter for the transactions list.
final transactionTypeFilterProvider = StateProvider<TxnKind?>((ref) => null);

/// Display currency code (from app_settings, defaults to BDT).
final currencyCodeProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(appSettingsRepositoryProvider);
  final v = await repo.get('currency_code');
  return (v == null || v.isEmpty) ? 'BDT' : v;
});

/// Current-month expenses grouped by category, sorted by amount (desc).
final monthExpenseByCategoryProvider =
    FutureProvider<List<({String categoryId, String name, int totalMinor})>>(
        (ref) async {
  final txnRepo = ref.watch(transactionsRepositoryProvider);
  final catRepo = ref.watch(categoriesRepositoryProvider);
  final all = await txnRepo.getAll();
  final cats = await catRepo.getAll();
  final r = currentMonthRange();

  final catName = {for (final c in cats) c.id: c.name};
  final totals = <String, int>{};

  for (final t in all) {
    if (t.kind != TxnKind.expense) continue;
    if (t.occurredAt.isBefore(r.from) || !t.occurredAt.isBefore(r.to)) continue;
    final key = t.categoryId ?? '__none__';
    totals[key] = (totals[key] ?? 0) + t.amountMinor;
  }

  final list = totals.entries.map((e) {
    return (
      categoryId: e.key,
      name: e.key == '__none__' ? 'Uncategorized' : (catName[e.key] ?? 'Uncategorized'),
      totalMinor: e.value,
    );
  }).toList();

  list.sort((a, b) => b.totalMinor.compareTo(a.totalMinor));
  return list;
});
