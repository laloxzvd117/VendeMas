import 'package:flutter/material.dart';
import '../../../core/data/report_data.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/desk_widgets.dart';

class DeskDeadView extends StatelessWidget {
  const DeskDeadView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = ReportData.dead.fold(0.0, (s, p) => s + p.$4);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Capital atrapado',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onTertiaryContainer)),
              Text(Formatters.currency(total),
                style: TextStyle(fontSize: 44, color: cs.onTertiaryContainer)),
              Text('en ${ReportData.dead.length} productos sin movimiento',
                style: TextStyle(fontSize: 14, color: cs.onTertiaryContainer)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DeskCard(
          child: Column(
            children: [
              for (final p in ReportData.dead)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.$1),
                  subtitle: Text('${p.$2} días sin venta · ${p.$3} en stock'),
                  trailing: Text(Formatters.currency(p.$4),
                    style: TextStyle(fontWeight: FontWeight.w500, color: cs.tertiary)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const DeskCard(
          title: 'Sugerencia',
          child: Text('Considera bajar el precio o hacer promociones para mover estos productos y recuperar tu inversión.'),
        ),
      ],
    );
  }
}
