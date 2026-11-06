import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../domain/reports.dart';
import '../../providers.dart';
import 'add_product_sheet.dart';
import 'stock_sheet.dart';

/// F-06: catálogo con costo, precio y margen. F-08: existencias.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});
  @override
  ConsumerState<ProductsScreen> createState() => _State();
}

class _State extends ConsumerState<ProductsScreen> {
  bool _stockView = false;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(productsProvider).value ?? const <ProductView>[];
    final attention = list.where((p) => p.isLow || p.isOut).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          SegmentedButton<bool>(
            segments: [
              const ButtonSegment(value: false, label: Text('Catálogo')),
              ButtonSegment(
                value: true,
                label: Text(attention > 0
                    ? 'Existencias · $attention'
                    : 'Existencias'),
              ),
            ],
            selected: {_stockView},
            onSelectionChanged: (s) => setState(() => _stockView = s.first),
          ),
          const SizedBox(height: 12),
          if (_stockView) _StockView(list) else _Catalog(list),
        ],
      ),
    );
  }
}

class _Catalog extends StatelessWidget {
  const _Catalog(this.list);
  final List<ProductView> list;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}

/// F-08: qué se está acabando y cuánto alcanza lo que hay.
class _StockView extends ConsumerWidget {
  const _StockView(this.list);
  final List<ProductView> list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final data = ref.watch(reportDataProvider).value;
    final units = <String, int>{
      if (data != null)
        for (final s in productStats(data)) s.id: s.units,
    };
    String cover(ProductView p) =>
        coverText(stock: p.stock, unitsLast30: units[p.product.id] ?? 0);

    final low = list.where((p) => p.isLow || p.isOut).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));

    Widget tag(ProductView p) {
      if (!p.tracked) {
        return Text('Sin control', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant));
      }
      final (bg, fg, text) = p.isOut
          ? (cs.errorContainer, cs.onErrorContainer, 'Agotado')
          : p.isLow
              ? (cs.tertiaryContainer, cs.onTertiaryContainer, 'Poco')
              : (cs.primaryContainer, cs.onPrimaryContainer, 'Bien');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: tt.labelMedium?.copyWith(color: fg)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: low.isEmpty ? cs.primaryContainer : cs.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: low.isEmpty
                ? Text('Todo está bien: nada se está acabando.',
                    style: TextStyle(color: cs.onPrimaryContainer))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${low.length} ${low.length == 1 ? 'producto se está acabando' : 'productos se están acabando'}',
                        style: tt.titleSmall?.copyWith(color: cs.onTertiaryContainer),
                      ),
                      const SizedBox(height: 8),
                      for (final p in low)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${p.product.name}: ${p.isOut ? 'agotado' : 'quedan ${p.stock}'}'
                            '${p.isOut ? '' : ' · ${cover(p)}'}',
                            style: TextStyle(color: cs.onTertiaryContainer),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('Todos los productos',
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
                    subtitle: Text(p.tracked
                        ? 'Hay ${p.stock} · ${cover(p)}'
                        : 'No llevas existencias de este producto.'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        tag(p),
                        TextButton(
                          onPressed: () => showStockSheet(context, p),
                          child: Text(p.tracked ? 'Actualizar' : 'Activar'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
