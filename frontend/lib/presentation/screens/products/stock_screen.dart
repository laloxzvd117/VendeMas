import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final products = context.watch<ProductProvider>();
    final tracked = products.products.where((p) => p.trackStock).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Existencias')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tracked.length,
        itemBuilder: (context, index) {
          final p = tracked[index];
          final isLow = p.stock <= p.minStock;
          final isOut = p.stock <= 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(p.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: p.minStock > 0 ? (p.stock / (p.minStock * 3)).clamp(0, 1) : 1,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: isOut ? colorScheme.error : isLow ? colorScheme.tertiary : colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text('${p.stock} / mín. ${p.minStock}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOut)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Agotado',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onErrorContainer)),
                    )
                  else if (isLow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Bajo',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onTertiaryContainer)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(context, p.id, p.name, p.stock),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, String productId, String name, int currentStock) {
    final controller = TextEditingController(text: currentStock.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ajustar stock: $name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuevo stock',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                context.read<ProductProvider>().updateStock(productId, newStock);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
