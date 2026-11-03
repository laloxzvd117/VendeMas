class Product {
  final String id;
  final String businessId;
  final String name;
  final double price;
  final double cost;
  final bool trackStock;
  final int stock;
  final int minStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.price,
    required this.cost,
    this.trackStock = false,
    this.stock = 0,
    this.minStock = 3,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get margin => price > 0 ? (price - cost) / price * 100 : 0;
  double get unitProfit => price - cost;
}
