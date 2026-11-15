import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bootstrap_provider.dart';
import 'theme.dart';
import '../routing/app_router.dart';

class DailyHisabApp extends ConsumerWidget {
  const DailyHisabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final boot = ref.watch(appBootstrapProvider);
    return MaterialApp.router(
      title: 'DailyHisab',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return boot.when(
          data: (_) => child ?? const SizedBox.shrink(),
          loading: () => const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
          error: (e, _) => MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Startup error: $e'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
