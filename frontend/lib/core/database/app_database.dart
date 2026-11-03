// ============================================================================
// VendeMas - SQLite Schema (Drift / Local)
// Archivo: app_database.dart
// Espejo del esquema PostgreSQL — mismo modelo, adaptado a SQLite
// ============================================================================

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. NEGOCIO
// ─────────────────────────────────────────────────────────────────────────────
class Businesses extends Table {
  TextColumn     get id          => text()();
  TextColumn     get name        => text().withLength(min: 1, max: 100)();
  TextColumn     get phoneNumber => text().withLength(min: 10, max: 20)();
  DateTimeColumn get createdAt   => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt   => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. PRODUCTOS
// ─────────────────────────────────────────────────────────────────────────────
class Products extends Table {
  TextColumn     get id          => text()();
  TextColumn     get businessId  => text().references(Businesses, #id)();
  TextColumn     get name        => text().withLength(min: 1, max: 100)();
  RealColumn     get price       => real()();
  RealColumn     get cost        => real().withDefault(const Constant(0.0))();
  BoolColumn     get trackStock  => boolean().withDefault(const Constant(false))();
  IntColumn      get stock       => integer().withDefault(const Constant(0))();
  IntColumn      get minStock    => integer().withDefault(const Constant(3))();
  BoolColumn     get isActive    => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt   => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt   => dateTime().withDefault(currentDateAndTime)();
  // Sync tracking (solo en local, no existe en PostgreSQL)
  BoolColumn     get synced      => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. VENTAS
// ─────────────────────────────────────────────────────────────────────────────
class Sales extends Table {
  TextColumn     get id         => text()();   // UUID generado en el cliente
  TextColumn     get businessId => text().references(Businesses, #id)();
  RealColumn     get total      => real()();
  RealColumn     get profit     => real()();
  RealColumn     get received   => real()();
  RealColumn     get changeAmount => real().withDefault(const Constant(0.0)).named('change')();
  DateTimeColumn get createdAt  => dateTime()();
  // Sync tracking
  BoolColumn     get synced     => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt   => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. DETALLE DE VENTA
// ─────────────────────────────────────────────────────────────────────────────
class SaleItems extends Table {
  TextColumn  get id          => text()();
  TextColumn  get saleId      => text().references(Sales, #id)();
  TextColumn  get productId   => text().references(Products, #id)();
  TextColumn  get productName => text().withLength(min: 1, max: 100)();
  IntColumn   get quantity    => integer()();
  RealColumn  get unitPrice   => real()();
  RealColumn  get unitCost    => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. MOVIMIENTOS DE INVENTARIO
// ─────────────────────────────────────────────────────────────────────────────
class StockMovements extends Table {
  TextColumn     get id             => text()();
  TextColumn     get productId      => text().references(Products, #id)();
  TextColumn     get businessId     => text().references(Businesses, #id)();
  // type: 'sale' | 'entry' | 'count' | 'deactivate'
  TextColumn     get type           => text()();
  IntColumn      get quantity       => integer()();
  IntColumn      get resultingStock => integer()();
  DateTimeColumn get createdAt      => dateTime()();
  // Sync tracking
  BoolColumn     get synced         => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt       => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. RESÚMENES SEMANALES
// daily_data se guarda como JSON serializado (TEXT en SQLite)
// Formato: '[{"date":"2024-10-28","sales":1450,"profit":820,"tickets":32}]'
// ─────────────────────────────────────────────────────────────────────────────
class WeeklySummaries extends Table {
  TextColumn     get id           => text()();
  TextColumn     get businessId   => text().references(Businesses, #id)();
  DateTimeColumn get weekStart    => dateTime()();
  DateTimeColumn get weekEnd      => dateTime()();
  RealColumn     get totalSales   => real()();
  RealColumn     get totalProfit  => real()();
  IntColumn      get totalTickets => integer()();
  TextColumn     get dailyData    => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt    => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// BASE DE DATOS
// ─────────────────────────────────────────────────────────────────────────────
@DriftDatabase(tables: [
  Businesses,
  Products,
  Sales,
  SaleItems,
  StockMovements,
  WeeklySummaries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Índices equivalentes a los de PostgreSQL
        await customStatement('''
          CREATE INDEX idx_products_business
          ON products (business_id)
        ''');
        await customStatement('''
          CREATE INDEX idx_products_unsynced
          ON products (synced) WHERE synced = 0
        ''');
        await customStatement('''
          CREATE INDEX idx_sales_business
          ON sales (business_id)
        ''');
        await customStatement('''
          CREATE INDEX idx_sales_created
          ON sales (business_id, created_at DESC)
        ''');
        await customStatement('''
          CREATE INDEX idx_sales_unsynced
          ON sales (synced) WHERE synced = 0
        ''');
        await customStatement('''
          CREATE INDEX idx_sale_items_sale
          ON sale_items (sale_id)
        ''');
        await customStatement('''
          CREATE INDEX idx_stock_movements_product
          ON stock_movements (product_id)
        ''');
        await customStatement('''
          CREATE INDEX idx_stock_movements_unsynced
          ON stock_movements (synced) WHERE synced = 0
        ''');
        await customStatement('''
          CREATE UNIQUE INDEX idx_weekly_summaries_business
          ON weekly_summaries (business_id, week_start)
        ''');
        // Trigger: descontar stock al insertar sale_item
        await customStatement('''
          CREATE TRIGGER trg_sale_item_stock
          AFTER INSERT ON sale_items
          WHEN (SELECT track_stock FROM products WHERE id = NEW.product_id) = 1
          BEGIN
            UPDATE products
            SET stock = stock - NEW.quantity,
                updated_at = datetime('now')
            WHERE id = NEW.product_id;
          END
        ''');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migraciones futuras:
        // if (from < 2) { await m.addColumn(products, products.barcode); }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONEXIÓN
// ─────────────────────────────────────────────────────────────────────────────
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vendemas.db'));

    // En Android: apuntar sqlite3 al directorio temporal correcto
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;
    }

    return NativeDatabase.createInBackground(file);
  });
}
