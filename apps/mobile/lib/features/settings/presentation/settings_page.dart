import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Currency'),
            subtitle: Text('BDT (৳) — fixed in v1'),
          ),
          const SizedBox(height: 8),
          Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {mode},
            onSelectionChanged: (s) {
              final v = s.first;
              ref.read(themeModeProvider.notifier).state = v;
              saveThemeMode(v);
            },
          ),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('About'),
            subtitle: Text('DailyHisab — offline-first personal finance (BDT, integer poisha)'),
          ),
        ],
      ),
    );
  }
}