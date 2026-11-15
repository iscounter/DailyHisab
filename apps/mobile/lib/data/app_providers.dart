import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drift/app_database.dart';
import '../data/database_providers.dart';
import '../data/repositories/accounts_repository.dart';
import '../data/repositories/categories_repository.dart';
import '../data/repositories/transactions_repository.dart';

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
