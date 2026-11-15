import 'dart:math';

import 'package:drift/drift.dart';

import 'database.dart';

/// Producto de la semilla: [weight] es qué tan seguido se vende.
class _P {
  const _P(this.name, this.price, this.cost, this.weight,
      {this.track = true, this.min = 4});
  final String name;
  final int price;
  final int cost;
  final double weight;
  final bool track;
  final int min;
}

const _catalog = [
  _P('Coca-Cola 600 ml', 2200, 1600, 14, min: 10),
  _P('Sabritas 45 g', 2000, 1450, 8, min: 8),
  _P('Leche Lala 1 L', 3200, 2600, 10, min: 6),
  _P('Pan Bimbo blanco', 5200, 4200, 5),
  _P('Huevo 1 kg', 4800, 3700, 7, min: 5),
  _P('Tortillas 1 kg', 2400, 1800, 12, track: false),
  _P('Galletas Marías', 1800, 1200, 5),
  _P('Agua Ciel 1 L', 1500, 800, 9, min: 8),
  _P('Jabón Zote', 2600, 1900, 3, min: 3),
  _P('Papel higiénico 4 rollos', 4200, 3300, 3, min: 3),
  _P('Atún en lata', 2800, 2100, 0),
  _P('Cloro 1 L', 2200, 1500, 2, min: 3),
  _P('Café soluble 120 g', 6500, 4200, 1.5, min: 2),
  _P('Frijol 1 kg', 4000, 3200, 3),
  _P('Arroz 1 kg', 3200, 2500, 3),
  _P('Aceite 1 L', 4800, 3900, 2.5, min: 3),
  _P('Refresco 2 L', 3800, 3150, 9, min: 6),
  _P('Detergente 1 kg', 3900, 3000, 3, min: 3),
  _P('Gansito', 1600, 1100, 4, min: 6),
  _P('Chicles', 500, 250, 4, track: false),
];

/// Productos que suelen ir juntos: (si lleva, también lleva, probabilidad).
const _pairs = [
  ('Coca-Cola 600 ml', 'Sabritas 45 g', 0.5),
  ('Pan Bimbo blanco', 'Leche Lala 1 L', 0.45),
  ('Huevo 1 kg', 'Tortillas 1 kg', 0.4),
];

/// Se acaban al final para que se vean los avisos de existencias.
const _lowAtEnd = {
  'Leche Lala 1 L': 6,
  'Huevo 1 kg': 9,
  'Pan Bimbo blanco': 14,
};

const _hourWeights = {
  7: 4, 8: 9, 9: 8, 10: 5, 11: 4, 12: 5, 13: 7, 14: 6,
  15: 4, 16: 4, 17: 5, 18: 8, 19: 9, 20: 7, 21: 3,
};

/// Lunes a domingo.
const _dayFactor = [0.9, 0.85, 0.9, 0.95, 1.1, 1.35, 1.0];

const seedDays = 63;

class SeedResult {
  const SeedResult(this.products, this.sales);
  final int products;
  final int sales;
}

/// Datos de ejemplo de una tienda de abarrotes: 9 semanas de ventas.
/// Solo se cargan en una cuenta sin ventas.
extension Seed on AppDatabase {
  Future<bool> hasSales() async =>
      (await (select(sales)..limit(1)).get()).isNotEmpty;

  Future<SeedResult> seedDemoData({DateTime? now, int seed = 7}) async {
    if (await hasSales()) {
      throw StateError('Esta cuenta ya tiene ventas.');
    }
    final at = now ?? DateTime.now();
    final rnd = Random(seed);
    final today = DateTime(at.year, at.month, at.day);
    final first = DateTime(today.year, today.month, today.day - (seedDays - 1));

    final productRows = <ProductsCompanion>[];
    final saleRows = <SalesCompanion>[];
    final itemRows = <SaleItemsCompanion>[];
    final moveRows = <StockMovementsCompanion>[];

    final ids = <String, String>{};
    final byName = {for (final p in _catalog) p.name: p};
    final stock = <String, int>{};
    int capacity(_P p) => max(p.min * 3, (p.weight * 6).round() + 6);

    final created = DateTime(first.year, first.month, first.day - 1, 7);
    for (final p in _catalog) {
      final id = newId();
      ids[p.name] = id;
      productRows.add(ProductsCompanion.insert(
        id: id,
        name: p.name,
        priceCents: p.price,
        costCents: p.cost,
        trackStock: Value(p.track),
        minStock: Value(p.min),
        createdAt: created,
      ));
      if (p.track) {
        stock[p.name] = capacity(p);
        moveRows.add(StockMovementsCompanion.insert(
          id: newId(),
          productId: id,
          delta: capacity(p),
          kind: 'initial',
          createdAt: created,
        ));
      }
    }

    void move(String name, int delta, String kind, DateTime when, [String? saleId]) {
      stock[name] = stock[name]! + delta;
      moveRows.add(StockMovementsCompanion.insert(
        id: newId(),
        productId: ids[name]!,
        delta: delta,
        kind: kind,
        saleId: Value(saleId),
        createdAt: when,
      ));
    }

    double weightOn(_P p, int daysAgo) {
      var w = p.weight;
      if (p.name == 'Gansito') w *= daysAgo < 7 ? 2.5 : 1;
      if (p.name == 'Detergente 1 kg') w *= daysAgo < 7 ? 0.3 : 1;
      if (p.name == 'Cloro 1 L' && daysAgo < 21) w = 0;
      return w;
    }

    T pick<T>(List<T> items, double Function(T) weight) {
      final total = items.fold<double>(0, (a, x) => a + weight(x));
      var r = rnd.nextDouble() * total;
      for (final x in items) {
        r -= weight(x);
        if (r <= 0) return x;
      }
      return items.last;
    }

    final hours = _hourWeights.keys.toList();
    for (var i = 0; i < seedDays; i++) {
      final day = DateTime(first.year, first.month, first.day + i);
      final daysAgo = seedDays - 1 - i;
      final opening = DateTime(day.year, day.month, day.day, 7);

      // Resurtido de la mañana y conteo que deja poco al final.
      for (final p in _catalog.where((p) => p.track)) {
        final low = _lowAtEnd[p.name];
        if (low != null && daysAgo == 3) {
          move(p.name, low - stock[p.name]!, 'count', opening);
        } else if ((low == null || daysAgo > 3) &&
            stock[p.name]! < max(p.min, (p.weight * 1.5).ceil()) &&
            p.weight > 0) {
          move(p.name, capacity(p) - stock[p.name]!, 'in', opening);
        }
      }

      final growth = 0.8 + 0.25 * i / seedDays;
      final noise = 0.85 + rnd.nextDouble() * 0.3;
      final count = (30 * _dayFactor[day.weekday - 1] * growth * noise).round();
      final times = <DateTime>[
        for (var k = 0; k < count; k++)
          DateTime(day.year, day.month, day.day,
              pick(hours, (h) => _hourWeights[h]!.toDouble()), rnd.nextInt(60))
      ]..sort();

      for (final t in times) {
        if (t.isAfter(at)) break;
        final roll = rnd.nextDouble();
        final size = roll < 0.45 ? 1 : (roll < 0.8 ? 2 : (roll < 0.95 ? 3 : 4));
        final basket = <String, int>{};
        int qty() {
          final q = rnd.nextDouble();
          return q < 0.67 ? 1 : (q < 0.92 ? 2 : 3);
        }

        while (basket.length < size) {
          final options = [
            for (final p in _catalog)
              if (!basket.containsKey(p.name) && weightOn(p, daysAgo) > 0) p
          ];
          if (options.isEmpty) break;
          final p = pick(options, (x) => weightOn(x, daysAgo));
          basket[p.name] = qty();
          for (final (a, b, prob) in _pairs) {
            if (p.name == a && !basket.containsKey(b) && rnd.nextDouble() < prob) {
              basket[b] = 1;
            }
          }
        }

        // No se vende más de lo que hay (RF-11).
        basket.removeWhere((name, q) {
          final p = byName[name]!;
          return p.track && stock[name]! < q;
        });
        if (basket.isEmpty) continue;

        final saleId = newId();
        var total = 0;
        var profit = 0;
        final parts = <String>[];
        basket.forEach((name, q) {
          final p = byName[name]!;
          total += p.price * q;
          profit += (p.price - p.cost) * q;
          parts.add('$q × $name');
          itemRows.add(SaleItemsCompanion.insert(
            id: newId(),
            saleId: saleId,
            productId: ids[name]!,
            qty: q,
            unitPriceCents: p.price,
            unitCostCents: p.cost,
          ));
          if (p.track) move(name, -q, 'sale', t, saleId);
        });
        final summary = parts.length > 2
            ? '${parts.take(2).join(', ')} y ${parts.length - 2} más'
            : parts.join(', ');
        final cash = ((total + 1999) ~/ 2000) * 2000;
        saleRows.add(SalesCompanion.insert(
          id: saleId,
          createdAt: t,
          totalCents: total,
          profitCents: profit,
          receivedCents: rnd.nextBool() ? total : cash,
          summary: summary,
        ));
      }
    }

    final named = await (select(settings)
          ..where((s) => s.key.equals('business_name')))
        .getSingleOrNull();
    await transaction(() async {
      if (named == null) await setBusinessName('Abarrotes Doña Lupe');
      await batch((b) {
        b.insertAll(products, productRows);
        b.insertAll(sales, saleRows);
        b.insertAll(saleItems, itemRows);
        b.insertAll(stockMovements, moveRows);
      });
    });
    return SeedResult(productRows.length, saleRows.length);
  }
}
