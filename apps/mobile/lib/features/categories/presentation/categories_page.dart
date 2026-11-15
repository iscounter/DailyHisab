import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdd(context, ref),
        child: const Icon(Icons.add),
      ),
      body: cats.when(
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('No categories. Tap + to add (defaults are seeded on first run in some flows).'));
          final income = list.where((c) => c.type == TxnType.income).toList();
          final expense = list.where((c) => c.type == TxnType.expense).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Income', style: Theme.of(context).textTheme.titleSmall),
              ...income.map((c) => ListTile(title: Text(c.name), leading: const Icon(Icons.south_west))),
              const SizedBox(height: 16),
              Text('Expense', style: Theme.of(context).textTheme.titleSmall),
              ...expense.map((c) => ListTile(title: Text(c.name), leading: const Icon(Icons.north_east))),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAdd(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    TxnType type = TxnType.expense;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<TxnType>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: TxnType.expense, child: Text('Expense')),
                  DropdownMenuItem(value: TxnType.income, child: Text('Income')),
                ],
                onChanged: (v) => setS(() => type = v ?? TxnType.expense),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final n = nameCtrl.text.trim();
                if (n.isEmpty) return;
                await ref.read(categoriesRepositoryProvider).create(name: n, type: type);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
  }
}
