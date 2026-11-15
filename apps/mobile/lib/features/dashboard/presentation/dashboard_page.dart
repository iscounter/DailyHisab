import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_providers.dart';
import '../core/utils/money.dart';
import '../data/drift/app_database.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final accounts = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyHisab'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/transactions'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthSummaryProvider);
          ref.invalidate(recentTransactionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SummaryCard(summary: summary),
            const SizedBox(height: 16),
            Text('This month', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            accounts.when(
              data: (list) => Text('${list.length} account(s)', style: Theme.of(context).textTheme.bodyMedium),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Accounts error: $e'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent transactions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(onPressed: () => context.go('/transactions'), child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 8),
            recent.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No transactions yet. Tap + to add from Transactions.')));
                }
                return Column(
                  children: items.take(8).map((t) => _TxnTile(txn: t)).toList(),
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
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
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: summary.when(
          data: (s) {
            final balance = s.incomeMinor - s.expenseMinor;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net this month', style: TextStyle(color: cs.onPrimaryContainer.withOpacity(0.85))),
                const SizedBox(height: 6),
                Text(formatBdtMinor(balance), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _mini(context, 'Income', s.incomeMinor, cs.onPrimaryContainer)),
                    Expanded(child: _mini(context, 'Expense', s.expenseMinor, cs.onPrimaryContainer)),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Failed to load summary: $e'),
        ),
      ),
    );
  }

  Widget _mini(BuildContext context, String label, int v, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: c.withOpacity(0.75), fontSize: 12)),
        const SizedBox(height: 4),
        Text(formatBdtMinor(v), style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TxnTile extends ConsumerWidget {
  const _TxnTile({required this.txn});
  final Transaction txn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = txn.type == TxnType.income;
    final color = isIncome ? Colors.teal : Colors.red.shade700;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color),
        ),
        title: Text(formatBdtMinor(txn.amountMinor), style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(txn.note.isEmpty ? (isIncome ? 'Income' : 'Expense') : txn.note, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text('${txn.occurredAt.month}/${txn.occurredAt.day}', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
