import 'package:flutter/material.dart';
import '../../../core/data/report_data.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/desk_widgets.dart';

class DeskWeeklyView extends StatefulWidget {
  const DeskWeeklyView({super.key});

  @override
  State<DeskWeeklyView> createState() => _DeskWeeklyViewState();
}

class _DeskWeeklyViewState extends State<DeskWeeklyView> {
  int _week = ReportData.weekTotals.length - 1;

  bool get _isLatest => _week == ReportData.weekTotals.length - 1;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = ReportData.weekTotals[_week];
    final prev = _week > 0 ? ReportData.weekTotals[_week - 1] : null;
    final delta = prev == null ? null : ((total - prev) / prev * 100).round();
    final first = ReportData.weekTotals.first;
    final growth = ((ReportData.weekTotals.last - first) / first * 100).round();

    final baseSum = ReportData.dayBase.fold(0, (a, b) => a + b);
    final days = ReportData.dayBase.map((d) => (d * total / baseSum).round()).toList();
    final bestIdx = days.indexOf(days.reduce((a, b) => a > b ? a : b));
    final tickets = (ReportData.ticketsLatest * total / ReportData.weekTotals.last).round();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _week > 0 ? () => setState(() => _week--) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Column(
              children: [
                Text('Semana del ${ReportData.weekRanges[_week]}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(_isLatest ? 'Última semana completa' : 'Semana anterior',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
              ],
            ),
            IconButton(
              onPressed: !_isLatest ? () => setState(() => _week++) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vendido en la semana',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onPrimaryContainer)),
              const SizedBox(height: 4),
              Text(Formatters.currency(total),
                style: TextStyle(fontSize: 44, color: cs.onPrimaryContainer)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ganancia ${Formatters.currency(total * ReportData.marginPct / 100)}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onPrimaryContainer)),
                  if (delta != null)
                    Text('${Formatters.signedPercent(delta)} vs. semana anterior',
                      style: TextStyle(fontSize: 14, color: cs.onPrimaryContainer)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DeskCard(
          title: 'Últimas 8 semanas',
          subtitle: 'Tus ventas ${growth >= 0 ? 'subieron' : 'bajaron'} ${growth.abs()}% en 8 semanas. Toca una semana para verla.',
          child: DeskBars(
            values: ReportData.weekTotals,
            labels: ReportData.weekLabels,
            valueLabels: ReportData.weekTotals.map((v) => '\$${(v / 1000).toStringAsFixed(1)}k').toList(),
            highlight: _week,
            height: 200,
            onTap: (i) => setState(() => _week = i),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: DeskCard(
                title: 'Ventas por día',
                child: DeskBars(
                  values: days,
                  labels: ReportData.dayLabels,
                  valueLabels: days.map((v) => Formatters.currency(v)).toList(),
                  highlightMax: true,
                  height: 190,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DeskCard(
                title: 'Resumen',
                child: Column(
                  children: [
                    DeskStatRow(label: 'Tickets totales', value: '$tickets'),
                    DeskStatRow(label: 'Ticket promedio', value: Formatters.currency(total / tickets)),
                    DeskStatRow(
                      label: 'Mejor día',
                      value: '${ReportData.dayLabels[bestIdx]} (${Formatters.currency(days[bestIdx])})',
                    ),
                    DeskStatRow(label: 'Margen promedio', value: '${ReportData.marginPct}%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
