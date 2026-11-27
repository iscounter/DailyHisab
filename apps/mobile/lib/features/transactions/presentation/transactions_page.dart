import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final query = ref.watch(transactionQueryProvider);
    final kindFilter = ref.watch(transactionTypeFilterProvider);
    final normalizedQuery = query.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            onPressed: () => _exportCsv(context, ref),
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(
          context,
          ref,
          accounts.valueOrNull ?? [],
          categories.valueOrNull ?? [],
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => ref.read(transactionQueryProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Search notes…',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: kindFilter == null,
                  onSelected: (_) => ref.read(transactionTypeFilterProvider.notifier).state = null,
                ),
                FilterChip(
                  label: const Text('Income'),
                  selected: kindFilter == TxnKind.income,
                  onSelected: (_) => ref
                      .read(transactionTypeFilterProvider.notifier)
                      .state = kindFilter == TxnKind.income ? null : TxnKind.income,
                ),
                FilterChip(
                  label: const Text('Expense'),
                  selected: kindFilter == TxnKind.expense,
                  onSelected: (_) => ref
                      .read(transactionTypeFilterProvider.notifier)
                      .state = kindFilter == TxnKind.expense ? null : TxnKind.expense,
                ),
                FilterChip(
                  label: const Text('Transfer'),
                  selected: kindFilter == TxnKind.transfer,
                  onSelected: (_) => ref
                      .read(transactionTypeFilterProvider.notifier)
                      .state = kindFilter == TxnKind.transfer ? null : TxnKind.transfer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: txns.when(
              data: (items) {
                final filtered = items.where((t) {
                  if (kindFilter != null && t.kind != kindFilter) return false;
                  if (normalizedQuery.isEmpty) return true;
                  return t.note.toLowerCase().contains(normalizedQuery);
                }).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No transactions match.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = filtered[i];
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
                        ref.invalidate(totalBalanceProvider);
                        ref.invalidate(accountBalancesProvider);
                      },
                      child: Card(
                        child: ListTile(
                          leading: Icon(_iconFor(t.kind), color: _colorFor(t.kind)),
                          title: Text(formatBdtMinor(t.amountMinor)),
                          subtitle: Text(
                            '${_labelFor(t)}\n${t.occurredAt.toLocal().toString().split('.').first}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openSheet(
                            context,
                            ref,
                            accounts.valueOrNull ?? [],
                            categories.valueOrNull ?? [],
                            existing: t,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(TxnKind kind) {
    switch (kind) {
      case TxnKind.income:
        return Icons.north_east;
      case TxnKind.expense:
        return Icons.south_west;
      case TxnKind.transfer:
        return Icons.swap_horiz;
    }
  }

  Color _colorFor(TxnKind kind) {
    switch (kind) {
      case TxnKind.income:
        return Colors.teal;
      case TxnKind.expense:
        return Colors.red.shade700;
      case TxnKind.transfer:
        return Colors.blue;
    }
  }

  String _labelFor(Transaction t) {
    switch (t.kind) {
      case TxnKind.income:
        return 'Income';
      case TxnKind.expense:
        return 'Expense';
      case TxnKind.transfer:
        return 'Transfer';
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final all = await ref.read(transactionsRepositoryProvider).getAll();
    final buf = StringBuffer(
      'kind,amount_minor,from_account,to_account,note,occurred_at\n',
    );
    for (final t in all) {
      final note = t.note.replaceAll('"', '""');
      buf.writeln(
        '${t.kind.name},${t.amountMinor},${t.fromAccountId ?? ''},'
        '${t.toAccountId ?? ''},"$note",${t.occurredAt.toIso8601String()}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied ${all.length} transactions as CSV')),
      );
    }
  }

  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
    List<Category> categories, {
    Transaction? existing,
  }) async {
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an account first (Accounts tab).')),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddTxnSheet(
        accounts: accounts,
        categories: categories,
        existing: existing,
      ),
    );
  }
}

class _AddTxnSheet extends ConsumerStatefulWidget {
  const _AddTxnSheet({
    required this.accounts,
    required this.categories,
    this.existing,
  });
  final List<Account> accounts;
  final List<Category> categories;
  final Transaction? existing;

  @override
  ConsumerState<_AddTxnSheet> createState() => _AddTxnSheetState();
}

class _AddTxnSheetState extends ConsumerState<_AddTxnSheet> {
  late TxnKind _kind;
  late String _fromAccountId;
  late String _toAccountId;
  String? _categoryId;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late DateTime _date;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _kind = e.kind;
      _fromAccountId = e.fromAccountId ?? widget.accounts.first.id;
      _toAccountId = e.toAccountId ??
          (widget.accounts.length > 1 ? widget.accounts[1].id : widget.accounts.first.id);
      _categoryId = e.categoryId;
      _date = e.occurredAt;
      _amountCtrl.text = minorToBdtInput(e.amountMinor);
      _noteCtrl.text = e.note;
    } else {
      _kind = TxnKind.expense;
      _fromAccountId = widget.accounts.first.id;
      _toAccountId = widget.accounts.length > 1 ? widget.accounts[1].id : widget.accounts.first.id;
      _pickDefaultCategory();
    }
  }

  void _pickDefaultCategory() {
    if (_kind == TxnKind.transfer) {
      _categoryId = null;
      return;
    }
    final want = _kind == TxnKind.income ? CategoryKind.income : CategoryKind.expense;
    final filtered = widget.categories.where((c) => c.kind == want).toList();
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
    final wantCat =
        _kind == TxnKind.income ? CategoryKind.income : CategoryKind.expense;
    final filteredCats = widget.categories.where((c) => c.kind == wantCat).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEdit ? 'Edit transaction' : 'Add transaction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<TxnKind>(
              segments: const [
                ButtonSegment(value: TxnKind.expense, label: Text('Expense')),
                ButtonSegment(value: TxnKind.income, label: Text('Income')),
                ButtonSegment(value: TxnKind.transfer, label: Text('Transfer')),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() {
                _kind = s.first;
                _pickDefaultCategory();
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (BDT)',
                hintText: 'e.g. 500 or 500.50',
              ),
            ),
            const SizedBox(height: 12),
            if (_kind != TxnKind.income)
              DropdownButtonFormField<String>(
                initialValue: _fromAccountId,
                decoration: InputDecoration(
                  labelText: _kind == TxnKind.transfer ? 'From account' : 'Account',
                ),
                items: widget.accounts
                    .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setState(() => _fromAccountId = v!),
              ),
            if (_kind == TxnKind.transfer) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _toAccountId,
                decoration: const InputDecoration(labelText: 'To account'),
                items: widget.accounts
                    .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setState(() => _toAccountId = v!),
              ),
            ],
            if (_kind == TxnKind.income) ...[
              DropdownButtonFormField<String>(
                initialValue: _toAccountId,
                decoration: const InputDecoration(labelText: 'Account'),
                items: widget.accounts
                    .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setState(() => _toAccountId = v!),
              ),
            ],
            if (_kind != TxnKind.transfer) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: filteredCats.any((c) => c.id == _categoryId)
                    ? _categoryId
                    : (filteredCats.isNotEmpty ? filteredCats.first.id : null),
                decoration: const InputDecoration(labelText: 'Category'),
                items: filteredCats
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_date.toLocal().toString().split(' ').first),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: _date,
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _save(context, ref),
              child: Text(_isEdit ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final minor = parseBdtToMinor(_amountCtrl.text);
    if (minor == null || minor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount > 0')),
      );
      return;
    }
    if (_kind == TxnKind.transfer) {
      if (_fromAccountId == _toAccountId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer accounts must differ')),
        );
        return;
      }
    }

    String? effectiveCategory;
    if (_kind != TxnKind.transfer) {
      final want =
          _kind == TxnKind.income ? CategoryKind.income : CategoryKind.expense;
      final options = widget.categories.where((c) => c.kind == want).toList();
      effectiveCategory = options.any((c) => c.id == _categoryId)
          ? _categoryId
          : (options.isNotEmpty ? options.first.id : null);
      if (effectiveCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add a category first.')),
        );
        return;
      }
    }

    final repo = ref.read(transactionsRepositoryProvider);
    final note = _noteCtrl.text.trim();

    if (_isEdit) {
      await repo.update(
        id: widget.existing!.id,
        kind: _kind,
        amountMinor: minor,
        fromAccountId: _kind == TxnKind.income ? null : _fromAccountId,
        toAccountId: _kind == TxnKind.expense ? null : _toAccountId,
        categoryId: effectiveCategory,
        occurredAt: _date,
        note: note,
      );
    } else {
      await repo.add(
        kind: _kind,
        amountMinor: minor,
        fromAccountId: _kind == TxnKind.income ? null : _fromAccountId,
        toAccountId: _kind == TxnKind.expense ? null : _toAccountId,
        categoryId: effectiveCategory,
        occurredAt: _date,
        note: note,
      );
    }
    ref.invalidate(monthSummaryProvider);
    ref.invalidate(totalBalanceProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(accountBalancesProvider);
    if (context.mounted) Navigator.pop(context);
  }
}