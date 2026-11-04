import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../providers.dart';

/// F-02: resumen del día.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = ref.watch(businessNameProvider).value ?? '';
    final today = ref.watch(todayProvider).value;
    final recent = ref.watch(recentSalesProvider).value ?? const [];
    final low = (ref.watch(productsProvider).value ?? const [])
        .where((p) => p.isLow || p.isOut)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/sell'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva venta'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          Text(longDate(DateTime.now()),
              style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          Card(
            color: cs.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: cs.onPrimaryContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vendido hoy'),
                    Text(money(today?.sales ?? 0),
                        style: tt.displaySmall
                            ?.copyWith(color: cs.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ganancia ${money(today?.profit ?? 0)}'),
                        Text('${today?.tickets ?? 0} ventas'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (low.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: cs.tertiaryContainer,
              child: ListTile(
                leading: Icon(Icons.warning_amber, color: cs.onTertiaryContainer),
                title: Text(
                  '${low.length} ${low.length == 1 ? 'producto se está acabando' : 'productos se están acabando'}',
                  style: TextStyle(color: cs.onTertiaryContainer),
                ),
                subtitle: Text(
                  low.take(3).map((p) => p.product.name).join(', '),
                  style: TextStyle(color: cs.onTertiaryContainer),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text('Ventas recientes',
                        style: tt.titleSmall?.copyWith(color: cs.primary)),
                  ),
                  if (recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aún no hay ventas. Toca «Nueva venta».'),
                    ),
                  for (final s in recent)
                    ListTile(
                      title: Text(s.summary),
                      subtitle: Text(hm(s.createdAt)),
                      trailing: Text(money(s.totalCents),
                          style: tt.titleMedium),
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
