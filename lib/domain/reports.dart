/// Cálculos de los reportes (F-10 a F-19). Son funciones puras: reciben los
/// datos ya leídos y devuelven resultados, así el celular y la computadora
/// muestran exactamente los mismos números. Todo el dinero va en centavos.
library;

/// Ventana de análisis de los reportes de producto: últimos 30 días.
const windowDays = 30;

/// Un producto sin venderse esta cantidad de días se considera "muerto".
const deadAfterDays = 14;

class SaleRow {
  const SaleRow({
    required this.id,
    required this.createdAt,
    required this.totalCents,
    required this.profitCents,
  });
  final String id;
  final DateTime createdAt;
  final int totalCents;
  final int profitCents;
}

class ItemRow {
  const ItemRow({
    required this.saleId,
    required this.productId,
    required this.qty,
    required this.unitPriceCents,
    required this.unitCostCents,
  });
  final String saleId;
  final String productId;
  final int qty;
  final int unitPriceCents;
  final int unitCostCents;

  int get revenue => qty * unitPriceCents;
  int get profit => qty * (unitPriceCents - unitCostCents);
}

class ProductRow {
  const ProductRow({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.costCents,
    required this.trackStock,
    required this.minStock,
    required this.createdAt,
  });
  final String id;
  final String name;
  final int priceCents;
  final int costCents;
  final bool trackStock;
  final int minStock;
  final DateTime createdAt;
}

/// Todo lo que necesitan los reportes, leído de la base local.
class ReportData {
  const ReportData({
    required this.sales,
    required this.items,
    required this.products,
    required this.stock,
    required this.now,
  });

  factory ReportData.empty([DateTime? now]) => ReportData(
        sales: const [],
        items: const [],
        products: const [],
        stock: const {},
        now: now ?? DateTime.now(),
      );

  final List<SaleRow> sales;
  final List<ItemRow> items;
  final List<ProductRow> products;

  /// Existencias actuales por producto (suma de movimientos).
  final Map<String, int> stock;
  final DateTime now;

  bool get hasSales => sales.isNotEmpty;
}

// ───────────────────────── Fechas ─────────────────────────

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

/// Lunes de la semana de [d].
DateTime weekStartOf(DateTime d) => addDays(d, -(d.weekday - 1));

// ───────────────────────── Producto ─────────────────────────

/// Ventas de un producto dentro de una ventana de tiempo.
class ProductStat {
  const ProductStat({
    required this.id,
    required this.name,
    required this.units,
    required this.revenue,
    required this.profit,
  });
  final String id;
  final String name;
  final int units;
  final int revenue;
  final int profit;

  /// Ganancia promedio por pieza, en centavos.
  int get unitProfit => units == 0 ? 0 : (profit / units).round();
}

Map<String, DateTime> _saleDates(ReportData d) =>
    {for (final s in d.sales) s.id: s.createdAt};

/// Ventas por producto en los últimos [days] días (incluye hoy).
List<ProductStat> productStats(ReportData d, {int days = windowDays}) {
  final cutoff = addDays(startOfDay(d.now), -(days - 1));
  final dates = _saleDates(d);
  final names = {for (final p in d.products) p.id: p.name};
  final units = <String, int>{};
  final revenue = <String, int>{};
  final profit = <String, int>{};
  for (final i in d.items) {
    final at = dates[i.saleId];
    if (at == null || at.isBefore(cutoff)) continue;
    if (!names.containsKey(i.productId)) continue;
    units[i.productId] = (units[i.productId] ?? 0) + i.qty;
    revenue[i.productId] = (revenue[i.productId] ?? 0) + i.revenue;
    profit[i.productId] = (profit[i.productId] ?? 0) + i.profit;
  }
  return [
    for (final id in units.keys)
      ProductStat(
        id: id,
        name: names[id]!,
        units: units[id]!,
        revenue: revenue[id]!,
        profit: profit[id]!,
      ),
  ];
}

List<ProductStat> rankByUnits(List<ProductStat> s) => [...s]
  ..sort((a, b) {
    final c = b.units.compareTo(a.units);
    return c != 0 ? c : b.profit.compareTo(a.profit);
  });

List<ProductStat> rankByProfit(List<ProductStat> s) => [...s]
  ..sort((a, b) {
    final c = b.profit.compareTo(a.profit);
    return c != 0 ? c : b.units.compareTo(a.units);
  });

// ───────────────────────── ABC (RF-13) ─────────────────────────

class AbcRow {
  const AbcRow(this.stat, this.grade, this.share, this.cumulative);
  final ProductStat stat;

  /// 'A', 'B' o 'C'.
  final String grade;

  /// Porcentaje de la ganancia total que aporta este producto.
  final double share;

  /// Porcentaje acumulado hasta este producto.
  final double cumulative;
}

class AbcResult {
  const AbcResult(this.rows, this.countA, this.shareA);
  final List<AbcRow> rows;
  final int countA;

  /// Porcentaje de la ganancia que generan los productos A.
  final double shareA;

  int get total => rows.length;
  bool get isEmpty => rows.isEmpty;
}

/// A: los que juntan el primer 80% de la ganancia; B: hasta el 95%; C: el resto.
AbcResult abcAnalysis(List<ProductStat> stats) {
  final sorted = rankByProfit(stats);
  final total = sorted.fold<int>(0, (a, s) => a + (s.profit > 0 ? s.profit : 0));
  if (total <= 0) return const AbcResult([], 0, 0);
  final rows = <AbcRow>[];
  var cum = 0;
  for (final s in sorted) {
    final p = s.profit > 0 ? s.profit : 0;
    final before = cum / total * 100;
    cum += p;
    final grade = before < 80 ? 'A' : (before < 95 ? 'B' : 'C');
    rows.add(AbcRow(s, grade, p / total * 100, cum / total * 100));
  }
  final a = rows.where((r) => r.grade == 'A').toList();
  return AbcResult(rows, a.length, a.isEmpty ? 0 : a.last.cumulative);
}

// ───────────────────────── Margen y rotación (RF-14) ─────────────────────────

class Quadrants {
  const Quadrants({
    required this.stars,
    required this.gems,
    required this.busy,
    required this.review,
    required this.minUnits,
    required this.minUnitProfit,
  });
  final List<ProductStat> stars; // mucho margen, mucha rotación
  final List<ProductStat> gems; // mucho margen, poca rotación
  final List<ProductStat> busy; // poco margen, mucha rotación
  final List<ProductStat> review; // poco margen, poca rotación

  /// Piezas a partir de las cuales se considera "mucha rotación".
  final int minUnits;

  /// Ganancia por pieza (centavos) a partir de la cual se considera "buen margen".
  final int minUnitProfit;

  bool get isEmpty =>
      stars.isEmpty && gems.isEmpty && busy.isEmpty && review.isEmpty;
}

/// Los umbrales son el promedio de los propios productos del negocio.
Quadrants quadrants(List<ProductStat> stats) {
  if (stats.isEmpty) {
    return const Quadrants(
        stars: [], gems: [], busy: [], review: [], minUnits: 0, minUnitProfit: 0);
  }
  final avgUnits = stats.fold<int>(0, (a, s) => a + s.units) / stats.length;
  final avgProfit =
      stats.fold<int>(0, (a, s) => a + s.unitProfit) / stats.length;
  final stars = <ProductStat>[];
  final gems = <ProductStat>[];
  final busy = <ProductStat>[];
  final review = <ProductStat>[];
  for (final s in rankByProfit(stats)) {
    final hiRot = s.units >= avgUnits;
    final hiMar = s.unitProfit >= avgProfit;
    if (hiRot && hiMar) {
      stars.add(s);
    } else if (hiMar) {
      gems.add(s);
    } else if (hiRot) {
      busy.add(s);
    } else {
      review.add(s);
    }
  }
  return Quadrants(
    stars: stars,
    gems: gems,
    busy: busy,
    review: review,
    minUnits: avgUnits.ceil(),
    minUnitProfit: avgProfit.round(),
  );
}

// ───────────────────────── Productos muertos (RF-15) ─────────────────────────

class DeadItem {
  const DeadItem({
    required this.product,
    required this.stock,
    required this.trappedCents,
    required this.daysIdle,
    required this.neverSold,
  });
  final ProductRow product;
  final int stock;

  /// Dinero inmovilizado: existencias por costo.
  final int trappedCents;

  /// Días sin venderse (o desde que se dio de alta, si nunca se vendió).
  final int daysIdle;
  final bool neverSold;
}

List<DeadItem> deadProducts(ReportData d) {
  final dates = _saleDates(d);
  final last = <String, DateTime>{};
  for (final i in d.items) {
    final at = dates[i.saleId];
    if (at == null) continue;
    final prev = last[i.productId];
    if (prev == null || at.isAfter(prev)) last[i.productId] = at;
  }
  final today = startOfDay(d.now);
  final out = <DeadItem>[];
  for (final p in d.products) {
    final stock = d.stock[p.id] ?? 0;
    if (!p.trackStock || stock <= 0) continue;
    final since = last[p.id] ?? p.createdAt;
    final idle = today.difference(startOfDay(since)).inDays;
    if (idle < deadAfterDays) continue;
    out.add(DeadItem(
      product: p,
      stock: stock,
      trappedCents: stock * p.costCents,
      daysIdle: idle,
      neverSold: !last.containsKey(p.id),
    ));
  }
  out.sort((a, b) => b.trappedCents.compareTo(a.trappedCents));
  return out;
}

int deadTotal(List<DeadItem> items) =>
    items.fold(0, (a, i) => a + i.trappedCents);

// ───────────────────────── Horas y días fuertes (RF-16) ─────────────────────────

class HoursResult {
  const HoursResult({
    required this.byHour,
    required this.byWeekday,
    required this.peakHour,
    required this.strongRanges,
    required this.bestWeekday,
  });
  final List<int> byHour; // 24 valores, centavos
  final List<int> byWeekday; // lunes = 0, centavos
  final int peakHour;

  /// Rangos [inicio, fin) de horas fuertes, ej. (8, 10).
  final List<(int, int)> strongRanges;
  final int bestWeekday;

  bool get isEmpty => byHour.every((v) => v == 0);
}

HoursResult hoursReport(ReportData d) {
  final cutoff = addDays(startOfDay(d.now), -(windowDays - 1));
  final byHour = List<int>.filled(24, 0);
  final byDay = List<int>.filled(7, 0);
  for (final s in d.sales) {
    if (s.createdAt.isBefore(cutoff)) continue;
    byHour[s.createdAt.hour] += s.totalCents;
    byDay[s.createdAt.weekday - 1] += s.totalCents;
  }
  final maxH = byHour.reduce((a, b) => a > b ? a : b);
  final maxD = byDay.reduce((a, b) => a > b ? a : b);
  final ranges = <(int, int)>[];
  if (maxH > 0) {
    int? start;
    for (var h = 0; h <= 24; h++) {
      final strong = h < 24 && byHour[h] >= maxH * 0.7;
      if (strong && start == null) start = h;
      if (!strong && start != null) {
        ranges.add((start, h));
        start = null;
      }
    }
  }
  return HoursResult(
    byHour: byHour,
    byWeekday: byDay,
    peakHour: maxH == 0 ? 0 : byHour.indexOf(maxH),
    strongRanges: ranges,
    bestWeekday: maxD == 0 ? 0 : byDay.indexOf(maxD),
  );
}

// ───────────────────────── Se venden juntos (RF-17) ─────────────────────────

class PairRow {
  const PairRow(this.nameA, this.nameB, this.together, this.percent);
  final String nameA;
  final String nameB;

  /// Ventas donde aparecen los dos.
  final int together;

  /// De cada 100 ventas con [nameA], cuántas llevan también [nameB].
  final int percent;
}

class ComboIdea {
  const ComboIdea(this.nameA, this.nameB, this.normalCents, this.comboCents);
  final String nameA;
  final String nameB;
  final int normalCents;
  final int comboCents;
}

class PairsResult {
  const PairsResult(this.rows, this.combo);
  final List<PairRow> rows;
  final ComboIdea? combo;
}

PairsResult pairsReport(ReportData d) {
  final cutoff = addDays(startOfDay(d.now), -(windowDays - 1));
  final recent = {
    for (final s in d.sales)
      if (!s.createdAt.isBefore(cutoff)) s.id
  };
  final bySale = <String, Set<String>>{};
  for (final i in d.items) {
    if (recent.contains(i.saleId)) {
      bySale.putIfAbsent(i.saleId, () => <String>{}).add(i.productId);
    }
  }
  final count = <String, int>{};
  final pair = <(String, String), int>{};
  for (final ids in bySale.values) {
    final list = ids.toList()..sort();
    for (final id in list) {
      count[id] = (count[id] ?? 0) + 1;
    }
    for (var a = 0; a < list.length; a++) {
      for (var b = a + 1; b < list.length; b++) {
        final k = (list[a], list[b]);
        pair[k] = (pair[k] ?? 0) + 1;
      }
    }
  }
  final prods = {for (final p in d.products) p.id: p};
  final rows = <(PairRow, String, String)>[];
  pair.forEach((k, n) {
    if (n < 2) return;
    final a = prods[k.$1];
    final b = prods[k.$2];
    if (a == null || b == null) return;
    final pa = n / count[k.$1]!;
    final pb = n / count[k.$2]!;
    final first = pa >= pb ? a : b;
    final second = pa >= pb ? b : a;
    rows.add((
      PairRow(first.name, second.name, n, ((pa >= pb ? pa : pb) * 100).round()),
      first.id,
      second.id,
    ));
  });
  rows.sort((x, y) {
    final c = y.$1.percent.compareTo(x.$1.percent);
    return c != 0 ? c : y.$1.together.compareTo(x.$1.together);
  });
  final top = rows.take(5).toList();
  ComboIdea? combo;
  if (top.isNotEmpty) {
    final a = prods[top.first.$2]!;
    final b = prods[top.first.$3]!;
    final normal = a.priceCents + b.priceCents;
    // 10% menos, redondeado a pesos enteros, sin vender por debajo del costo.
    final offer = ((normal * 0.9) / 100).round() * 100;
    if (offer < normal && offer > a.costCents + b.costCents) {
      combo = ComboIdea(a.name, b.name, normal, offer);
    }
  }
  return PairsResult([for (final r in top) r.$1], combo);
}

// ───────────────────────── Tendencias (RF-18) ─────────────────────────

class TrendRow {
  const TrendRow(this.name, this.current, this.previous, this.percent);
  final String name;
  final int current;
  final int previous;
  final int percent;
}

/// Últimos 7 días contra los 7 días anteriores, por piezas vendidas.
/// Solo productos con al menos 3 piezas y cambios de 8% o más.
List<TrendRow> trendsReport(ReportData d) {
  final today = startOfDay(d.now);
  final curStart = addDays(today, -6);
  final prevStart = addDays(today, -13);
  final dates = _saleDates(d);
  final names = {for (final p in d.products) p.id: p.name};
  final cur = <String, int>{};
  final prev = <String, int>{};
  for (final i in d.items) {
    final at = dates[i.saleId];
    if (at == null || !names.containsKey(i.productId)) continue;
    if (!at.isBefore(curStart)) {
      cur[i.productId] = (cur[i.productId] ?? 0) + i.qty;
    } else if (!at.isBefore(prevStart)) {
      prev[i.productId] = (prev[i.productId] ?? 0) + i.qty;
    }
  }
  final out = <TrendRow>[];
  for (final id in {...cur.keys, ...prev.keys}) {
    final c = cur[id] ?? 0;
    final p = prev[id] ?? 0;
    if ((c > p ? c : p) < 3) continue;
    final pct = p == 0 ? 100 : ((c - p) / p * 100).round();
    if (pct.abs() < 8) continue;
    out.add(TrendRow(names[id]!, c, p, pct));
  }
  out.sort((a, b) => b.percent.abs().compareTo(a.percent.abs()));
  return out;
}

// ───────────────────────── Resumen semanal (RF-19) ─────────────────────────

class DayStat {
  const DayStat(this.day, this.sales, this.profit, this.tickets);
  final DateTime day;
  final int sales;
  final int profit;
  final int tickets;
}

class WeekSummary {
  const WeekSummary({
    required this.start,
    required this.days,
    required this.sales,
    required this.profit,
    required this.tickets,
    required this.previousSales,
    required this.isCurrent,
  });
  final DateTime start;
  final List<DayStat> days; // lunes a domingo
  final int sales;
  final int profit;
  final int tickets;

  /// Ventas de la semana anterior; 0 si no hubo.
  final int previousSales;

  /// true si es la semana en curso (todavía incompleta).
  final bool isCurrent;

  DateTime get end => addDays(start, 6);

  /// Cambio contra la semana anterior; null si no hay con qué comparar.
  int? get percent =>
      previousSales <= 0 ? null : ((sales - previousSales) / previousSales * 100).round();

  DayStat get bestDay => days.reduce((a, b) => b.sales > a.sales ? b : a);
  DayStat get worstDay => days.reduce((a, b) => b.sales < a.sales ? b : a);
  bool get hasSales => tickets > 0;
}

int _salesBetween(ReportData d, DateTime from, DateTime to) {
  var t = 0;
  for (final s in d.sales) {
    if (!s.createdAt.isBefore(from) && s.createdAt.isBefore(to)) {
      t += s.totalCents;
    }
  }
  return t;
}

WeekSummary weekSummary(ReportData d, DateTime weekStart) {
  final start = startOfDay(weekStart);
  final end = addDays(start, 7);
  final sales = List<int>.filled(7, 0);
  final profit = List<int>.filled(7, 0);
  final tickets = List<int>.filled(7, 0);
  for (final s in d.sales) {
    if (s.createdAt.isBefore(start) || !s.createdAt.isBefore(end)) continue;
    final k = s.createdAt.weekday - 1;
    sales[k] += s.totalCents;
    profit[k] += s.profitCents;
    tickets[k] += 1;
  }
  final thisWeek = weekStartOf(d.now);
  return WeekSummary(
    start: start,
    days: [
      for (var k = 0; k < 7; k++)
        DayStat(addDays(start, k), sales[k], profit[k], tickets[k]),
    ],
    sales: sales.fold(0, (a, b) => a + b),
    profit: profit.fold(0, (a, b) => a + b),
    tickets: tickets.fold(0, (a, b) => a + b),
    previousSales: _salesBetween(d, addDays(start, -7), start),
    isCurrent: start == thisWeek,
  );
}

/// Las últimas [count] semanas, de la más antigua a la actual.
List<WeekSummary> lastWeeks(ReportData d, {int count = 8}) {
  final thisWeek = weekStartOf(d.now);
  return [
    for (var i = count - 1; i >= 0; i--) weekSummary(d, addDays(thisWeek, -7 * i)),
  ];
}

// ───────────────────────── Existencias (RF-09 a RF-11) ─────────────────────────

/// Cuánto alcanza lo que hay, según el ritmo de venta de los últimos 30 días.
String coverText({required int stock, required int unitsLast30}) {
  if (unitsLast30 <= 0) return 'sin ventas recientes';
  final days = stock / (unitsLast30 / windowDays);
  if (days < 1) return 'alcanza menos de 1 día';
  final r = days.round();
  return 'alcanza ~$r ${r == 1 ? 'día' : 'días'}';
}

