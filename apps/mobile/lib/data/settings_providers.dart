import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory theme mode, persisted to SharedPreferences on change.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme_mode', mode.name);
}

/// In-app language preference; `system` follows the device locale.
enum AppLanguage { system, english, bangla }

final appLanguageProvider =
    StateProvider<AppLanguage>((ref) => AppLanguage.system);

Future<void> saveAppLanguage(AppLanguage language) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_language', language.name);
}
