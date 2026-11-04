import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'domain/calculations.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'vendemas'));
  ref.onDispose(db.close);
  return db;
});

final businessNameProvider = StreamProvider<String?>(
    (ref) => ref.watch(databaseProvider).watchBusinessName());

final productsProvider = StreamProvider<List<ProductView>>(
    (ref) => ref.watch(databaseProvider).watchProducts());

final todayProvider = StreamProvider<DayStats>(
    (ref) => ref.watch(databaseProvider).watchToday());

final recentSalesProvider = StreamProvider<List<Sale>>(
    (ref) => ref.watch(databaseProvider).watchRecentSales());

/// Carrito: id de producto -> cantidad.
class CartNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  /// Devuelve un mensaje si no se puede sumar (sin existencias suficientes).
  String? add(ProductView p) {
    final q = state[p.product.id] ?? 0;
    if (p.tracked && q + 1 > p.stock) {
      return 'Solo quedan ${p.stock} de ${p.product.name}.';
    }
    state = {...state, p.product.id: q + 1};
    return null;
  }

  void remove(String id) {
    final q = (state[id] ?? 0) - 1;
    final next = {...state};
    if (q <= 0) {
      next.remove(id);
    } else {
      next[id] = q;
    }
    state = next;
  }

  void clear() => state = {};
}

final cartProvider =
    NotifierProvider<CartNotifier, Map<String, int>>(CartNotifier.new);

/// Renglones del carrito con precios vigentes.
final cartItemsProvider = Provider<List<LineItem>>((ref) {
  final cart = ref.watch(cartProvider);
  final products = ref.watch(productsProvider).value ?? const [];
  return [
    for (final p in products)
      if ((cart[p.product.id] ?? 0) > 0)
        LineItem(
          productId: p.product.id,
          name: p.product.name,
          qty: cart[p.product.id]!,
          unitPrice: p.product.priceCents,
          unitCost: p.product.costCents,
        ),
  ];
});

/// Resultado de la última venta, para la pantalla "Venta registrada".
class LastSale {
  const LastSale({
    required this.total,
    required this.profit,
    required this.change,
    required this.alerts,
  });
  final int total;
  final int profit;
  final int change;
  final List<String> alerts;
}

class LastSaleNotifier extends Notifier<LastSale?> {
  @override
  LastSale? build() => null;
  void set(LastSale s) => state = s;
}

final lastSaleProvider =
    NotifierProvider<LastSaleNotifier, LastSale?>(LastSaleNotifier.new);
