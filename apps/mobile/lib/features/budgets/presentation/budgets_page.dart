import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/app_providers.dart';
import '../../../data/database_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';

const _uuid = Uuid();

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  int _currentMonthYear() {
    final now = DateTime.now();
    return now.year * 100 + now.month;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final my = _currentMonthYear();
    final spentTotal = ref.watch(monthSpentProvider).valueOrNull ?? 0;
    final byCategory =
        ref.watch(monthExpenseByCategoryProvider).valueOrNull ?? const [];
    final spentByCat = {
      for (final e in byCategory) e.categoryId: e.totalMinor,
    };
    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ?? const <Category>[];

    return Scaffold(
      appBar: AppBar(title: Text(t.budgetsTitle)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budget-add',
        onPressed: () => _addBudget(context, ref, db, my, categories),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Budget>>(
        stream: (db.select(db.budgets)
              ..where((tbl) => tbl.monthYear.equals(my)))
            .watch(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorStateView(details: snap.error.toString());
          }
          final list = snap.data ?? <Budget>[];
          if (list.isEmpty) {
            return EmptyStateView(
              icon: Icons.savings_outlined,
              message: t.noBudgets,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final b = list[i];
              // Overall budget (no category) uses total month expenses;
              // category budgets use that category's expenses only.
              final spent = b.categoryId == null
                  ? spentTotal
                  : (spentByCat[b.categoryId] ?? 0);
              String? catName;
              if (b.categoryId != null) {
                for (final c in categories) {
                  if (c.id == b.categoryId) {
                    catName = c.name;
                    break;
                  }
                }
              }
              final ratio = b.limitMinor <= 0
                  ? 0.0
                  : (spent / b.limitMinor).clamp(0.0, 1.0);
              final over = spent > b.limitMinor;

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
                              catName == null ? b.name : '${b.name} • $catName',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            tooltip: t.deleteBudgetTooltip,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await (db.delete(db.budgets)
                                    ..where((tbl) => tbl.id.equals(b.id)))
                                  .go();
                              ref.invalidate(monthSpentProvider);
                            },
                          ),
                        ],
                      ),
                      Text(t.budgetSpentOf(
                        formatBdtMinor(spent),
                        formatBdtMinor(b.limitMinor),
                      )),
                      const SizedBox(height: 4),
                      if (over)
                        Text(
                          t.overBudget(formatBdtMinor(spent - b.limitMinor)),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 8),
                      StatusSemantic(
                        label: t.budgetSpentOf(
                          formatBdtMinor(spent),
                          formatBdtMinor(b.limitMinor),
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

  Future<void> _addBudget(BuildContext context, WidgetRef ref, AppDatabase db,
      int my, List<Category> categories) async {
    final t = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: t.budgetDefaultName);
    final limitCtrl = TextEditingController();
    String? categoryId;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return AlertDialog(
              title: Text(t.addBudgetTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: t.budgetNameLabel),
                  ),
                  TextField(
                    controller: limitCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: t.limitLabel),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: categoryId,
                    decoration: InputDecoration(labelText: t.categoryLabel),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(t.chipAll),
                      ),
                      ...categories
                          .where((c) => c.kind == CategoryKind.expense)
                          .map((c) => DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.name),
                              )),
                    ],
                    onChanged: (v) => setS(() => categoryId = v),
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
                    final limitMinor = parseBdtToMinor(limitCtrl.text);
                    if (limitMinor == null || limitMinor <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(t.invalidAmount)),
                      );
                      return;
                    }
                    await db.into(db.budgets).insert(
                          BudgetsCompanion.insert(
                            id: _uuid.v4(),
                            name: nameCtrl.text.trim().isEmpty
                                ? t.budgetDefaultName
                                : nameCtrl.text.trim(),
                            monthYear: my,
                            limitMinor: limitMinor,
                            categoryId: Value(categoryId),
                            createdAt: DateTime.now(),
                          ),
                        );
                    ref.invalidate(monthSpentProvider);
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
    limitCtrl.dispose();
  }
}
