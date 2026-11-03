import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/sale_list_item.dart';
import '../../../core/utils/formatters.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final biz = context.watch<BusinessProvider>();
    final products = context.watch<ProductProvider>();
    final sales = context.watch<SaleProvider>();
    final lowStock = products.lowStockProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(biz.business?.name ?? 'VendeMas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          if (!biz.isOnline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 20, color: colorScheme.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin conexión · ${biz.pendingSync} pendientes',
                      style: TextStyle(color: colorScheme.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),

          Text(Formatters.dateHeader(DateTime.now()),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),

          HeroCard(
            label: 'Venta del día',
            amount: sales.today.sales,
            secondaryLabel: 'Ganancia',
            secondaryValue: Formatters.currency(sales.today.profit),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actividad reciente',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
                const SaleListItem(time: '12:41', description: '2 × Concha, 1 × Café americano', total: 55),
                const SaleListItem(time: '12:18', description: '3 × Bolillo, 1 × Empanada', total: 37),
                const SaleListItem(time: '11:52', description: '1 × Pan de muerto, 1 × Café americano', total: 60),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (lowStock.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.tertiary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, size: 20, color: colorScheme.tertiary),
                      const SizedBox(width: 8),
                      Text('Stock bajo',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.tertiary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...lowStock.map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.name),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${p.stock}',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: colorScheme.onTertiaryContainer)),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/sell'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva venta'),
      ),
    );
  }
}
