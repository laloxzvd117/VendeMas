import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
  double get profit => (product.price - product.cost) * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  double? _received;

  Map<String, CartItem> get items => Map.unmodifiable(_items);
  List<CartItem> get itemList => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalProfit => _items.values.fold(0.0, (sum, item) => sum + item.profit);
  double? get received => _received;
  double get change => (_received ?? 0) - total;
  bool get canPay => _received != null && _received! >= total;

  void addProduct(Product product) {
    final existing = _items[product.id];
    if (existing != null) {
      _items[product.id] = CartItem(
        product: product,
        quantity: existing.quantity + 1,
      );
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void removeOne(String productId) {
    final existing = _items[productId];
    if (existing == null) return;
    if (existing.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = CartItem(
        product: existing.product,
        quantity: existing.quantity - 1,
      );
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void setReceived(double amount) {
    _received = amount;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _received = null;
    notifyListeners();
  }

  String describe() {
    final list = itemList;
    final shown = list.take(2).map((i) => '${i.quantity} × ${i.product.name}').join(', ');
    if (list.length > 2) return '$shown y ${list.length - 2} más';
    return shown;
  }
}
