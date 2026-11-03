import 'package:flutter/material.dart';
import '../../../core/data/report_data.dart';

class DeskMatrixView extends StatelessWidget {
  const DeskMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = [
      (cs.primaryContainer, cs.onPrimaryContainer),
      (cs.secondaryContainer, cs.onSecondaryContainer),
      (cs.tertiaryContainer, cs.onTertiaryContainer),
      (cs.surfaceContainerHighest, cs.onSurfaceVariant),
    ];

    Widget quad(int i) {
      final q = ReportData.matrix[i];
      final (bg, fg) = colors[i];
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.$1, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: fg)),
            const SizedBox(height: 2),
            Text(q.$2, style: TextStyle(fontSize: 13, color: fg)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: q.$3
                  .map((p) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(p, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Expanded(child: quad(1)), const SizedBox(width: 16), Expanded(child: quad(0))],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Expanded(child: quad(3)), const SizedBox(width: 16), Expanded(child: quad(2))],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('← Menor rotación', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            Text('Mayor rotación →', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
