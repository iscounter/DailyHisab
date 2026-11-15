import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1B6B4A), brightness: Brightness.light);
  return ThemeData(colorScheme: scheme, useMaterial3: true);
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1B6B4A), brightness: Brightness.dark);
  return ThemeData(colorScheme: scheme, useMaterial3: true);
}
