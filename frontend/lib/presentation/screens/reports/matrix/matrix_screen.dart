import 'package:flutter/material.dart';

class MatrixScreen extends StatelessWidget {
  const MatrixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final quads = [
      ('Estrellas', 'Alta rotación + alto margen', colorScheme.primaryContainer, colorScheme.onPrimaryContainer,
       ['Café americano', 'Concha', 'Cuernito']),
      ('Joyas ocultas', 'Baja rotación + alto margen', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer,
       ['Pan de muerto', 'Rebanada de pastel', 'Pan integral']),
      ('Alto volumen', 'Alta rotación + bajo margen', colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer,
       ['Bolillo', 'Dona glaseada']),
      ('Revisar', 'Baja rotación + bajo margen', colorScheme.surfaceContainerHighest, colorScheme.onSurfaceVariant,
       ['Empanada', 'Tamal', 'Galleta de avena']),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Margen y rotación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: quads.map((q) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: q.$3,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.$1, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: q.$4)),
                const SizedBox(height: 2),
                Text(q.$2, style: TextStyle(fontSize: 12, color: q.$4.withValues(alpha: 0.85))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: q.$5.map((name) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                  )).toList(),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}
