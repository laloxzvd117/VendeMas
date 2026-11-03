import 'package:flutter/material.dart';
import '../../../core/data/report_data.dart';
import '../widgets/desk_widgets.dart';

class DeskAbcView extends StatelessWidget {
  const DeskAbcView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg(String k) => switch (k) {
      'A' => cs.primaryContainer,
      'B' => cs.tertiaryContainer,
      _ => cs.surfaceContainerHighest,
    };
    Color fg(String k) => switch (k) {
      'A' => cs.onPrimaryContainer,
      'B' => cs.onTertiaryContainer,
      _ => cs.onSurfaceVariant,
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('3 productos A generan el 72.5% de la ganancia',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.primary)),
        const SizedBox(height: 16),
        DeskCard(
          child: Column(
            children: [
              for (final item in ReportData.abc)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: bg(item.$2), shape: BoxShape.circle),
                        child: Text(item.$2,
                          style: TextStyle(fontWeight: FontWeight.w600, color: fg(item.$2))),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(width: 190, child: Text(item.$1, style: const TextStyle(fontSize: 15))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            minHeight: 12,
                            value: item.$4 / 100,
                            backgroundColor: cs.surfaceContainerHighest,
                            color: item.$2 == 'A' ? cs.primary : item.$2 == 'B' ? cs.tertiary : cs.outline,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text('${item.$3.toStringAsFixed(1)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
