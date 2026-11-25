import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/transactions/presentation/transactions_page.dart';
import '../features/accounts/presentation/accounts_page.dart';
import '../features/categories/presentation/categories_page.dart';
import '../features/budgets/presentation/budgets_page.dart';
import '../features/analytics/presentation/analytics_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/savings/presentation/savings_page.dart';
import '../l10n/generated/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final t = AppLocalizations.of(context)!;
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: navigationShell.goBranch,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: t.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.swap_horiz_outlined),
                  selectedIcon: const Icon(Icons.swap_horiz),
                  label: t.navTxns,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet),
                  label: t.navAccounts,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.category_outlined),
                  selectedIcon: const Icon(Icons.category),
                  label: t.navCategories,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.pie_chart_outline),
                  selectedIcon: const Icon(Icons.pie_chart),
                  label: t.navBudgets,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.insights_outlined),
                  selectedIcon: const Icon(Icons.insights),
                  label: t.navAnalytics,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: t.navSettings,
                ),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, __) => const DashboardPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/transactions',
                builder: (_, __) => const TransactionsPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/accounts', builder: (_, __) => const AccountsPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/categories', builder: (_, __) => const CategoriesPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/budgets', builder: (_, __) => const BudgetsPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/analytics', builder: (_, __) => const AnalyticsPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (_, __) => const SettingsPage())
          ]),
        ],
      ),
      GoRoute(path: '/savings', builder: (_, __) => const SavingsPage()),
    ],
  );
});
