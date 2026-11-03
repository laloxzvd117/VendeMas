import 'package:flutter/material.dart';

class TrendScreen extends StatelessWidget {
  const TrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final trends = [
      ('Pan de muerto', 24, 13, 85),
      ('Café americano', 74, 66, 12),
      ('Dona glaseada', 28, 41, -32),
      ('Bolillo', 215, 236, -9),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tendencias')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Cambios esta semana vs anterior',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
          const SizedBox(height: 4),
          Text('Solo productos con cambio ≥ 8% y al menos 3 unidades',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          ...trends.map((t) {
            final isUp = t.$4 > 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    width: 4,
                    color: isUp ? colorScheme.primary : colorScheme.error,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('${t.$2} uds esta semana · ${t.$3} la anterior',
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUp ? colorScheme.primaryContainer : colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isUp ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isUp ? '+' : ''}${t.$4}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isUp ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
