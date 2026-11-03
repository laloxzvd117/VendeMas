import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../../core/utils/formatters.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _showCatalog = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final products = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2),
            onPressed: () => context.push('/products/stock'),
            tooltip: 'Existencias',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Catálogo')),
                ButtonSegment(value: false, label: Text('Existencias')),
              ],
              selected: {_showCatalog},
              onSelectionChanged: (v) => setState(() => _showCatalog = v.first),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.products.length,
              itemBuilder: (context, index) {
                final p = products.products[index];
                return ListTile(
                  title: Text(p.name, style: TextStyle(
                    color: p.isActive ? null : colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
                  subtitle: _showCatalog
                      ? Text('${Formatters.currency(p.price)} · Costo ${Formatters.currency(p.cost)} · Margen ${p.margin.toStringAsFixed(0)}%')
                      : p.trackStock
                          ? Text('${p.stock} unidades · Mínimo: ${p.minStock}')
                          : const Text('Sin control de existencias'),
                  trailing: _showCatalog
                      ? Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant)
                      : p.trackStock && p.stock <= p.minStock
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: p.stock <= 0 ? colorScheme.errorContainer : colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p.stock <= 0 ? 'Agotado' : 'Bajo',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: p.stock <= 0 ? colorScheme.onErrorContainer : colorScheme.onTertiaryContainer,
                                ),
                              ),
                            )
                          : null,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/add'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar producto'),
      ),
    );
  }
}
