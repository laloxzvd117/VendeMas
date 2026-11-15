import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/reports.dart';
import 'report_texts.dart';

/// Tarjeta del resumen semanal para compartir como imagen (RF-20).
/// Siempre usa el tema claro para que la imagen se vea igual en todos lados.
class WeekShareCard extends StatelessWidget {
  const WeekShareCard({
    super.key,
    required this.business,
    required this.week,
    required this.top,
  });
  final String business;
  final WeekSummary week;
  final List<ProductStat> top;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildTheme(Brightness.light),
      child: Builder(builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        final w = week;
        final maxDay = w.days.map((d) => d.sales).fold(0, (a, b) => a > b ? a : b);
        final pct = w.percent;

        Widget kpi(String label, String value, {Color? color}) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700, color: color ?? cs.onSurface)),
                  ],
                ),
              ),
            );

        return Material(
          color: cs.surface,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cs.primary, Color.lerp(cs.primary, Colors.black, 0.25)!],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.storefront, color: cs.onPrimary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(business,
                              overflow: TextOverflow.ellipsis,
                              style: tt.titleMedium?.copyWith(
                                  color: cs.onPrimary, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      Text('RESUMEN SEMANAL',
                          style: tt.labelSmall?.copyWith(
                              color: cs.onPrimary.withAlpha(200), letterSpacing: 1.2)),
                      Text(weekLabel(w),
                          style: tt.bodyMedium?.copyWith(color: cs.onPrimary)),
                      const SizedBox(height: 12),
                      Text('Vendido',
                          style: tt.bodySmall?.copyWith(color: cs.onPrimary.withAlpha(200))),
                      Text(money(w.sales),
                          style: tt.displaySmall?.copyWith(
                              color: cs.onPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(children: [
                    kpi('Ganancia', money(w.profit)),
                    const SizedBox(width: 8),
                    kpi('Ventas', '${w.tickets}'),
                    const SizedBox(width: 8),
                    kpi('Vs. anterior', pct == null ? '—' : signed(pct),
                        color: pct == null
                            ? null
                            : (pct >= 0 ? cs.primary : cs.error)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text('Ventas por día', style: tt.titleSmall),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SizedBox(
                    height: 130,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final d in w.days)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(d.sales == 0 ? '' : compactMoney(d.sales),
                                      style: tt.labelSmall?.copyWith(fontSize: 9)),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: maxDay == 0 || d.sales == 0
                                        ? 3
                                        : 88 * d.sales / maxDay,
                                    decoration: BoxDecoration(
                                      color: w.hasSales && d.sales == maxDay
                                          ? cs.primary
                                          : cs.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(dayShort[d.day.weekday - 1],
                                      style: tt.labelSmall),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (top.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text('Lo que más dejó', style: tt.titleSmall),
                  ),
                  for (var i = 0; i < top.length && i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: i == 0 ? cs.primary : cs.secondaryContainer,
                          foregroundColor:
                              i == 0 ? cs.onPrimary : cs.onSecondaryContainer,
                          child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(top[i].name,
                              overflow: TextOverflow.ellipsis, style: tt.bodyMedium),
                        ),
                        Text('${top[i].units} pzas · ${money(top[i].profit)}',
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ]),
                    ),
                ],
                if (w.hasSales)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      'Mejor día: ${dayLong[w.bestDay.day.weekday - 1]}, '
                      'con ${money(w.bestDay.sales)}.',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  child: Row(children: [
                    Icon(Icons.bar_chart, size: 16, color: cs.outline),
                    const SizedBox(width: 6),
                    Text('Hecho con VendeMas',
                        style: tt.labelSmall?.copyWith(color: cs.outline)),
                  ]),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
