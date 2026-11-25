import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final summary = ref.watch(monthSummaryProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final accounts = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appName),
        actions: [
          IconButton(
            tooltip: t.savingsTooltip,
            onPressed: () => context.push('/savings'),
            icon: const Icon(Icons.savings_outlined),
          ),
          IconButton(
            tooltip: t.settingsTooltip,
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard-add',
        onPressed: () => context.go('/transactions'),
        icon: const Icon(Icons.add),
        label: Text(t.addLabel),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthSummaryProvider);
          ref.invalidate(totalBalanceProvider);
          ref.invalidate(accountBalancesProvider);
          ref.invalidate(monthExpenseByCategoryProvider);
          ref.invalidate(monthSpentProvider);
          ref.invalidate(currencyCodeProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _TotalBalanceCard(balance: totalBalance),
            const SizedBox(height: 12),
            _SummaryCard(summary: summary),
            const SizedBox(height: 16),
            Text(
              t.thisMonth,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            accounts.when(
              data: (list) => Semantics(
                label: t.accountsCount(list.length),
                child: Text(
                  t.accountsCount(list.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => ErrorStateView(details: e.toString()),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.recentTransactions,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: Text(t.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            recent.when(
              data: (items) {
                if (items.isEmpty) {
                  return Card(
                    child: EmptyStateView(
                      icon: Icons.receipt_long_outlined,
                      message: t.noTransactionsYet,
                    ),
                  );
                }
                return Column(
                  children:
                      items.take(8).map((txn) => _TxnTile(txn: txn)).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => ErrorStateView(details: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({required this.balance});
  final AsyncValue<int> balance;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: balance.when(
          data: (v) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.totalBalance,
                style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 6),
              Text(
                formatBdtMinor(v),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          loading: () => const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => ErrorStateView(details: e.toString()),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final AsyncValue<({int incomeMinor, int expenseMinor})> summary;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: summary.when(
          data: (s) {
            final net = s.incomeMinor - s.expenseMinor;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.netThisMonth,
                  style: TextStyle(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 6),
                Text(
                  formatBdtMinor(net),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _mini(context, t.income, s.incomeMinor,
                          Colors.teal, Icons.north_east),
                    ),
                    Expanded(
                      child: _mini(context, t.expense, s.expenseMinor, cs.error,
                          Icons.south_west),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => ErrorStateView(details: e.toString()),
        ),
      ),
    );
  }

  Widget _mini(
      BuildContext context, String label, int v, Color c, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c, semanticLabel: label),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: c, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatBdtMinor(v),
          style: TextStyle(color: c, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.txn});
  final Transaction txn;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isIncome = txn.kind == TxnKind.income;
    final isTransfer = txn.kind == TxnKind.transfer;
    final color = isIncome
        ? Colors.teal
        : (isTransfer ? Colors.blue : Colors.red.shade700);
    final icon = isIncome
        ? Icons.arrow_downward
        : (isTransfer ? Icons.swap_horiz : Icons.arrow_upward);
    final kindLabel =
        isIncome ? t.kindIncome : (isTransfer ? t.kindTransfer : t.kindExpense);
    final dateStr = DateFormat.yMd(Localizations.localeOf(context).toString())
        .format(txn.occurredAt.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, semanticLabel: kindLabel),
        ),
        title: Text(
          formatBdtMinor(txn.amountMinor),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          txn.note.isEmpty ? kindLabel : txn.note,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Semantics(
          label: dateStr,
          child: Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
    );
  }
}
