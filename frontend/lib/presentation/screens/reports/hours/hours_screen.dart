import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

class HoursScreen extends StatelessWidget {
  const HoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hours = [
      (7, 180), (8, 620), (9, 540), (10, 310), (11, 260), (12, 330), (13, 410),
      (14, 280), (15, 240), (16, 420), (17, 610), (18, 560), (19, 320), (20, 150),
    ];

    final maxVal = hours.map((h) => h.$2).reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Horas fuertes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Distribución de ventas por hora',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: hours.map((h) {
                final ratio = h.$2 / maxVal;
                final isHigh = h.$2 >= 550;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isHigh ? colorScheme.primary : colorScheme.secondaryContainer,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${h.$1}',
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
                Text('Horarios pico',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary)),
                const SizedBox(height: 8),
                _HourTip(icon: Icons.circle, color: colorScheme.primary, text: '8:00 - 9:00 AM → ${Formatters.currency(1160)} (mañana)'),
                _HourTip(icon: Icons.circle, color: colorScheme.primary, text: '5:00 - 6:00 PM → ${Formatters.currency(1170)} (tarde)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HourTip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _HourTip({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
