import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final modeStr = prefs.getString('theme_mode');
  final initial = ThemeMode.values.firstWhere(
    (m) => m.name == modeStr,
    orElse: () => ThemeMode.system,
  );
  runApp(
    ProviderScope(
      overrides: [themeModeProvider.overrideWith((ref) => initial)],
      child: const DailyHisabApp(),
    ),
  );
}