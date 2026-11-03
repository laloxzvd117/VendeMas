enum MovementType { sale, entry, count, deactivate }

class StockMovement {
  final String id;
  final String productId;
  final MovementType type;
  final int quantity;
  final int resultingStock;
  final DateTime timestamp;
  final bool synced;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.resultingStock,
    required this.timestamp,
    this.synced = false,
  });
}
