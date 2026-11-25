import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/backup/backup_codec.dart';
import '../../../data/app_providers.dart';
import '../../../data/settings_providers.dart';
import '../../../l10n/generated/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final mode = ref.watch(themeModeProvider);
    final language = ref.watch(appLanguageProvider);
    final currency = ref.watch(currencyCodeProvider).valueOrNull ?? 'BDT';

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.currency_exchange),
            title: Text(t.currencyTitle),
            subtitle: Text(t.currencySubtitle(currency)),
          ),
          const SizedBox(height: 8),
          Text(t.themeTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                  value: ThemeMode.system, label: Text(t.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(t.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(t.themeDark)),
            ],
            selected: {mode},
            onSelectionChanged: (s) {
              final v = s.first;
              ref.read(themeModeProvider.notifier).state = v;
              saveThemeMode(v);
            },
          ),
          const SizedBox(height: 16),
          Text(t.languageTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<AppLanguage>(
            segments: [
              ButtonSegment(
                  value: AppLanguage.system, label: Text(t.langSystem)),
              ButtonSegment(
                  value: AppLanguage.english, label: Text(t.langEnglish)),
              ButtonSegment(
                  value: AppLanguage.bangla, label: Text(t.langBangla)),
            ],
            selected: {language},
            onSelectionChanged: (s) {
              final v = s.first;
              ref.read(appLanguageProvider.notifier).state = v;
              saveAppLanguage(v);
            },
          ),
          const SizedBox(height: 16),
          Text(
            t.backupSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: Text(t.exportBackup),
              subtitle: Text(t.exportBackupSubtitle),
              onTap: () => _exportBackup(context, ref),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: Text(t.restoreBackup),
              subtitle: Text(t.restoreBackupSubtitle),
              onTap: () => _restoreBackup(context, ref),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(t.aboutTitle),
            subtitle: Text(t.aboutSubtitle),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tag),
            title: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                final version = snap.data?.version ?? '1.0.0';
                return Text(t.versionLabel(version));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(backupRepositoryProvider);
      final content = await repo.exportContent();
      final json = repo.exportToJson(content);

      final dir = await getTemporaryDirectory();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final file = File(
          '${dir.path}${Platform.pathSeparator}DailyHisab-backup-$date.json');
      await file.writeAsString(json, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: t.backupShareText(date),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.backupExportFailed(e.toString()))),
      );
    }
  }

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = files.isEmpty ? null : files.first.path;
    if (path == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final BackupContent content;
    try {
      content = BackupCodec.decode(await File(path).readAsString());
    } on BackupFormatException {
      messenger.showSnackBar(SnackBar(content: Text(t.invalidBackup)));
      return;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.restoreFailed(e.toString()))),
      );
      return;
    }
    if (!context.mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.restoreConfirmTitle),
        content: Text(t.restoreConfirmMessage(
          content.countOfAccounts,
          content.countOfCategories,
          content.countOfTransactions,
          content.countOfBudgets,
          content.countOfGoals,
        )),
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
            child: Text(t.restoreBackup),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;

    try {
      await ref.read(backupRepositoryProvider).restoreContent(content);
      // Refresh every derived value after the full replace.
      ref.invalidate(totalBalanceProvider);
      ref.invalidate(monthSummaryProvider);
      ref.invalidate(accountBalancesProvider);
      ref.invalidate(monthExpenseByCategoryProvider);
      ref.invalidate(monthSpentProvider);
      ref.invalidate(currencyCodeProvider);
      ref.invalidate(recentTransactionsProvider);
      messenger.showSnackBar(SnackBar(content: Text(t.restoreSuccess)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.restoreFailed(e.toString()))),
      );
    }
  }
}
