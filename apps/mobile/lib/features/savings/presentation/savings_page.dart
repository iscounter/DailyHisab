import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../core/utils/money.dart';

class SavingsPage extends ConsumerWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addGoal(context, ref),
        child: const Icon(Icons.add),
      ),
      body: goals.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No savings goals yet. Tap + to create one.'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final g = list[i];
              final ratio = g.targetMinor <= 0
                  ? 0.0
                  : (g.savedMinor / g.targetMinor).clamp(0.0, 1.0).toDouble();
              final done = g.targetMinor > 0 && g.savedMinor >= g.targetMinor;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(g.name,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref
                                  .read(savingsGoalsRepositoryProvider)
                                  .delete(g.id);
                            },
                          ),
                        ],
                      ),
                      Text('${formatBdtMinor(g.savedMinor)} of ${formatBdtMinor(g.targetMinor)}'),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (done) ...[
                            const Icon(Icons.check_circle, color: Colors.teal, size: 20),
                            const SizedBox(width: 8),
                          ],
                          TextButton.icon(
                            onPressed: () => _addMoney(context, ref, g),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add money'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _addGoal(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New savings goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Target (BDT)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final target = parseBdtToMinor(targetCtrl.text);
                if (name.isEmpty || target == null || target <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Enter a name and valid target')),
                  );
                  return;
                }
                await ref
                    .read(savingsGoalsRepositoryProvider)
                    .create(name: name, targetMinor: target);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    nameCtrl.dispose();
    targetCtrl.dispose();
  }

  Future<void> _addMoney(BuildContext context, WidgetRef ref, SavingsGoal goal) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add to savings'),
          content: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount (BDT)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = parseBdtToMinor(ctrl.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount > 0')),
                  );
                  return;
                }
                await ref
                    .read(savingsGoalsRepositoryProvider)
                    .addToSaved(goal.id, amount);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    ctrl.dispose();
  }
}