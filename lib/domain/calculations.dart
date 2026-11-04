/// Cálculos puros del negocio. Todo el dinero va en centavos (int) para
/// evitar errores de redondeo con decimales.
library;

/// Una línea de venta: producto, cantidad y precios vigentes al vender.
class LineItem {
  const LineItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.unitCost,
  });

  final String productId;
  final String name;
  final int qty;
  final int unitPrice;
  final int unitCost;

  int get subtotal => unitPrice * qty;
  int get profit => (unitPrice - unitCost) * qty;

  LineItem withQty(int q) => LineItem(
        productId: productId,
        name: name,
        qty: q,
        unitPrice: unitPrice,
        unitCost: unitCost,
      );
}

int saleTotal(Iterable<LineItem> items) =>
    items.fold(0, (a, i) => a + i.subtotal);

int saleProfit(Iterable<LineItem> items) =>
    items.fold(0, (a, i) => a + i.profit);

int pieceCount(Iterable<LineItem> items) =>
    items.fold(0, (a, i) => a + i.qty);

/// Cambio a entregar. Negativo = faltan centavos por cobrar.
int changeFor({required int total, required int received}) => received - total;

/// El cobro solo se permite si hay venta y el monto alcanza (RF-06).
bool canCharge({required int total, required int? received}) =>
    total > 0 && received != null && received >= total;

/// Margen en porcentaje sobre el precio de venta. 0 si el precio es 0.
double marginPercent({required int price, required int cost}) =>
    price <= 0 ? 0 : (price - cost) / price * 100;

/// Montos sugeridos de pago: el siguiente billete/múltiplo redondo mayor
/// al total, sin repetir y ordenados. Ej. total 55 → 60, 100, 200.
List<int> suggestedCash(int totalCents, {int max = 3}) {
  const steps = [1000, 2000, 5000, 10000, 20000, 50000]; // 10,20,50,100,200,500
  final out = <int>{};
  for (final s in steps) {
    final v = ((totalCents + s - 1) ~/ s) * s;
    if (v > totalCents) out.add(v);
  }
  final list = out.toList()..sort();
  return list.take(max).toList();
}

/// Convierte texto como "15", "15.5" o "15,50" a centavos. null si no es válido.
int? parseCents(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  final v = double.tryParse(t);
  if (v == null || v.isNaN || v.isInfinite || v < 0) return null;
  return (v * 100).round();
}
