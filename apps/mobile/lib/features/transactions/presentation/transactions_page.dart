import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final txns = ref.watch(recentTransactionsProvider);
    final accounts = ref.watch(accountsStreamProvider);
    final categories = ref.watch(categoriesStreamProvider);
    final query = ref.watch(transactionQueryProvider);
    final kindFilter = ref.watch(transactionTypeFilterProvider);
    final normalizedQuery = query.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.transactionsTitle),
        actions: [
          IconButton(
            tooltip: t.exportCsvTooltip,
            onPressed: () => _exportCsv(context),
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'txn-add',
        onPressed: () => _openSheet(
          context,
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
              onChanged: (v) =>
                  ref.read(transactionQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: t.searchNotesHint,
                prefixIcon: const Icon(Icons.search),
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
                  label: Text(t.chipAll),
                  selected: kindFilter == null,
                  onSelected: (_) => ref
                      .read(transactionTypeFilterProvider.notifier)
                      .state = null,
                ),
                FilterChip(
                  label: Text(t.kindIncome),
                  selected: kindFilter == TxnKind.income,
                  onSelected: (_) =>
                      ref.read(transactionTypeFilterProvider.notifier).state =
                          kindFilter == TxnKind.income ? null : TxnKind.income,
                ),
                FilterChip(
                  label: Text(t.kindExpense),
                  selected: kindFilter == TxnKind.expense,
                  onSelected: (_) => ref
                          .read(transactionTypeFilterProvider.notifier)
                          .state =
                      kindFilter == TxnKind.expense ? null : TxnKind.expense,
                ),
                FilterChip(
                  label: Text(t.kindTransfer),
                  selected: kindFilter == TxnKind.transfer,
                  onSelected: (_) => ref
                          .read(transactionTypeFilterProvider.notifier)
                          .state =
                      kindFilter == TxnKind.transfer ? null : TxnKind.transfer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: txns.when(
              data: (items) {
                final filtered = items.where((txn) {
                  if (kindFilter != null && txn.kind != kindFilter) {
                    return false;
                  }
                  if (normalizedQuery.isEmpty) return true;
                  return txn.note.toLowerCase().contains(normalizedQuery);
                }).toList();
                if (filtered.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.filter_list_off,
                    message: t.noTxnMatch,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final txn = filtered[i];
                    return Dismissible(
                      key: ValueKey(txn.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmDelete(txn),
                      onDismissed: (_) => _deleteWithUndo(txn),
                      child: Card(
                        child: ListTile(
                          leading: Icon(_iconFor(txn.kind),
                              color: _colorFor(txn.kind),
                              semanticLabel: _labelFor(txn.kind)),
                          title: Text(
                            formatBdtMinor(txn.amountMinor),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${_labelFor(txn.kind)}\n'
                            '${DateFormat.yMd(Localizations.localeOf(context).toString()).format(txn.occurredAt.toLocal())} '
                            '${DateFormat.Hm(Localizations.localeOf(context).toString()).format(txn.occurredAt.toLocal())}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openSheet(
                            context,
                            accounts.valueOrNull ?? [],
                            categories.valueOrNull ?? [],
                            existing: txn,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateView(details: e.toString()),
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

  String _labelFor(TxnKind kind) {
    final t = AppLocalizations.of(context)!;
    switch (kind) {
      case TxnKind.income:
        return t.kindIncome;
      case TxnKind.expense:
        return t.kindExpense;
      case TxnKind.transfer:
        return t.kindTransfer;
    }
  }

  Future<bool> _confirmDelete(Transaction txn) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteTxnTitle),
        content: Text(t.deleteTxnMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancelLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.deleteLabel),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _deleteWithUndo(Transaction txn) async {
    final t = AppLocalizations.of(context)!;
    final repo = ref.read(transactionsRepositoryProvider);
    await repo.delete(txn.id);
    _invalidateTotals();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.txnDeleted),
        action: SnackBarAction(
          label: t.undoLabel,
          onPressed: () async {
            await repo.restore(txn.id);
            _invalidateTotals();
          },
        ),
      ),
    );
  }

  void _invalidateTotals() {
    ref.invalidate(monthSummaryProvider);
    ref.invalidate(totalBalanceProvider);
    ref.invalidate(accountBalancesProvider);
    ref.invalidate(monthExpenseByCategoryProvider);
    ref.invalidate(monthSpentProvider);
  }

  Future<void> _exportCsv(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final all = await ref.read(transactionsRepositoryProvider).getAll();
    final buf = StringBuffer(
      'kind,amount_minor,from_account,to_account,note,occurred_at\n',
    );
    for (final txn in all) {
      final note = txn.note.replaceAll('"', '""');
      buf.writeln(
        '${txn.kind.name},${txn.amountMinor},${txn.fromAccountId ?? ''},'
        '${txn.toAccountId ?? ''},"$note",${txn.occurredAt.toIso8601String()}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.csvCopied(all.length))),
      );
    }
  }

  Future<void> _openSheet(
    BuildContext context,
    List<Account> accounts,
    List<Category> categories, {
    Transaction? existing,
  }) async {
    final t = AppLocalizations.of(context)!;
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.addAccountFirst)),
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
          (widget.accounts.length > 1
              ? widget.accounts[1].id
              : widget.accounts.first.id);
      _categoryId = e.categoryId;
      _date = e.occurredAt;
      _amountCtrl.text = minorToBdtInput(e.amountMinor);
      _noteCtrl.text = e.note;
    } else {
      _kind = TxnKind.expense;
      _fromAccountId = widget.accounts.first.id;
      _toAccountId = widget.accounts.length > 1
          ? widget.accounts[1].id
          : widget.accounts.first.id;
      _pickDefaultCategory();
    }
  }

  void _pickDefaultCategory() {
    if (_kind == TxnKind.transfer) {
      _categoryId = null;
      return;
    }
    final want =
        _kind == TxnKind.income ? CategoryKind.income : CategoryKind.expense;
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
    final t = AppLocalizations.of(context)!;
    final wantCat =
        _kind == TxnKind.income ? CategoryKind.income : CategoryKind.expense;
    final filteredCats =
        widget.categories.where((c) => c.kind == wantCat).toList();

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
              _isEdit ? t.editTxnTitle : t.addTxnTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<TxnKind>(
              segments: [
                ButtonSegment(
                    value: TxnKind.expense, label: Text(t.kindExpense)),
                ButtonSegment(value: TxnKind.income, label: Text(t.kindIncome)),
                ButtonSegment(
                    value: TxnKind.transfer, label: Text(t.kindTransfer)),
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: t.amountLabel,
                hintText: t.amountHint,
              ),
            ),
            const SizedBox(height: 12),
            if (_kind != TxnKind.income)
              DropdownButtonFormField<String>(
                initialValue: _fromAccountId,
                decoration: InputDecoration(
                  labelText: _kind == TxnKind.transfer
                      ? t.fromAccountLabel
                      : t.accountLabel,
                ),
                items: widget.accounts
                    .map((a) =>
                        DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setState(() => _fromAccountId = v!),
              ),
            if (_kind == TxnKind.transfer) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _toAccountId,
                decoration: InputDecoration(labelText: t.toAccountLabel),
                items: widget.accounts
                    .map((a) =>
                        DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setState(() => _toAccountId = v!),
              ),
            ],
            if (_kind == TxnKind.income) ...[
              DropdownButtonFormField<String>(
                initialValue: _toAccountId,
                decoration: InputDecoration(labelText: t.accountLabel),
                items: widget.accounts
                    .map((a) =>
                        DropdownMenuItem(value: a.id, child: Text(a.name)))
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
                decoration: InputDecoration(labelText: t.categoryLabel),
                items: filteredCats
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(labelText: t.noteLabel),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.dateLabel),
              subtitle: Text(
                DateFormat.yMd(Localizations.localeOf(context).toString())
                    .format(_date.toLocal()),
              ),
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
              onPressed: () => _save(context),
              child: Text(_isEdit ? t.updateLabel : t.saveLabel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final minor = parseBdtToMinor(_amountCtrl.text);
    if (minor == null || minor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidAmount)),
      );
      return;
    }
    if (_kind == TxnKind.transfer && _fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.transferAccountsMustDiffer)),
      );
      return;
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
          SnackBar(content: Text(t.addCategoryFirst)),
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
    ref.invalidate(monthExpenseByCategoryProvider);
    ref.invalidate(monthSpentProvider);
    if (context.mounted) Navigator.pop(context);
  }
}
