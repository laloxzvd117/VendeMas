import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/calculations.dart';

part 'database.g.dart';

const _uuid = Uuid();
String newId() => _uuid.v7();

/// Ajustes clave/valor del negocio (nombre, etc.).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get priceCents => integer()();
  IntColumn get costCents => integer()();
  BoolColumn get trackStock => boolean().withDefault(const Constant(false))();
  IntColumn get minStock => integer().withDefault(const Constant(3))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get totalCents => integer()();
  IntColumn get profitCents => integer()();
  IntColumn get receivedCents => integer()();
  TextColumn get summary => text()();

  /// null = pendiente de sincronizar (se usa en la fase de sincronización).
  DateTimeColumn get syncedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get qty => integer()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get unitCostCents => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Las existencias no se editan: son la suma de estos movimientos.
/// kind: 'sale' | 'in' | 'count' | 'initial'
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get delta => integer()();
  TextColumn get kind => text()();
  TextColumn get saleId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Producto con sus existencias calculadas.
class ProductView {
  const ProductView(this.product, this.stock);
  final Product product;
  final int stock;

  bool get tracked => product.trackStock;
  bool get isOut => tracked && stock <= 0;
  bool get isLow => tracked && stock > 0 && stock <= product.minStock;
  double get margin =>
      marginPercent(price: product.priceCents, cost: product.costCents);
}

class DayStats {
  const DayStats({this.sales = 0, this.profit = 0, this.tickets = 0});
  final int sales;
  final int profit;
  final int tickets;
}

@DriftDatabase(
    tables: [Settings, Products, Sales, SaleItems, StockMovements])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  // ---- Negocio ----
  Stream<String?> watchBusinessName() =>
      (select(settings)..where((s) => s.key.equals('business_name')))
          .watchSingleOrNull()
          .map((r) => r?.value);

  Future<void> setBusinessName(String name) => into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: 'business_name', value: name));

  // ---- Productos ----
  Stream<List<ProductView>> watchProducts() {
    final stock = stockMovements.delta.sum();
    final q = select(products).join([
      leftOuterJoin(stockMovements, stockMovements.productId.equalsExp(products.id))
    ])
      ..addColumns([stock])
      ..groupBy([products.id])
      ..orderBy([OrderingTerm.asc(products.name)]);
    return q.watch().map((rows) => rows
        .map((r) => ProductView(r.readTable(products), r.read(stock) ?? 0))
        .toList());
  }

  /// [initialStock] null = sin control de existencias.
  Future<void> addProduct({
    required String name,
    required int priceCents,
    required int costCents,
    int? initialStock,
  }) =>
      transaction(() async {
        final id = newId();
        final now = DateTime.now();
        await into(products).insert(ProductsCompanion.insert(
          id: id,
          name: name.trim(),
          priceCents: priceCents,
          costCents: costCents,
          trackStock: Value(initialStock != null),
          createdAt: now,
        ));
        if (initialStock != null && initialStock > 0) {
          await into(stockMovements).insert(StockMovementsCompanion.insert(
              id: newId(),
              productId: id,
              delta: initialStock,
              kind: 'initial',
              createdAt: now));
        }
      });

  // ---- Ventas ----
  /// Registra venta, renglones y descuento de existencias en una transacción.
  Future<Sale> recordSale({
    required List<LineItem> items,
    required int receivedCents,
    required Set<String> trackedIds,
  }) =>
      transaction(() async {
        final now = DateTime.now();
        final total = saleTotal(items);
        final saleId = newId();
        final summary = _describe(items);
        final row = SalesCompanion.insert(
          id: saleId,
          createdAt: now,
          totalCents: total,
          profitCents: saleProfit(items),
          receivedCents: receivedCents,
          summary: summary,
        );
        await into(sales).insert(row);
        for (final i in items) {
          await into(saleItems).insert(SaleItemsCompanion.insert(
            id: newId(),
            saleId: saleId,
            productId: i.productId,
            qty: i.qty,
            unitPriceCents: i.unitPrice,
            unitCostCents: i.unitCost,
          ));
          if (trackedIds.contains(i.productId)) {
            await into(stockMovements).insert(StockMovementsCompanion.insert(
              id: newId(),
              productId: i.productId,
              delta: -i.qty,
              kind: 'sale',
              saleId: Value(saleId),
              createdAt: now,
            ));
          }
        }
        return (select(sales)..where((s) => s.id.equals(saleId))).getSingle();
      });

  String _describe(List<LineItem> items) {
    final head = items.take(2).map((i) => '${i.qty} × ${i.name}').join(', ');
    return items.length > 2 ? '$head y ${items.length - 2} más' : head;
  }

  Stream<DayStats> watchToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final q = selectOnly(sales)
      ..addColumns([sales.totalCents.sum(), sales.profitCents.sum(), sales.id.count()])
      ..where(sales.createdAt.isBiggerOrEqualValue(start));
    return q.watchSingle().map((r) => DayStats(
          sales: r.read(sales.totalCents.sum()) ?? 0,
          profit: r.read(sales.profitCents.sum()) ?? 0,
          tickets: r.read(sales.id.count()) ?? 0,
        ));
  }

  Stream<List<Sale>> watchRecentSales({int limit = 3}) =>
      (select(sales)
            ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
            ..limit(limit))
          .watch();
}
