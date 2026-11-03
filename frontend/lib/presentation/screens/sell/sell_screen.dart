import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_tile.dart';
import '../../widgets/cart_bar.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final activeProducts = products.activeProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva venta'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => cart.clear(),
              tooltip: 'Vaciar carrito',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: activeProducts.length,
              itemBuilder: (context, index) {
                final product = activeProducts[index];
                final qty = cart.items[product.id]?.quantity ?? 0;
                return ProductTile(
                  product: product,
                  cartQuantity: qty,
                  onTap: () => cart.addProduct(product),
                  onRemove: qty > 0 ? () => cart.removeOne(product.id) : null,
                );
              },
            ),
          ),
          if (!cart.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CartBar(
                itemCount: cart.totalItems,
                total: cart.total,
                onTap: () => context.go('/pay'),
              ),
            ),
        ],
      ),
    );
  }
}
