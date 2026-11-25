import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dailyhisab/app/app.dart';
import 'package:dailyhisab/data/app_providers.dart';
import 'package:dailyhisab/data/bootstrap_provider.dart';
import 'package:dailyhisab/data/database_providers.dart';
import 'package:dailyhisab/data/drift/app_database.dart';

/// Widget smoke tests. Data providers are overridden with synchronous
/// values so no Drift stream timers outlive the test (flutter_test asserts
/// no pending timers at teardown).
void main() {
  List<Override> commonOverrides(AppDatabase db) => [
        databaseProvider.overrideWith((ref) => db),
        appBootstrapProvider.overrideWith((ref) async {}),
        accountsStreamProvider.overrideWith((ref) => Stream.value(const [])),
        archivedAccountsStreamProvider
            .overrideWith((ref) => Stream.value(const [])),
        categoriesStreamProvider.overrideWith((ref) => Stream.value(const [])),
        savingsGoalsProvider.overrideWith((ref) => Stream.value(const [])),
        recentTransactionsProvider
            .overrideWith((ref) => Stream.value(const [])),
        monthSummaryProvider.overrideWith(
            (ref) => Future.value((incomeMinor: 0, expenseMinor: 0))),
        totalBalanceProvider.overrideWith((ref) => Future.value(0)),
        monthSpentProvider.overrideWith((ref) => Future.value(0)),
        monthExpenseByCategoryProvider
            .overrideWith((ref) => Future.value(const [])),
        currencyCodeProvider.overrideWith((ref) => Future.value('BDT')),
      ];

  testWidgets('app boots to dashboard with empty state', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: commonOverrides(db),
        child: const DailyHisabApp(),
      ),
    );
    await tester.pumpAndSettle();

    // AppBar shows the app name; dashboard shows the friendly empty state.
    expect(find.text('DailyHisab'), findsWidgets);
    expect(find.text('No transactions yet. Tap + to add your first one.'),
        findsOneWidget);
    expect(find.text('0 accounts'), findsOneWidget);
    expect(find.text('৳0.00'), findsWidgets);
  });

  testWidgets('navigation bar shows localized tab labels', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: commonOverrides(db),
        child: const DailyHisabApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Txns'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
