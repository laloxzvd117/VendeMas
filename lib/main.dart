import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  runApp(const ProviderScope(child: VendeMasApp()));
}

class VendeMasApp extends ConsumerWidget {
  const VendeMasApp({super.key});

  static const _locale = Locale('es', 'MX');
  static const _delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(businessNameProvider);
    final light = buildTheme(Brightness.light);
    final dark = buildTheme(Brightness.dark);

    // Primer inicio: sin negocio solo se muestra la bienvenida (F-01).
    if (name.isLoading) {
      return MaterialApp(
        theme: light,
        darkTheme: dark,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (name.value == null) {
      return MaterialApp(
        title: 'VendeMas',
        theme: light,
        darkTheme: dark,
        locale: _locale,
        supportedLocales: const [_locale],
        localizationsDelegates: _delegates,
        home: const OnboardingScreen(),
      );
    }
    return MaterialApp.router(
      title: 'VendeMas',
      theme: light,
      darkTheme: dark,
      locale: _locale,
      supportedLocales: const [_locale],
      localizationsDelegates: _delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
