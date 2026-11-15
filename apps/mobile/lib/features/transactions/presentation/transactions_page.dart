import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../core/utils/money.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(recentTransactionsProvider);
    final accounts = ref.watch(accountsStreamProvider);
    final categories = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref, accounts.valueOrNull ?? [], categories.valueOrNull ?? []),
        child: const Icon(Icons.add),
      ),
      body: txns.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No transactions yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final t = items[i];
              final isIncome = t.type == TxnType.income;
              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: Colors.red.shade700,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await ref.read(transactionsRepositoryProvider).delete(t.id);
                  ref.invalidate(monthSummaryProvider);
                },
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(isIncome ? Icons.north_east : Icons.south_west, color: isIncome ? Colors.teal : Colors.red.shade700),
                  title: Text(formatBdtMinor(t.amountMinor)),
                  subtitle: Text('${t.note.isEmpty ? (isIncome ? 'Income' : 'Expense') : t.note}\n${t.occurredAt.toLocal().toString().split('.').first}', style: Theme.of(context).textTheme.bodySmall),
                  isThreeLine: t.note.isNotEmpty,
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

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref, List<Account> accounts, List<Category> categories) async {
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add an account first (Accounts tab).')));
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddTxnSheet(accounts: accounts, categories: categories),
    );
  }
}

class _AddTxnSheet extends ConsumerStatefulWidget {
  const _AddTxnSheet({required this.accounts, required this.categories});
  final List<Account> accounts;
  final List<Category> categories;

  @override
  ConsumerState<_AddTxnSheet> createState() => _AddTxnSheetState();
}

class _AddTxnSheetState extends ConsumerState<_AddTxnSheet> {
  TxnType _type = TxnType.expense;
  late String _accountId = widget.accounts.first.id;
  String? _categoryId;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pickDefaultCategory();
  }

  void _pickDefaultCategory() {
    final filtered = widget.categories.where((c) => c.type == _type).toList();
    if (filtered.isNotEmpty) _categoryId = filtered.first.id;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCats = widget.categories.where((c) => c.type == _type).toList();
    if (_categoryId == null && filteredCats.isNotEmpty) _categoryId = filteredCats.first.id;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add transaction', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<TxnType>(
              segments: const [
                ButtonSegment(value: TxnType.expense, label: Text('Expense')),
                ButtonSegment(value: TxnType.income, label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _pickDefaultCategory();
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (BDT)', hintText: 'e.g. 500 or 500.50'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _accountId,
              decoration: const InputDecoration(labelText: 'Account'),
              items: widget.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
              onChanged: (v) => setState(() => _accountId = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: filteredCats.any((c) => c.id == _categoryId) ? _categoryId : (filteredCats.isNotEmpty ? filteredCats.first.id : null),
              decoration: const InputDecoration(labelText: 'Category'),
              items: filteredCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            TextField(controller: _noteCtrl, decoration: const InputDecoration(labelText: 'Note (optional)')),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_date.toLocal().toString().split(' ').first),
              onTap: () async {
                final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: _date);
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final raw = _amountCtrl.text.trim().replaceAll(',', '');
                final val = double.tryParse(raw);
                if (val == null || val <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount > 0')));
                  return;
                }
                if (_categoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a category first.')));
                  return;
                }
                final minor = (val * 100).round();
                await ref.read(transactionsRepositoryProvider).add(
                      type: _type,
                      amountMinor: minor,
                      accountId: _accountId,
                      categoryId: _categoryId!,
                      occurredAt: _date,
                      note: _noteCtrl.text.trim(),
                    );
                ref.invalidate(monthSummaryProvider);
                ref.invalidate(recentTransactionsProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
