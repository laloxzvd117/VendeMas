import 'package:flutter_test/flutter_test.dart';
import 'package:vendemas/domain/reports.dart';

/// Escenario fijo. Hoy = miércoles 4 de noviembre de 2026, 12:00.
ReportData scenario() {
  final now = DateTime(2026, 11, 4, 12);
  ProductRow p(String id, String name, int price, int cost, bool track, DateTime at) =>
      ProductRow(
          id: id,
          name: name,
          priceCents: price,
          costCents: cost,
          trackStock: track,
          minStock: 3,
          createdAt: at);
  final products = [
    p('a', 'Concha', 1500, 650, true, DateTime(2026, 1, 1)),
    p('b', 'Café', 2500, 700, false, DateTime(2026, 1, 1)),
    p('c', 'Pan integral', 4000, 1600, true, DateTime(2026, 9, 1)),
    p('d', 'Galleta', 1200, 500, true, DateTime(2026, 10, 1)),
  ];
  final byId = {for (final x in products) x.id: x};

  final sales = <SaleRow>[];
  final items = <ItemRow>[];
  void sale(String id, DateTime at, List<(String, int)> lines) {
    var total = 0;
    var profit = 0;
    for (final (pid, qty) in lines) {
      final prod = byId[pid]!;
      items.add(ItemRow(
          saleId: id,
          productId: pid,
          qty: qty,
          unitPriceCents: prod.priceCents,
          unitCostCents: prod.costCents));
      total += qty * prod.priceCents;
      profit += qty * (prod.priceCents - prod.costCents);
    }
    sales.add(SaleRow(id: id, createdAt: at, totalCents: total, profitCents: profit));
  }

  sale('s1', DateTime(2026, 11, 4, 8, 10), [('a', 2), ('b', 1)]);
  sale('s2', DateTime(2026, 11, 4, 9, 5), [('a', 1), ('b', 1)]);
  sale('s3', DateTime(2026, 11, 3, 17, 30), [('a', 3)]);
  sale('s4', DateTime(2026, 10, 28, 11), [('b', 2)]);
  sale('s5', DateTime(2026, 10, 10, 10), [('c', 1)]);

  return ReportData(
    sales: sales,
    items: items,
    products: products,
    stock: const {'a': 40, 'c': 12, 'd': 5},
    now: now,
  );
}

void main() {
  final d = scenario();

  test('ventas por producto y rankings (RF-12)', () {
    final stats = productStats(d);
    expect(stats.length, 3);
    expect(rankByUnits(stats).map((s) => s.name), ['Concha', 'Café', 'Pan integral']);
    expect(rankByProfit(stats).map((s) => s.name), ['Café', 'Concha', 'Pan integral']);
    final concha = stats.firstWhere((s) => s.id == 'a');
    expect(concha.units, 6);
    expect(concha.revenue, 9000);
    expect(concha.profit, 5100);
  });

  test('clasificación ABC por ganancia (RF-13)', () {
    final abc = abcAnalysis(productStats(d));
    expect(abc.rows.map((r) => r.grade), ['A', 'A', 'B']);
    expect(abc.countA, 2);
    expect(abc.shareA.round(), 84);
    expect(abcAnalysis(const []).isEmpty, isTrue);
  });

  test('margen y rotación en cuatro grupos (RF-14)', () {
    final q = quadrants(productStats(d));
    expect(q.busy.map((s) => s.name), ['Concha']);
    expect(q.stars.map((s) => s.name), ['Café']);
    expect(q.gems.map((s) => s.name), ['Pan integral']);
    expect(q.review, isEmpty);
    expect(q.minUnits, 4);
    expect(q.minUnitProfit, 1683);
  });

  test('productos muertos e inmovilizado (RF-15)', () {
    final dead = deadProducts(d);
    expect(dead.map((x) => x.product.name), ['Pan integral', 'Galleta']);
    expect(dead.first.trappedCents, 12 * 1600);
    expect(dead.first.daysIdle, 25);
    expect(dead.first.neverSold, isFalse);
    expect(dead.last.neverSold, isTrue);
    expect(deadTotal(dead), 19200 + 2500);
  });

  test('horas y días fuertes (RF-16)', () {
    final h = hoursReport(d);
    expect(h.peakHour, 8);
    expect(h.strongRanges, [(8, 12), (17, 18)]);
    expect(h.bestWeekday, 2); // miércoles
    expect(h.byWeekday[2], 14500);
  });

  test('se venden juntos y combo (RF-17)', () {
    final r = pairsReport(d);
    expect(r.rows.length, 1);
    expect(r.rows.first.nameA, 'Concha');
    expect(r.rows.first.nameB, 'Café');
    expect(r.rows.first.together, 2);
    expect(r.rows.first.percent, 67);
    expect(r.combo?.normalCents, 4000);
    expect(r.combo?.comboCents, 3600);
  });

  test('tendencias frente a la semana anterior (RF-18)', () {
    final t = trendsReport(d);
    expect(t.length, 1);
    expect(t.first.name, 'Concha');
    expect(t.first.current, 6);
    expect(t.first.previous, 0);
    expect(t.first.percent, 100);
  });

  test('resumen semanal e historial de 8 semanas (RF-19)', () {
    final weeks = lastWeeks(d);
    expect(weeks.length, 8);
    final cur = weeks.last;
    expect(cur.isCurrent, isTrue);
    expect(cur.start, DateTime(2026, 11, 2));
    expect(cur.sales, 14000);
    expect(cur.profit, 8700);
    expect(cur.tickets, 3);
    expect(cur.previousSales, 5000);
    expect(cur.percent, 180);
    expect(cur.days[1].sales, 4500);
    expect(cur.bestDay.day, DateTime(2026, 11, 4));
    expect(weeks[6].sales, 5000);
    expect(weeks[3].sales, 4000);
    expect(weeks[3].percent, isNull);
    expect(weeks[3].isCurrent, isFalse);
  });

  test('cuánto alcanza lo que hay (RF-09)', () {
    expect(coverText(stock: 30, unitsLast30: 30), 'alcanza ~30 días');
    expect(coverText(stock: 0, unitsLast30: 30), 'alcanza menos de 1 día');
    expect(coverText(stock: 5, unitsLast30: 0), 'sin ventas recientes');
  });

  test('sin ventas, nada truena', () {
    final e = ReportData.empty(DateTime(2026, 11, 4));
    expect(productStats(e), isEmpty);
    expect(deadProducts(e), isEmpty);
    expect(hoursReport(e).isEmpty, isTrue);
    expect(pairsReport(e).rows, isEmpty);
    expect(trendsReport(e), isEmpty);
    expect(lastWeeks(e).last.hasSales, isFalse);
  });
}
