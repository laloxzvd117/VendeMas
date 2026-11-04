import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../domain/calculations.dart';
import '../../providers.dart';

/// F-03: arma la venta tocando productos.
class SellScreen extends ConsumerWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final products = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);
    final items = ref.watch(cartItemsProvider);
    final n = pieceCount(items);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva venta')),
      body: Column(
        children: [
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                            'Primero agrega productos en la pestaña Productos.',
                            textAlign: TextAlign.center),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisExtent: 104,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) =>
                          _Tile(p: list[i], qty: cart[list[i].product.id] ?? 0),
                    ),
            ),
          ),
          Material(
            color: cs.surfaceContainerHigh,
            elevation: 3,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$n ${n == 1 ? 'pieza' : 'piezas'}',
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                          Text(money(saleTotal(items)),
                              style: tt.headlineSmall),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: n == 0 ? null : () => context.go('/sell/pay'),
                      child: const Text('Cobrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends ConsumerWidget {
  const _Tile({required this.p, required this.qty});
  final ProductView p;
  final int qty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final on = qty > 0;
    final fg = on ? cs.onSecondaryContainer : cs.onSurface;

    return Opacity(
      opacity: p.isOut ? .6 : 1,
      child: Material(
        color: on ? cs.secondaryContainer : cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: on ? BorderSide.none : BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            InkWell(
              onTap: p.isOut
                  ? null
                  : () {
                      final msg = ref.read(cartProvider.notifier).add(p);
                      if (msg != null) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text(msg)));
                      }
                    },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 28),
                      child: Text(p.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(color: fg)),
                    ),
                    if (p.tracked)
                      Text(p.isOut ? 'Agotado' : 'Quedan ${p.stock}',
                          style: tt.labelMedium?.copyWith(
                              color: p.isOut
                                  ? cs.error
                                  : p.isLow
                                      ? cs.tertiary
                                      : cs.onSurfaceVariant)),
                    Text(money2(p.product.priceCents),
                        style: tt.bodyMedium?.copyWith(color: fg)),
                  ],
                ),
              ),
            ),
            if (on) ...[
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: cs.primary, borderRadius: BorderRadius.circular(12)),
                  child: Text('$qty',
                      style: tt.labelMedium?.copyWith(color: cs.onPrimary)),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: IconButton(
                  tooltip: 'Quitar uno',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                      backgroundColor: cs.surface,
                      side: BorderSide(color: cs.outlineVariant)),
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).remove(p.product.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
