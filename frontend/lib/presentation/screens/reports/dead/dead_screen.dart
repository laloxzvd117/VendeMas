import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

class DeadScreen extends StatelessWidget {
  const DeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final deadProducts = [
      ('Pan integral', 21, 12, 192.0),
      ('Galleta de avena', 34, 30, 150.0),
    ];

    final totalTrapped = deadProducts.fold(0.0, (sum, p) => sum + p.$4);

    return Scaffold(
      appBar: AppBar(title: const Text('Productos muertos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Capital atrapado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onTertiaryContainer)),
                Text(Formatters.currency(totalTrapped),
                  style: TextStyle(fontSize: 32, color: colorScheme.onTertiaryContainer)),
                Text('en ${deadProducts.length} productos sin movimiento',
                  style: TextStyle(fontSize: 14, color: colorScheme.onTertiaryContainer)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...deadProducts.map((p) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(p.$1),
              subtitle: Text('${p.$2} días sin venta · ${p.$3} en stock'),
              trailing: Text(Formatters.currency(p.$4),
                style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.tertiary)),
            ),
          )),
          const SizedBox(height: 16),
          Text('Sugerencia',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
          const SizedBox(height: 8),
          const Text('Considera bajar el precio o hacer promociones para mover estos productos y recuperar tu inversión.'),
        ],
      ),
    );
  }
}
