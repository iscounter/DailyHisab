import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/app_providers.dart';
import '../../../data/drift/app_database.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdd(context, ref),
        child: const Icon(Icons.add),
      ),
      body: accounts.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No accounts yet. Add Cash, Bank, or Wallet.')));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = list[i];
              return ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(a.name),
                subtitle: Text(a.kind.name),
                trailing: IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () async {
                    await ref.read(accountsRepositoryProvider).archive(a.id);
                  },
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

  Future<void> _showAdd(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    AccountKind kind = AccountKind.cash;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Cash, bKash')),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountKind>(
                initialValue: kind,
                decoration: const InputDecoration(labelText: 'Type'),
                items: AccountKind.values.map((k) => DropdownMenuItem(value: k, child: Text(k.name))).toList(),
                onChanged: (v) => setS(() => kind = v ?? AccountKind.cash),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final n = nameCtrl.text.trim();
                if (n.isEmpty) return;
                await ref.read(accountsRepositoryProvider).create(name: n, kind: kind);
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
