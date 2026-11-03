import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

class AbcScreen extends StatelessWidget {
  const AbcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final data = [
      ('Café americano', 'A', 33.1, 33.1),
      ('Concha', 'A', 21.4, 54.5),
      ('Bolillo', 'A', 18.0, 72.5),
      ('Cuernito', 'B', 11.0, 83.5),
      ('Pan de muerto', 'B', 7.7, 91.2),
      ('Dona glaseada', 'B', 7.7, 98.9),
      ('Empanada', 'C', 5.5, 97.7),
      ('Tamal', 'C', 3.9, 98.6),
      ('Rebanada de pastel', 'C', 2.3, 99.2),
      ('Pan integral', 'C', 1.2, 99.9),
      ('Galleta de avena', 'C', 0.2, 100.0),
    ];

    Color classColor(String k) => switch (k) {
      'A' => colorScheme.primaryContainer,
      'B' => colorScheme.tertiaryContainer,
      _ => colorScheme.surfaceContainerHighest,
    };

    Color classTextColor(String k) => switch (k) {
      'A' => colorScheme.onPrimaryContainer,
      'B' => colorScheme.onTertiaryContainer,
      _ => colorScheme.onSurfaceVariant,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Clasificación ABC')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('3 productos A generan el 72.5% de la ganancia',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          ...data.map((item) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: classColor(item.$2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(item.$2,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: classTextColor(item.$2))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item.$1, style: const TextStyle(fontSize: 16))),
                Text('${item.$3.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
