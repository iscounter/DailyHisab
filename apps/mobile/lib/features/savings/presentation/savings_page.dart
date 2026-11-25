import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';

class SavingsPage extends ConsumerWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final goals = ref.watch(savingsGoalsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.savingsTitle)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'savings-add',
        onPressed: () => _addGoal(context, ref),
        child: const Icon(Icons.add),
      ),
      body: goals.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyStateView(
              icon: Icons.savings_outlined,
              message: t.noSavingsGoals,
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
                            child: Text(
                              g.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            tooltip: t.deleteLabel,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref
                                  .read(savingsGoalsRepositoryProvider)
                                  .delete(g.id);
                            },
                          ),
                        ],
                      ),
                      Text(
                        t.goalProgress(
                          formatBdtMinor(g.savedMinor),
                          formatBdtMinor(g.targetMinor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      StatusSemantic(
                        label: t.goalProgress(
                          formatBdtMinor(g.savedMinor),
                          formatBdtMinor(g.targetMinor),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: ratio.toDouble(),
                            minHeight: 8,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (done) ...[
                            const Icon(Icons.check_circle,
                                color: Colors.teal, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              t.goalReached,
                              style: const TextStyle(color: Colors.teal),
                            ),
                          ],
                          TextButton.icon(
                            onPressed: () => _addMoney(context, ref, g),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(t.addMoney),
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
        error: (e, _) => ErrorStateView(details: e.toString()),
      ),
    );
  }

  Future<void> _addGoal(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.newGoalTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: t.goalNameLabel),
              ),
              TextField(
                controller: targetCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: t.targetLabel),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.cancelLabel),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final target = parseBdtToMinor(targetCtrl.text);
                if (name.isEmpty || target == null || target <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(t.enterValidGoal)),
                  );
                  return;
                }
                await ref
                    .read(savingsGoalsRepositoryProvider)
                    .create(name: name, targetMinor: target);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(t.saveLabel),
            ),
          ],
        );
      },
    );
    nameCtrl.dispose();
    targetCtrl.dispose();
  }

  Future<void> _addMoney(
      BuildContext context, WidgetRef ref, SavingsGoal goal) async {
    final t = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.addToSavingsTitle),
          content: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.amountLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.cancelLabel),
            ),
            FilledButton(
              onPressed: () async {
                final amount = parseBdtToMinor(ctrl.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(t.invalidAmount)),
                  );
                  return;
                }
                await ref
                    .read(savingsGoalsRepositoryProvider)
                    .addToSaved(goal.id, amount);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(t.addLabel),
            ),
          ],
        );
      },
    );
    ctrl.dispose();
  }
}
