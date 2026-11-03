import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get activeProducts => _products.where((p) => p.isActive).toList();
  List<Product> get lowStockProducts => _products.where((p) => p.trackStock && p.stock <= p.minStock && p.isActive).toList();

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void updateStock(String productId, int newStock) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final p = _products[index];
      _products[index] = Product(
        id: p.id,
        businessId: p.businessId,
        name: p.name,
        price: p.price,
        cost: p.cost,
        trackStock: p.trackStock,
        stock: newStock,
        minStock: p.minStock,
        isActive: p.isActive,
      );
      notifyListeners();
    }
  }

  void toggleActive(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final p = _products[index];
      _products[index] = Product(
        id: p.id,
        businessId: p.businessId,
        name: p.name,
        price: p.price,
        cost: p.cost,
        trackStock: p.trackStock,
        stock: p.stock,
        minStock: p.minStock,
        isActive: !p.isActive,
      );
      notifyListeners();
    }
  }

  void loadSampleData(String businessId) {
    _products.clear();
    final samples = [
      ('Concha', 15.0, 6.5, true, 40, 20),
      ('Bolillo', 5.0, 2.0, true, 80, 40),
      ('Cuernito', 18.0, 8.0, true, 6, 8),
      ('Pan de muerto', 35.0, 14.0, true, 14, 6),
      ('Café americano', 25.0, 7.0, false, 0, 3),
      ('Empanada', 22.0, 12.0, true, 12, 6),
      ('Dona glaseada', 16.0, 7.0, true, 3, 6),
      ('Tamal', 20.0, 11.0, true, 10, 6),
      ('Rebanada de pastel', 45.0, 30.0, true, 0, 2),
      ('Pan integral', 40.0, 16.0, true, 12, 3),
      ('Galleta de avena', 12.0, 5.0, true, 30, 5),
    ];
    for (var i = 0; i < samples.length; i++) {
      final s = samples[i];
      _products.add(Product(
        id: 'sample_$i',
        businessId: businessId,
        name: s.$1,
        price: s.$2,
        cost: s.$3,
        trackStock: s.$4,
        stock: s.$5,
        minStock: s.$6,
      ));
    }
    notifyListeners();
  }
}
