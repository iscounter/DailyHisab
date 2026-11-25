import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final modeStr = prefs.getString('theme_mode');
  final initialTheme = ThemeMode.values.firstWhere(
    (m) => m.name == modeStr,
    orElse: () => ThemeMode.system,
  );
  final langStr = prefs.getString('app_language');
  final initialLanguage = AppLanguage.values.firstWhere(
    (l) => l.name == langStr,
    orElse: () => AppLanguage.system,
  );

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => initialTheme),
        appLanguageProvider.overrideWith((ref) => initialLanguage),
      ],
      child: const DailyHisabApp(),
    ),
  );
}
