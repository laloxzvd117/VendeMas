import 'package:flutter/material.dart';
import '../../../core/data/report_data.dart';
import '../../../core/utils/formatters.dart';

class DeskTrendView extends StatelessWidget {
  const DeskTrendView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Cambios esta semana vs anterior',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.primary)),
        const SizedBox(height: 4),
        Text('Solo productos con cambio ≥ 8% y al menos 3 unidades',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const SizedBox(height: 16),
        for (final t in ReportData.trends)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  t.$4 > 0 ? Icons.trending_up : Icons.trending_down,
                  color: t.$4 > 0 ? cs.primary : cs.error,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text('${t.$2} uds esta semana · ${t.$3} la anterior',
                        style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: t.$4 > 0 ? cs.primaryContainer : cs.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(Formatters.signedPercent(t.$4),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: t.$4 > 0 ? cs.onPrimaryContainer : cs.onErrorContainer,
                    )),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
