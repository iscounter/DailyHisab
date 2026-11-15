import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(title: Text('Currency'), subtitle: Text('BDT (৳) — fixed in v1')),
          ListTile(title: Text('Theme'), subtitle: Text('Follows system (Light/Dark)')),
          ListTile(title: Text('About'), subtitle: Text('DailyHisab — offline-first personal finance (MVP scaffold evolved)')),
        ],
      ),
    );
  }
}
