import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

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
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No budgets for this month. Tap + to add.')));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final b = list[i];
              return Card(
                child: ListTile(
                  title: Text(b.name),
                  subtitle: Text('Limit ${formatBdtMinor(b.limitMinor)} • ${b.monthYear}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline'),
                    onPressed: () async {
                      await (db.delete(db.budgets)..where((t) => t.id.equals(b.id))).go();
                    },
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
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: limitCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Limit (BDT)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final v = double.tryParse(limitCtrl.text.trim());
              if (v == null || v <= 0) return;
              await db.into(db.budgets).insert(BudgetsCompanion.insert(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    name: nameCtrl.text.trim().isEmpty ? 'Budget' : nameCtrl.text.trim(),
                    monthYear: my,
                    limitMinor: (v * 100).round(),
                    createdAt: DateTime.now(),
                  ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    limitCtrl.dispose();
  }
}
