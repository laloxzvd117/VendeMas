import 'database.dart';

/// Copia completa de la base para mandarla a la computadora. Cada registro
/// lleva su identificador único, así importar dos veces no duplica nada.
extension SyncData on AppDatabase {
  /// Cambia cada vez que hay ventas, productos, existencias o nombre nuevos.
  Future<String> syncVersion() async {
    final r = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM sales) AS s, '
      '(SELECT COUNT(*) FROM stock_movements) AS m, '
      '(SELECT COUNT(*) FROM products) AS p, '
      '(SELECT COALESCE(SUM(track_stock), 0) FROM products) AS t, '
      "(SELECT value FROM settings WHERE key = 'business_name') AS n",
      readsFrom: {sales, stockMovements, products, settings},
    ).getSingle();
    return '${r.read<int>('s')}-${r.read<int>('m')}-${r.read<int>('p')}-'
        '${r.read<int>('t')}-${r.readNullable<String>('n') ?? ''}';
  }

  Future<Map<String, dynamic>> exportAll() async => {
        'version': await syncVersion(),
        'settings': [for (final r in await select(settings).get()) r.toJson()],
        'products': [for (final r in await select(products).get()) r.toJson()],
        'sales': [for (final r in await select(sales).get()) r.toJson()],
        'saleItems': [for (final r in await select(saleItems).get()) r.toJson()],
        'stockMovements': [
          for (final r in await select(stockMovements).get()) r.toJson()
        ],
      };

  /// Inserta lo nuevo y actualiza lo existente, por identificador.
  Future<void> importAll(Map<String, dynamic> data) {
    List<Map<String, dynamic>> rows(String key) => [
          for (final r in (data[key] as List? ?? const []))
            (r as Map).cast<String, dynamic>()
        ];
    return batch((b) {
      b.insertAllOnConflictUpdate(
          settings, [for (final j in rows('settings')) Setting.fromJson(j)]);
      b.insertAllOnConflictUpdate(
          products, [for (final j in rows('products')) Product.fromJson(j)]);
      b.insertAllOnConflictUpdate(
          sales, [for (final j in rows('sales')) Sale.fromJson(j)]);
      b.insertAllOnConflictUpdate(
          saleItems, [for (final j in rows('saleItems')) SaleItem.fromJson(j)]);
      b.insertAllOnConflictUpdate(stockMovements,
          [for (final j in rows('stockMovements')) StockMovement.fromJson(j)]);
    });
  }
}
