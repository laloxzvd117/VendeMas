import '../domain/reports.dart';
import 'database.dart';

/// Lee de la base local lo que necesitan los reportes (F-10 a F-19).
extension ReportSource on AppDatabase {
  Future<ReportData> loadReportData() async {
    final salesRows = await select(sales).get();
    final itemRows = await select(saleItems).get();
    final productRows = await select(products).get();
    final moves = await select(stockMovements).get();

    final stock = <String, int>{};
    for (final m in moves) {
      stock[m.productId] = (stock[m.productId] ?? 0) + m.delta;
    }

    return ReportData(
      sales: [
        for (final s in salesRows)
          SaleRow(
            id: s.id,
            createdAt: s.createdAt,
            totalCents: s.totalCents,
            profitCents: s.profitCents,
          ),
      ],
      items: [
        for (final i in itemRows)
          ItemRow(
            saleId: i.saleId,
            productId: i.productId,
            qty: i.qty,
            unitPriceCents: i.unitPriceCents,
            unitCostCents: i.unitCostCents,
          ),
      ],
      products: [
        for (final p in productRows)
          ProductRow(
            id: p.id,
            name: p.name,
            priceCents: p.priceCents,
            costCents: p.costCents,
            trackStock: p.trackStock,
            minStock: p.minStock,
            createdAt: p.createdAt,
          ),
      ],
      stock: stock,
      now: DateTime.now(),
    );
  }

  /// Emite de nuevo cada vez que cambian ventas, productos o existencias.
  Stream<ReportData> watchReportData() => customSelect(
        'SELECT 1',
        readsFrom: {sales, saleItems, products, stockMovements},
      ).watch().asyncMap((_) => loadReportData());
}
