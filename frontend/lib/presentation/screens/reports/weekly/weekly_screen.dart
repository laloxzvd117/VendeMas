import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final sales = [850, 880, 960, 1010, 1190, 1450, 1161];
    final maxSale = sales.reduce((a, b) => a > b ? a : b).toDouble();
    final weekTotal = sales.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen semanal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Venta de la semana',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer)),
                Text(Formatters.currency(weekTotal.toDouble()),
                  style: TextStyle(fontSize: 32, color: colorScheme.onPrimaryContainer)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ganancia: ${Formatters.currency(weekTotal * 0.589)}',
                      style: TextStyle(fontSize: 14, color: colorScheme.onPrimaryContainer)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('+2%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Venta por día',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
          const SizedBox(height: 8),

          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio = sales[i] / maxSale;
                final isHighest = sales[i] == maxSale.toInt();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(Formatters.currency(sales[i].toDouble()),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isHighest ? FontWeight.w500 : FontWeight.w400,
                            color: isHighest ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isHighest ? colorScheme.primary : colorScheme.secondaryContainer,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(days[i],
                          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
                const SizedBox(height: 8),
                _SummaryRow(label: 'Tickets totales', value: '167'),
                _SummaryRow(label: 'Ticket promedio', value: Formatters.currency(weekTotal / 167)),
                _SummaryRow(label: 'Mejor día', value: 'Sábado (${Formatters.currency(1450)})'),
                _SummaryRow(label: 'Margen promedio', value: '58.9%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
