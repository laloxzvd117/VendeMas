import 'package:flutter/material.dart';
import '../../../core/data/report_data.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/desk_widgets.dart';

class DeskHoursView extends StatelessWidget {
  const DeskHoursView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final values = ReportData.hours.map((h) => h.$2).toList();
    final peak = values.reduce((a, b) => a > b ? a : b);
    final strong = values.indexWhere((v) => v >= 550);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        DeskCard(
          title: 'Distribución de ventas por hora',
          child: DeskBars(
            values: values,
            labels: ReportData.hours.map((h) => '${h.$1}h').toList(),
            valueLabels: values.map((v) => '\$$v').toList(),
            highlight: strong >= 0 ? values.indexOf(peak) : null,
            height: 220,
          ),
        ),
        const SizedBox(height: 16),
        DeskCard(
          title: 'Horarios pico',
          child: Column(
            children: [
              _Tip(color: cs.primary, text: '8:00 - 9:00 AM → ${Formatters.currency(1160)} (mañana)'),
              _Tip(color: cs.primary, text: '5:00 - 6:00 PM → ${Formatters.currency(1170)} (tarde)'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  final Color color;
  final String text;
  const _Tip({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
