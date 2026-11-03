import 'package:flutter/material.dart';

class PairsScreen extends StatelessWidget {
  const PairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final pairs = [
      ('Café americano', 'Concha', 58),
      ('Café americano', 'Pan de muerto', 34),
      ('Cuernito', 'Café americano', 27),
      ('Bolillo', 'Empanada', 21),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Se venden juntos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Productos que se compran en la misma venta',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
          const SizedBox(height: 16),
          ...pairs.asMap().entries.map((entry) {
            final i = entry.key;
            final pair = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('${i + 1}',
                      style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${pair.$1}  +  ${pair.$2}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Text('${pair.$3} veces juntos',
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sugerencia',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
                const SizedBox(height: 8),
                const Text('Coloca estos productos cerca uno del otro para facilitar la compra combinada.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
