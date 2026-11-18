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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Txns'),
              NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Accounts'),
              NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
              NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'Budgets'),
              NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Analytics'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
            ],
          ),
        ),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, __) => const DashboardPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/transactions', builder: (_, __) => const TransactionsPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/accounts', builder: (_, __) => const AccountsPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/categories', builder: (_, __) => const CategoriesPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/budgets', builder: (_, __) => const BudgetsPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, __) => const SettingsPage())]),
        ],
      ),
      GoRoute(path: '/savings', builder: (_, __) => const SavingsPage()),
    ],
  );
});
