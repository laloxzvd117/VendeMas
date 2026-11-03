import 'package:flutter/material.dart';
import '../../../core/data/report_data.dart';
import '../widgets/desk_widgets.dart';

class DeskPairsView extends StatelessWidget {
  const DeskPairsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Productos que se compran en la misma venta',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.primary)),
        const SizedBox(height: 16),
        for (var i = 0; i < ReportData.pairs.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
                  child: Text('${i + 1}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: cs.onPrimaryContainer)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('${ReportData.pairs[i].$1}  +  ${ReportData.pairs[i].$2}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                Text('${ReportData.pairs[i].$3} veces juntos',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        const DeskCard(
          title: 'Sugerencia',
          child: Text('Prueba un combo de café con concha: es la pareja que más se repite en tus ventas.'),
        ),
      ],
    );
  }
}
