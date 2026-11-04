import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendemas/data/database.dart';
import 'package:vendemas/domain/calculations.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('alta de producto con y sin existencias (RF-03)', () async {
    await db.addProduct(name: 'Concha', priceCents: 1500, costCents: 650, initialStock: 40);
    await db.addProduct(name: 'Café', priceCents: 2500, costCents: 700);
    final list = await db.watchProducts().first;
    expect(list.map((p) => p.product.name), ['Café', 'Concha']);
    final concha = list.firstWhere((p) => p.product.name == 'Concha');
    final cafe = list.firstWhere((p) => p.product.name == 'Café');
    expect(concha.tracked, isTrue);
    expect(concha.stock, 40);
    expect(cafe.tracked, isFalse);
  });

  test('venta descuenta existencias solo de productos con control (RF-09)', () async {
    await db.addProduct(name: 'Concha', priceCents: 1500, costCents: 650, initialStock: 5);
    await db.addProduct(name: 'Café', priceCents: 2500, costCents: 700);
    final ps = await db.watchProducts().first;
    final concha = ps.firstWhere((p) => p.product.name == 'Concha');
    final cafe = ps.firstWhere((p) => p.product.name == 'Café');

    LineItem line(ProductView p, int q) => LineItem(
        productId: p.product.id,
        name: p.product.name,
        qty: q,
        unitPrice: p.product.priceCents,
        unitCost: p.product.costCents);

    final sale = await db.recordSale(
      items: [line(concha, 2), line(cafe, 1)],
      receivedCents: 10000,
      trackedIds: {concha.product.id},
    );
    expect(sale.totalCents, 5500);
    expect(sale.profitCents, 2 * 850 + 1800);
    expect(sale.summary, '2 × Concha, 1 × Café');

    final after = await db.watchProducts().first;
    expect(after.firstWhere((p) => p.product.name == 'Concha').stock, 3);

    final today = await db.watchToday().first;
    expect(today.sales, 5500);
    expect(today.tickets, 1);
  });

  test('nombre del negocio', () async {
    expect(await db.watchBusinessName().first, isNull);
    await db.setBusinessName('La Espiga');
    expect(await db.watchBusinessName().first, 'La Espiga');
  });
}
