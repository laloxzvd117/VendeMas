import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/product_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/sale.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _registerSale();
  }

  void _registerSale() {
    final cart = context.read<CartProvider>();
    final saleProvider = context.read<SaleProvider>();
    final productProvider = context.read<ProductProvider>();

    final items = cart.itemList.map((ci) => SaleItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      saleId: '',
      productId: ci.product.id,
      productName: ci.product.name,
      quantity: ci.quantity,
      unitPrice: ci.product.price,
      unitCost: ci.product.cost,
    )).toList();

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      businessId: '',
      timestamp: DateTime.now(),
      total: cart.total,
      profit: cart.totalProfit,
      received: cart.received ?? cart.total,
      change: cart.change > 0 ? cart.change : 0,
      synced: false,
      items: items,
    );

    saleProvider.addSale(sale);

    for (final ci in cart.itemList) {
      if (ci.product.trackStock) {
        productProvider.updateStock(ci.product.id, ci.product.stock - ci.quantity);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = context.read<CartProvider>();
    final total = cart.total;
    final change = cart.change;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 48, color: colorScheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 24),
              Text('Venta registrada',
                style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(Formatters.currency(total),
                style: const TextStyle(fontSize: 32)),
              if (change > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Cambio: ${Formatters.currency(change)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer)),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    cart.clear();
                    context.go('/sell');
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Nueva venta', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    cart.clear();
                    context.go('/home');
                  },
                  child: const Text('Ir al inicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
