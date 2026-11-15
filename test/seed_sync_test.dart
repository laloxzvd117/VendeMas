import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendemas/data/database.dart';
import 'package:vendemas/data/lan_sync.dart';
import 'package:vendemas/data/report_source.dart';
import 'package:vendemas/data/seed.dart';
import 'package:vendemas/data/sync_data.dart';
import 'package:vendemas/domain/calculations.dart';
import 'package:vendemas/domain/reports.dart';

void main() {
  late AppDatabase phone;
  late AppDatabase desktop;
  setUp(() {
    phone = AppDatabase(NativeDatabase.memory());
    desktop = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await phone.close();
    await desktop.close();
  });

  test('la semilla llena todos los reportes', () async {
    final r = await phone.seedDemoData();
    expect(r.products, 20);
    expect(r.sales, greaterThan(1000));
    expect(await phone.watchBusinessName().first, 'Abarrotes Doña Lupe');

    final d = await phone.loadReportData();
    final stats = productStats(d);
    expect(abcAnalysis(stats).countA, greaterThan(0));
    expect(quadrants(stats).isEmpty, isFalse);
    expect(deadProducts(d).map((x) => x.product.name), contains('Atún en lata'));
    expect(hoursReport(d).strongRanges, isNotEmpty);
    final pairs = pairsReport(d);
    expect(pairs.rows, isNotEmpty);
    expect(pairs.combo, isNotNull);
    final trends = trendsReport(d);
    expect(trends.any((t) => t.name == 'Gansito' && t.percent > 0), isTrue);
    expect(lastWeeks(d).take(7).every((w) => w.hasSales), isTrue);

    final products = await phone.watchProducts().first;
    expect(products.any((p) => p.isLow || p.isOut), isTrue);
    expect(products.every((p) => !p.tracked || p.stock >= 0), isTrue);

    await expectLater(phone.seedDemoData(), throwsStateError);
  });

  test('importar dos veces no duplica (RNF-06)', () async {
    await phone.seedDemoData();
    final data = await phone.exportAll();
    await desktop.importAll(data);
    await desktop.importAll(data);
    expect(await desktop.syncVersion(), await phone.syncVersion());
    final a = await phone.loadReportData();
    final b = await desktop.loadReportData();
    expect(b.sales.length, a.sales.length);
    expect(b.items.length, a.items.length);
    expect(b.stock, a.stock);
  });

  test('la computadora copia los datos del celular por la red', () async {
    await phone.setBusinessName('La Espiga');
    await phone.addProduct(
        name: 'Concha', priceCents: 1500, costCents: 650, initialStock: 10);
    final server = LanServer(db: phone, accountId: 'cuenta-1', port: 0);
    await server.start(discovery: false);
    addTearDown(server.stop);
    final port = server.boundPort!;

    final client = LanClient(accountId: 'cuenta-1', db: desktop);
    final v1 = await client.pull('127.0.0.1', port: port);
    expect(await desktop.watchBusinessName().first, 'La Espiga');
    expect((await desktop.watchProducts().first).single.stock, 10);

    // Una venta nueva en el celular llega en la siguiente revisión.
    final p = (await phone.watchProducts().first).single;
    await phone.recordSale(
      items: [
        LineItem(
            productId: p.product.id,
            name: 'Concha',
            qty: 2,
            unitPrice: 1500,
            unitCost: 650)
      ],
      receivedCents: 5000,
      trackedIds: {p.product.id},
    );
    final v2 = await client.pull('127.0.0.1', port: port, lastVersion: v1);
    expect(v2, isNot(v1));
    expect((await desktop.watchProducts().first).single.stock, 8);
    expect(server.status.value.lastClient, isNotNull);

    // Otra cuenta no puede leer estos datos.
    final other = LanClient(accountId: 'cuenta-2', db: desktop);
    await expectLater(other.pull('127.0.0.1', port: port), throwsA(isA<SyncError>()));
  });
}
