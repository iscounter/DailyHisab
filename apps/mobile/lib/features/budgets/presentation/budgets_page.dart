import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/app_providers.dart';
import '../../../data/database_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../core/utils/money.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  int _currentMonthYear() {
    final now = DateTime.now();
    return now.year * 100 + now.month;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final my = _currentMonthYear();
    final spent = ref.watch(monthSpentProvider).valueOrNull ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addBudget(context, ref, db, my),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Budget>>(
        stream: (db.select(db.budgets)..where((t) => t.monthYear.equals(my))).watch(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? <Budget>[];
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No budgets for this month. Tap + to add.'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final b = list[i];
              final ratio = b.limitMinor <= 0 ? 0.0 : (spent / b.limitMinor).clamp(0.0, 1.0).toDouble();
              final over = spent > b.limitMinor;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await (db.delete(db.budgets)..where((t) => t.id.equals(b.id))).go();
                            },
                          ),
                        ],
                      ),
                      Text('Limit ${formatBdtMinor(b.limitMinor)}'),
                      const SizedBox(height: 4),
                      Text(
                        'Spent ${formatBdtMinor(spent)} of ${formatBdtMinor(b.limitMinor)}',
                        style: TextStyle(color: over ? Theme.of(context).colorScheme.error : null),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addBudget(BuildContext context, WidgetRef ref, AppDatabase db, int my) async {
    final nameCtrl = TextEditingController(text: 'Monthly budget');
    final limitCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: limitCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Limit (BDT)'),
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
                final limitMinor = parseBdtToMinor(limitCtrl.text);
                if (limitMinor == null || limitMinor <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Enter a valid limit > 0')),
                  );
                  return;
                }
                await db.into(db.budgets).insert(
                      BudgetsCompanion.insert(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        name: nameCtrl.text.trim().isEmpty ? 'Budget' : nameCtrl.text.trim(),
                        monthYear: my,
                        limitMinor: limitMinor,
                        createdAt: DateTime.now(),
                      ),
                    );
                ref.invalidate(monthSpentProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    nameCtrl.dispose();
    limitCtrl.dispose();
  }
}