import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendemas/data/database.dart';
import 'package:vendemas/data/report_source.dart';
import 'package:vendemas/data/stock_ops.dart';
import 'package:vendemas/domain/calculations.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<ProductView> only() async => (await db.watchProducts().first).single;

  test('activar, entrada, conteo y desactivar existencias (RF-10)', () async {
    await db.addProduct(name: 'Café', priceCents: 2500, costCents: 700);
    var p = await only();
    expect(p.tracked, isFalse);

    await db.enableStock(p.product.id, 10);
    p = await only();
    expect(p.tracked, isTrue);
    expect(p.stock, 10);

    await db.receiveStock(p.product.id, 5);
    expect((await only()).stock, 15);

    await db.countStock(p.product.id, 12);
    expect((await only()).stock, 12);

    await db.disableStock(p.product.id);
    expect((await only()).tracked, isFalse);
  });

  test('una entrada de cero o negativa no mueve nada', () async {
    await db.addProduct(
        name: 'Concha', priceCents: 1500, costCents: 650, initialStock: 4);
    final p = await only();
    await db.receiveStock(p.product.id, 0);
    await db.receiveStock(p.product.id, -3);
    expect((await only()).stock, 4);
  });

  test('los reportes leen ventas y existencias de la base', () async {
    await db.addProduct(
        name: 'Concha', priceCents: 1500, costCents: 650, initialStock: 10);
    final p = await only();
    await db.recordSale(
      items: [
        LineItem(
            productId: p.product.id,
            name: 'Concha',
            qty: 2,
            unitPrice: 1500,
            unitCost: 650)
      ],
      receivedCents: 3000,
      trackedIds: {p.product.id},
    );
    final data = await db.loadReportData();
    expect(data.sales.length, 1);
    expect(data.items.single.qty, 2);
    expect(data.stock[p.product.id], 8);
    expect(data.hasSales, isTrue);
  });
}
