import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_views.dart';
import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cats = ref.watch(categoriesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.categoriesTitle)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'category-add',
        onPressed: () => _showAdd(context, ref),
        child: const Icon(Icons.add),
      ),
      body: cats.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyStateView(
              icon: Icons.category_outlined,
              message: t.noCategories,
            );
          }
          final income =
              list.where((c) => c.kind == CategoryKind.income).toList();
          final expense =
              list.where((c) => c.kind == CategoryKind.expense).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(t.incomeSection,
                  style: Theme.of(context).textTheme.titleSmall),
              ...income.map(
                (c) => ListTile(
                  leading: const Icon(Icons.north_east, color: Colors.teal),
                  title: Text(c.name),
                  trailing: c.isDefault
                      ? null
                      : const Icon(Icons.bookmark_outline, size: 18),
                ),
              ),
              const SizedBox(height: 16),
              Text(t.expenseSection,
                  style: Theme.of(context).textTheme.titleSmall),
              ...expense.map(
                (c) => ListTile(
                  leading: const Icon(Icons.south_west, color: Colors.red),
                  title: Text(c.name),
                  trailing: c.isDefault
                      ? null
                      : const Icon(Icons.bookmark_outline, size: 18),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(details: e.toString()),
      ),
    );
  }

  Future<void> _showAdd(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    CategoryKind kind = CategoryKind.expense;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return AlertDialog(
              title: Text(t.addCategoryTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: t.categoryNameLabel),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CategoryKind>(
                    initialValue: kind,
                    items: [
                      DropdownMenuItem(
                          value: CategoryKind.expense,
                          child: Text(t.kindExpense)),
                      DropdownMenuItem(
                          value: CategoryKind.income,
                          child: Text(t.kindIncome)),
                    ],
                    onChanged: (v) =>
                        setS(() => kind = v ?? CategoryKind.expense),
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
                    final n = nameCtrl.text.trim();
                    if (n.isEmpty) return;
                    await ref
                        .read(categoriesRepositoryProvider)
                        .create(name: n, kind: kind);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(t.saveLabel),
                ),
              ],
            );
          },
        );
      },
    );
    nameCtrl.dispose();
  }
}
