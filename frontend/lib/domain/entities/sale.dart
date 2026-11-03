class Sale {
  final String id;
  final String businessId;
  final DateTime timestamp;
  final double total;
  final double profit;
  final double received;
  final double change;
  final bool synced;
  final List<SaleItem> items;

  const Sale({
    required this.id,
    required this.businessId,
    required this.timestamp,
    required this.total,
    required this.profit,
    required this.received,
    required this.change,
    this.synced = false,
    required this.items,
  });
}

class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double unitCost;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
  });

  double get subtotal => unitPrice * quantity;
  double get profit => (unitPrice - unitCost) * quantity;
}
