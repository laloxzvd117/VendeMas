import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/platform.dart';
import 'core/theme.dart';
import 'features/desktop/desktop_shell.dart';
import 'features/login/login_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers.dart';
import 'router.dart';

export 'core/platform.dart' show debugForceMobile, isDesktop;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const VendeMasApp(),
  ));
}

class VendeMasApp extends ConsumerWidget {
  const VendeMasApp({super.key});

  static const _locale = Locale('es', 'MX');
  static const _delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  MaterialApp _app(Widget home, {String title = 'VendeMas'}) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        locale: _locale,
        supportedLocales: const [_locale],
        localizationsDelegates: _delegates,
        home: home,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session == null) return _app(const LoginScreen());

    // La computadora solo consulta: el nombre llega del celular.
    if (isDesktop) {
      return _app(const DesktopShell(), title: 'VendeMas · Consulta de reportes');
    }

    final name = ref.watch(businessNameProvider);
    if (name.isLoading && !name.hasValue) {
      return _app(const Scaffold(body: Center(child: CircularProgressIndicator())));
    }
    if (name.value == null) return _app(const OnboardingScreen());

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VendeMas',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: _locale,
      supportedLocales: const [_locale],
      localizationsDelegates: _delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
