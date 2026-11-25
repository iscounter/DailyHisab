import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final accounts = ref.watch(accountsStreamProvider);
    final archived = ref.watch(archivedAccountsStreamProvider);
    final balances = ref.watch(accountBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.accountsTitle)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'account-add',
        onPressed: () => _showAdd(context, ref),
        child: const Icon(Icons.add),
      ),
      body: accounts.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyStateView(
              icon: Icons.account_balance_wallet_outlined,
              message: t.noAccountsYet,
            );
          }
          final archivedList = archived.valueOrNull ?? const <Account>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final a in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AccountCard(
                    account: a,
                    balance:
                        balances.valueOrNull?[a.id] ?? a.openingBalanceMinor,
                    onArchive: () => _confirmArchive(context, ref, a),
                  ),
                ),
              if (archivedList.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${t.archivedSection} (${archivedList.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                for (final a in archivedList)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AccountCard(
                      account: a,
                      balance:
                          balances.valueOrNull?[a.id] ?? a.openingBalanceMinor,
                      archived: true,
                      onUnarchive: () => _unarchive(context, ref, a),
                    ),
                  ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(details: e.toString()),
      ),
    );
  }

  Future<void> _confirmArchive(
      BuildContext context, WidgetRef ref, Account a) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.archiveConfirmTitle),
        content: Text(t.archiveConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.archiveTooltip),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(accountsRepositoryProvider).archive(a.id);
      ref.invalidate(totalBalanceProvider);
      ref.invalidate(accountBalancesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.accountArchived)));
      }
    }
  }

  Future<void> _unarchive(
      BuildContext context, WidgetRef ref, Account a) async {
    final t = AppLocalizations.of(context)!;
    await ref.read(accountsRepositoryProvider).unarchive(a.id);
    ref.invalidate(totalBalanceProvider);
    ref.invalidate(accountBalancesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.accountRestored)));
    }
  }

  Future<void> _showAdd(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final openingCtrl = TextEditingController(text: '0');
    AccountKind kind = AccountKind.cash;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return AlertDialog(
              title: Text(t.addAccountTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: t.accountNameLabel,
                      hintText: t.accountNameHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AccountKind>(
                    initialValue: kind,
                    decoration: InputDecoration(labelText: t.accountTypeLabel),
                    items: [
                      DropdownMenuItem(
                          value: AccountKind.cash, child: Text(t.kindCash)),
                      DropdownMenuItem(
                          value: AccountKind.bank, child: Text(t.kindBank)),
                      DropdownMenuItem(
                          value: AccountKind.wallet, child: Text(t.kindWallet)),
                      DropdownMenuItem(
                          value: AccountKind.other, child: Text(t.kindOther)),
                    ],
                    onChanged: (v) => setS(() => kind = v ?? AccountKind.cash),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: openingCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration:
                        InputDecoration(labelText: t.openingBalanceLabel),
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
                    final raw = openingCtrl.text.trim();
                    final openingMinor = raw.isEmpty ? 0 : parseBdtToMinor(raw);
                    if (openingMinor == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(t.invalidOpeningBalance)),
                      );
                      return;
                    }
                    await ref.read(accountsRepositoryProvider).create(
                          name: n,
                          kind: kind,
                          openingBalanceMinor: openingMinor,
                        );
                    ref.invalidate(totalBalanceProvider);
                    ref.invalidate(accountBalancesProvider);
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
    openingCtrl.dispose();
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.balance,
    this.archived = false,
    this.onArchive,
    this.onUnarchive,
  });

  final Account account;
  final int balance;
  final bool archived;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final kindName = switch (account.kind) {
      AccountKind.cash => t.kindCash,
      AccountKind.bank => t.kindBank,
      AccountKind.wallet => t.kindWallet,
      AccountKind.other => t.kindOther,
    };
    return Card(
      child: ListTile(
        leading: Icon(
          archived
              ? Icons.archive_outlined
              : Icons.account_balance_wallet_outlined,
          semanticLabel: kindName,
        ),
        title: Text(account.name),
        subtitle: Text(
          t.accountSubtitle(kindName, formatBdtMinor(balance)),
        ),
        trailing: archived
            ? IconButton(
                tooltip: t.unarchiveTooltip,
                icon: const Icon(Icons.unarchive_outlined),
                onPressed: onUnarchive,
              )
            : IconButton(
                tooltip: t.archiveTooltip,
                icon: const Icon(Icons.archive_outlined),
                onPressed: onArchive,
              ),
      ),
    );
  }
}
