import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendemas/data/database.dart';
import 'package:vendemas/data/lan_sync.dart';
import 'package:vendemas/main.dart';
import 'package:vendemas/providers.dart';

void main() {
  testWidgets('acceso → bienvenida → vender → cobrar → cerrar sesión', (t) async {
    t.view.physicalSize = const Size(900, 2000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await initializeDateFormatting('es_MX');
    debugForceMobile = true;
    addTearDown(() => debugForceMobile = false);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());

    // La base y el hash usan E/S real: se deja pasar tiempo real entre pasos.
    Future<void> settle() async {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 400));
    }

    Future<void> waitFor(Finder f) async {
      for (var i = 0; i < 100; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await t.pump(const Duration(milliseconds: 100));
        if (f.evaluate().isNotEmpty) return;
      }
      fail('No apareció $f');
    }

    await t.runAsync(() => db.addProduct(
        name: 'Concha', priceCents: 1500, costCents: 650, initialStock: 10));

    await t.pumpWidget(ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        lanServerProvider.overrideWithValue(null),
      ],
      child: const VendeMasApp(),
    ));
    await settle();

    // F-24: acceso con número.
    expect(find.text('Entra a VendeMas'), findsOneWidget);
    await t.enterText(find.byType(TextField), '229123');
    await t.tap(find.text('Entrar'));
    await settle();
    expect(find.text('Escribe tu número de 10 dígitos.'), findsOneWidget);
    await t.enterText(find.byType(TextField), '2291234567');
    await t.tap(find.text('Entrar'));
    await waitFor(find.text('Bienvenido a VendeMas'));
    expect(prefs.getString('remember.last4'), '4567');
    expect(prefs.getKeys().any((k) => prefs.get(k) == '2291234567'), isFalse);

    // F-01: sin nombre no avanza.
    await t.tap(find.text('Empezar'));
    await settle();
    expect(find.text('Escribe el nombre de tu negocio.'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'La Espiga');
    await t.tap(find.text('Empezar'));
    await settle();
    expect(find.text('La Espiga'), findsOneWidget);

    // F-03
    await t.tap(find.text('Nueva venta'));
    await settle();
    await t.tap(find.text('Concha'));
    await t.tap(find.text('Concha'));
    await settle();
    expect(find.text(r'$30'), findsOneWidget);
    await t.tap(find.text('Cobrar'));
    await settle();

    // F-04: el botón está bloqueado hasta que alcance el monto.
    FilledButton confirm() =>
        t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Confirmar cobro'));
    expect(confirm().onPressed, isNull);
    await t.enterText(find.widgetWithText(TextField, 'Monto recibido'), '20');
    await t.pump();
    expect(find.text('Faltan'), findsOneWidget);
    expect(confirm().onPressed, isNull);
    await t.tap(find.text(r'$50'));
    await t.pump();
    expect(find.text(r'$20.00'), findsOneWidget); // cambio
    await t.tap(find.text('Confirmar cobro'));
    await settle();

    // F-05
    expect(find.text('Venta registrada'), findsOneWidget);
    expect(find.textContaining('Ganaste \$17'), findsOneWidget);
    final moves = await t.runAsync(() => db.select(db.stockMovements).get());
    expect(moves!.fold<int>(0, (a, m) => a + m.delta), 8);

    // F-20 y F-22: Ajustes y cerrar sesión.
    await t.tap(find.text('Ir al inicio'));
    await settle();
    await t.tap(find.byTooltip('Ajustes'));
    await settle();
    expect(find.text('•• •••• 4567'), findsOneWidget);
    await t.tap(find.text('Cerrar sesión'));
    await settle();
    await t.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await settle();

    // Usuario recordado.
    expect(find.text('Entra a VendeMas'), findsOneWidget);
    expect(find.text('•• •••• 4567'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);

    // Cierra streams de drift antes de terminar.
    await t.pumpWidget(const SizedBox());
    await settle();
  });
}
