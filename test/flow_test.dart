import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendemas/data/database.dart';
import 'package:vendemas/main.dart';
import 'package:vendemas/providers.dart';

void main() {
  testWidgets('onboarding → vender → cobrar → venta registrada', (t) async {
    t.view.physicalSize = const Size(900, 2000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await initializeDateFormatting('es_MX');
    debugForceMobile = true;
    addTearDown(() => debugForceMobile = false);
    final db = AppDatabase(NativeDatabase.memory());
    // La base usa E/S real: se deja pasar tiempo real entre pasos.
    Future<void> settle() async {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 400));
    }

    await t.runAsync(() => db.addProduct(
        name: 'Concha', priceCents: 1500, costCents: 650, initialStock: 10));

    await t.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const VendeMasApp(),
    ));
    await settle();

    // F-01: sin nombre no avanza.
    expect(find.text('Bienvenido a VendeMas'), findsOneWidget);
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

    // Cierra streams de drift antes de terminar.
    await t.pumpWidget(const SizedBox());
    await settle();
  });
}
