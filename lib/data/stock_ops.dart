import 'package:drift/drift.dart';

import 'database.dart';

/// Movimientos de existencias a mano (F-09, RF-10).
extension StockOps on AppDatabase {
  Future<int> _currentStock(String productId) async {
    final moves = await (select(stockMovements)
          ..where((m) => m.productId.equals(productId)))
        .get();
    return moves.fold<int>(0, (a, m) => a + m.delta);
  }

  Future<void> _move(String productId, int delta, String kind) =>
      into(stockMovements).insert(StockMovementsCompanion.insert(
        id: newId(),
        productId: productId,
        delta: delta,
        kind: kind,
        createdAt: DateTime.now(),
      ));

  /// Entrada de mercancía: suma [qty] piezas.
  Future<void> receiveStock(String productId, int qty) =>
      transaction(() async {
        if (qty <= 0) return;
        await _move(productId, qty, 'in');
      });

  /// Conteo: deja las existencias en [total] piezas.
  Future<void> countStock(String productId, int total) =>
      transaction(() async {
        final delta = total - await _currentStock(productId);
        if (delta != 0) await _move(productId, delta, 'count');
      });

  /// Activa el control de existencias empezando en [total] piezas.
  Future<void> enableStock(String productId, int total) =>
      transaction(() async {
        await (update(products)..where((p) => p.id.equals(productId)))
            .write(const ProductsCompanion(trackStock: Value(true)));
        final delta = total - await _currentStock(productId);
        if (delta != 0) await _move(productId, delta, 'count');
      });

  /// Deja de llevar existencias de este producto.
  Future<void> disableStock(String productId) =>
      (update(products)..where((p) => p.id.equals(productId)))
          .write(const ProductsCompanion(trackStock: Value(false)));
}
