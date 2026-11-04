import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../domain/calculations.dart';
import '../../providers.dart';

/// F-04: total, monto recibido y cambio.
class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({super.key});
  @override
  ConsumerState<PayScreen> createState() => _State();
}

class _State extends ConsumerState<PayScreen> {
  final _ctrl = TextEditingController();
  int? _received;
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _pick(int cents) {
    _ctrl.text = (cents / 100).toStringAsFixed(cents % 100 == 0 ? 0 : 2);
    setState(() => _received = cents);
  }

  Future<void> _confirm() async {
    final items = ref.read(cartItemsProvider);
    final total = saleTotal(items);
    final received = _received;
    if (_busy || !canCharge(total: total, received: received)) return;
    setState(() => _busy = true);

    final products = ref.read(productsProvider).value ?? const [];
    final byId = {for (final p in products) p.product.id: p};
    final tracked = {
      for (final p in products)
        if (p.tracked) p.product.id
    };
    final alerts = <String>[];
    for (final i in items) {
      final p = byId[i.productId];
      if (p != null && p.tracked) {
        final left = (p.stock - i.qty).clamp(0, 1 << 30);
        if (left <= p.product.minStock) {
          alerts.add('${p.product.name}: ${left == 0 ? 'se agotó' : 'quedan $left'}');
        }
      }
    }

    await ref.read(databaseProvider).recordSale(
          items: items,
          receivedCents: received!,
          trackedIds: tracked,
        );
    ref.read(lastSaleProvider.notifier).set(LastSale(
          total: total,
          profit: saleProfit(items),
          change: changeFor(total: total, received: received),
          alerts: alerts,
        ));
    ref.read(cartProvider.notifier).clear();
    if (mounted) context.go('/sell/done');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final items = ref.watch(cartItemsProvider);
    final total = saleTotal(items);
    final r = _received;
    final ch = r == null ? null : changeFor(total: total, received: r);
    final ok = canCharge(total: total, received: r);

    final (boxBg, boxFg, label, value) = switch (ch) {
      null => (cs.surfaceContainerHighest, cs.onSurfaceVariant, 'Cambio', '—'),
      < 0 => (cs.errorContainer, cs.onErrorContainer, 'Faltan', money2(-ch)),
      _ => (cs.primaryContainer, cs.onPrimaryContainer, 'Cambio', money2(ch)),
    };

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/sell')),
        title: const Text('Cobrar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen',
                      style: tt.titleSmall?.copyWith(color: cs.primary)),
                  for (final i in items)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Text('${i.qty} × ${i.name}')),
                          Text(money(i.subtotal), style: tt.titleSmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Total a cobrar',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          Text(money(total), style: tt.headlineLarge),
          const SizedBox(height: 16),
          Text('¿Con cuánto paga? Elige una opción o escribe el monto.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Exacto'),
                selected: r == total,
                onSelected: (_) => _pick(total),
              ),
              for (final v in suggestedCash(total))
                ChoiceChip(
                  label: Text(money(v)),
                  selected: r == v,
                  onSelected: (_) => _pick(v),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto recibido',
              helperText: 'Si no hay cambio que dar, elige Exacto.',
              prefixText: r'$ ',
              border: OutlineInputBorder(),
            ),
            onChanged: (t) => setState(() => _received = parseCents(t)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: boxBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: tt.titleSmall?.copyWith(color: boxFg)),
                Text(value, style: tt.headlineSmall?.copyWith(color: boxFg)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: ok && !_busy ? _confirm : null,
              child: const Text('Confirmar cobro'),
            ),
          ),
        ],
      ),
    );
  }
}
