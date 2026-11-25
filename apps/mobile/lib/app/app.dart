import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bootstrap_provider.dart';
import '../data/settings_providers.dart';
import '../l10n/generated/app_localizations.dart';
import '../routing/app_router.dart';
import 'theme.dart';

class DailyHisabApp extends ConsumerWidget {
  const DailyHisabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final boot = ref.watch(appBootstrapProvider);
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(appLanguageProvider);

    final Locale? locale;
    switch (language) {
      case AppLanguage.system:
        locale = null;
      case AppLanguage.english:
        locale = const Locale('en');
      case AppLanguage.bangla:
        locale = const Locale('bn');
    }

    return MaterialApp.router(
      title: 'DailyHisab',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        return boot.when(
          data: (_) => child ?? const SizedBox.shrink(),
          loading: () =>
              const _BootScaffold(child: CircularProgressIndicator()),
          error: (e, _) => _BootScaffold(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppLocalizations.of(context)!.appStartupError(
                e.toString(),
              )),
            ),
          ),
        );
      },
    );
  }
}

class _BootScaffold extends StatelessWidget {
  const _BootScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }
}
