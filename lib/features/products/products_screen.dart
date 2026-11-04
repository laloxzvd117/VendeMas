import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../providers.dart';
import 'add_product_sheet.dart';

/// F-06: catálogo con costo, precio y margen.
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final list = ref.watch(productsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          OutlinedButton.icon(
            onPressed: () => showAddProductSheet(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar producto'),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                        '${list.length} ${list.length == 1 ? 'producto' : 'productos'}',
                        style: tt.titleSmall?.copyWith(color: cs.primary)),
                  ),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Todavía no tienes productos.'),
                    ),
                  for (final p in list)
                    ListTile(
                      title: Text(p.product.name),
                      subtitle: Text(
                          'Costo ${money2(p.product.costCents)} · Precio ${money2(p.product.priceCents)}'
                          '${p.tracked ? ' · Hay ${p.stock}' : ''}'),
                      trailing: _MarginTag(p.margin),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarginTag extends StatelessWidget {
  const _MarginTag(this.margin);
  final double margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = margin.round();
    final (bg, fg) = m >= 55
        ? (cs.primaryContainer, cs.onPrimaryContainer)
        : m >= 40
            ? (cs.tertiaryContainer, cs.onTertiaryContainer)
            : (cs.errorContainer, cs.onErrorContainer);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text('Margen $m%',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: fg)),
    );
  }
}
