import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../providers.dart';

/// F-05: venta registrada.
class DoneScreen extends ConsumerWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = ref.watch(lastSaleProvider);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Listo')),
      body: l == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                        color: cs.primaryContainer, shape: BoxShape.circle),
                    child: Icon(Icons.check,
                        size: 48, color: cs.onPrimaryContainer),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Venta registrada',
                    textAlign: TextAlign.center, style: tt.headlineSmall),
                const SizedBox(height: 8),
                Text(money(l.total),
                    textAlign: TextAlign.center, style: tt.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Ganaste ${money(l.profit)} en esta venta.'
                  '${l.change > 0 ? ' Cambio entregado: ${money2(l.change)}.' : ''}',
                  textAlign: TextAlign.center,
                ),
                if (l.alerts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('Se está acabando · ${l.alerts.join('; ')}',
                        style: TextStyle(color: cs.onTertiaryContainer)),
                  ),
                ],
                const SizedBox(height: 4),
                Text('Guardada en tu teléfono.',
                    textAlign: TextAlign.center,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                      onPressed: () => context.go('/sell'),
                      child: const Text('Nueva venta')),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Ir al inicio')),
                ),
              ],
            ),
    );
  }
}
