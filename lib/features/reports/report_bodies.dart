import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/reports.dart';
import '../../providers.dart';
import 'report_texts.dart';
import 'report_widgets.dart';

/// Contenido de cada reporte. Lo usan igual el celular (F-11 a F-18) y la
/// vista de computadora (F-23), así los números siempre coinciden.

/// Semana elegida en el resumen semanal: 0 = la más antigua, 7 = la actual.
class SelectedWeek extends Notifier<int> {
  @override
  int build() => 7;
  void set(int i) => state = i;
}

final selectedWeekProvider =
    NotifierProvider<SelectedWeek, int>(SelectedWeek.new);

/// Para capturar el resumen semanal como imagen (RF-20).
final weekCaptureKey = GlobalKey();

class _Scope extends ConsumerWidget {
  const _Scope({required this.builder});
  final Widget Function(ReportData d) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(reportDataProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('No se pudieron leer los datos: $e')),
          data: (d) => d.hasSales
              ? builder(d)
              : const EmptyReport(
                  'Cuando registres ventas, aquí verás este reporte.'),
        );
  }
}

const _pad = EdgeInsets.fromLTRB(16, 8, 16, 24);

// ───────────────────────── F-11 Más vendidos y rentables ─────────────────────────

class RankBody extends StatelessWidget {
  const RankBody({super.key});
  @override
  Widget build(BuildContext context) => _Scope(builder: (d) => _RankView(d));
}

class _RankView extends StatefulWidget {
  const _RankView(this.d);
  final ReportData d;
  @override
  State<_RankView> createState() => _RankViewState();
}

class _RankViewState extends State<_RankView> {
  bool _byUnits = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stats = productStats(widget.d);
    if (stats.isEmpty) {
      return const EmptyReport('No hay ventas en los últimos 30 días.');
    }
    final topU = rankByUnits(stats).first;
    final topP = rankByProfit(stats).first;
    final list = (_byUnits ? rankByUnits(stats) : rankByProfit(stats)).take(8).toList();
    num valueOf(ProductStat s) => _byUnits ? s.units : s.profit;
    final maxV = valueOf(list.first) <= 0 ? 1 : valueOf(list.first);

    return ListView(
      padding: _pad,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Por piezas')),
            ButtonSegment(value: false, label: Text('Por ganancia')),
          ],
          selected: {_byUnits},
          onSelectionChanged: (s) => setState(() => _byUnits = s.first),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Últimos 30 días',
          child: Column(
            children: [
              for (var i = 0; i < list.length; i++)
                BarRow(
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        i < 3 ? cs.primary : cs.surfaceContainerHighest,
                    foregroundColor: i < 3 ? cs.onPrimary : cs.onSurface,
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                  ),
                  label: list[i].name,
                  value: _byUnits ? '${list[i].units} pzas' : money(list[i].profit),
                  fraction: valueOf(list[i]) / maxV,
                  highlight: i == 0,
                ),
            ],
          ),
        ),
        Hint(topU.id == topP.id
            ? '${topU.name} es el que más vende y el que más ganancia deja.'
            : '${topU.name} vende más piezas, pero ${topP.name} deja más dinero. '
                'Mira las dos listas antes de decidir qué impulsar.'),
      ],
    );
  }
}

// ───────────────────────── F-12 Clasificación ABC ─────────────────────────

class AbcBody extends StatelessWidget {
  const AbcBody({super.key});
  @override
  Widget build(BuildContext context) => _Scope(builder: (d) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        final a = abcAnalysis(productStats(d));
        if (a.isEmpty) {
          return const EmptyReport('Aún no hay ganancia en los últimos 30 días.');
        }
        Widget chip(String g) {
          final (bg, fg) = switch (g) {
            'A' => (cs.primaryContainer, cs.onPrimaryContainer),
            'B' => (cs.tertiaryContainer, cs.onTertiaryContainer),
            _ => (cs.surfaceContainerHighest, cs.onSurface),
          };
          return Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
            child: Text(g,
                style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13)),
          );
        }

        return ListView(
          padding: _pad,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${a.countA} de ${a.total} '
                '${plural(a.total, 'producto genera', 'productos generan')} el '
                '${a.shareA.round()}% de tu ganancia.',
                style: tt.titleMedium,
              ),
            ),
            SectionCard(
              title: 'Por ganancia, de mayor a menor',
              child: Column(
                children: [
                  for (final r in a.rows)
                    BarRow(
                      leading: chip(r.grade),
                      label: r.stat.name,
                      value: percentText(r.share),
                      fraction: r.cumulative / 100,
                      highlight: r.grade == 'A',
                    ),
                ],
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    chip('A'),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Cuídalos: nunca te pueden faltar.')),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    chip('B'),
                    const SizedBox(width: 10),
                    const Expanded(
                        child: Text('Vigílalos: aportan, pero se pueden mejorar.')),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    chip('C'),
                    const SizedBox(width: 10),
                    const Expanded(
                        child: Text('Candidatos a dejar de hacer o comprar.')),
                  ]),
                ],
              ),
            ),
          ],
        );
      });
}

// ───────────────────────── F-13 Margen y rotación ─────────────────────────

class MatrixBody extends StatelessWidget {
  const MatrixBody({super.key});
  @override
  Widget build(BuildContext context) => _Scope(builder: (d) {
        final q = quadrants(productStats(d));
        if (q.isEmpty) {
          return const EmptyReport('No hay ventas en los últimos 30 días.');
        }
        final cs = Theme.of(context).colorScheme;
        Widget cell(String title, String help, List<ProductStat> items, Color bg, Color fg) {
          return Expanded(
            child: Card(
              color: bg,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: fg, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(help, style: TextStyle(color: fg, fontSize: 12)),
                    const SizedBox(height: 8),
                    if (items.isEmpty)
                      Text('Ninguno', style: TextStyle(color: fg))
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final s in items)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.surface.withAlpha(150),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(s.name,
                                  style: TextStyle(color: cs.onSurface, fontSize: 12)),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: _pad,
          children: [
            Hint('Arriba: dejan ${money(q.minUnitProfit)} o más por pieza. '
                'A la derecha: se venden ${q.minUnits} piezas o más en 30 días.'),
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                cell('Joyas escondidas', 'Véndelas más: dejan mucho.', q.gems,
                    cs.tertiaryContainer, cs.onTertiaryContainer),
                const SizedBox(width: 12),
                cell('Estrellas', 'Tenlas siempre listas.', q.stars,
                    cs.primaryContainer, cs.onPrimaryContainer),
              ]),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                cell('Revisar', 'Poco movimiento y poca ganancia.', q.review,
                    cs.surfaceContainerHighest, cs.onSurface),
                const SizedBox(width: 12),
                cell('Mucho movimiento, poco margen', 'Sube el precio o baja el costo.',
                    q.busy, cs.errorContainer, cs.onErrorContainer),
              ]),
            ),
          ],
        );
      });
}

// ───────────────────────── F-14 Productos muertos ─────────────────────────

class DeadBody extends StatelessWidget {
  const DeadBody({super.key});
  @override
  Widget build(BuildContext context) => _Scope(builder: (d) {
        final dead = deadProducts(d);
        if (dead.isEmpty) {
          return const EmptyReport(
              'No tienes productos parados. Si algo con existencias lleva más de '
              '2 semanas sin venderse, aparecerá aquí.');
        }
        return ListView(
          padding: _pad,
          children: [
            HeroCard(
              label: 'Dinero atrapado en producto parado',
              big: money(deadTotal(dead)),
            ),
            SectionCard(
              title: 'Sin movimiento',
              child: Column(
                children: [
                  for (final x in dead)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(x.product.name),
                      subtitle: Text(x.neverSold
                          ? 'Nunca se ha vendido · ${x.stock} piezas'
                          : 'Sin venderse hace ${x.daysIdle} días · ${x.stock} piezas'),
                      trailing: Tag(money(x.trappedCents), TagKind.err),
                    ),
                ],
              ),
            ),
            const TipsCard(title: 'Qué puedes hacer', tips: [
              'Ofrécelos en promoción junto a lo que sí se vende.',
              'Deja de producirlos o comprarlos esta semana.',
            ]),
          ],
        );
      });
}

// ───────────────────────── F-15 Horas y días fuertes ─────────────────────────

class HoursBody extends StatelessWidget {
  const HoursBody({super.key});
  @override
  Widget build(BuildContext context) => _Scope(builder: (d) {
        final h = hoursReport(d);
        if (h.isEmpty) {
          return const EmptyReport('No hay ventas en los últimos 30 días.');
        }
        final cs = Theme.of(context).colorScheme;
        final nonZero = [
          for (var i = 0; i < 24; i++)
            if (h.byHour[i] > 0) i
        ];
        final lo = nonZero.first < 6 ? nonZero.first : 6;
        final hi = nonZero.last > 20 ? nonZero.last : 20;
        final maxH = h.byHour.reduce((a, b) => a > b ? a : b);
        final maxD = h.byWeekday.reduce((a, b) => a > b ? a : b);
        bool strong(int hr) => h.strongRanges.any((r) => hr >= r.$1 && hr < r.$2);

        final tips = <String>[
          for (final r in h.strongRanges)
            'Refuerza la atención ${hourRangeText(r.$1, r.$2)}.',
          'Tu mejor día es el ${dayLong[h.bestWeekday]}.',
          'Ten listo lo que más vendes antes de esas horas.',
        ];

        return ListView(
          padding: _pad,
          children: [
            SectionCard(
              title: 'Ventas por hora',
              child: SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var hr = lo; hr <= hi; hr++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: h.byHour[hr] == 0
                                    ? 2
                                    : 110 * h.byHour[hr] / maxH,
                                decoration: BoxDecoration(
                                  color: strong(hr) ? cs.primary : cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('$hr',
                                  style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SectionCard(
              title: 'Por día de la semana',
              child: Column(
                children: [
                  for (var i = 0; i < 7; i++)
                    BarRow(
                      label: cap(dayLong[i]),
                      value: money(h.byWeekday[i]),
                      fraction: maxD == 0 ? 0 : h.byWeekday[i] / maxD,
                      highlight: i == h.bestWeekday,
                    ),
                ],
              ),
            ),
            TipsCard(title: 'Qué hacer', tips: tips),
          ],
        );
      });
}

// ───────────────────────── F-16 Se venden juntos ─────────────────────────

class PairsBody extends StatelessWidget {
  const PairsBody({super.key});
  @override
  Widget build(BuildContext context) => _Scope(builder: (d) {
        final r = pairsReport(d);
        if (r.rows.isEmpty) {
          return const EmptyReport(
              'Aún no hay productos que se vendan juntos. Aparecen cuando dos '
              'productos coinciden en al menos 2 ventas.');
        }
        return ListView(
          padding: _pad,
          children: [
            const Hint('De cada 100 ventas con el primer producto, cuántas '
                'llevan también el segundo.'),
            SectionCard(
              child: Column(
                children: [
                  for (final p in r.rows)
                    BarRow(
                      label: '${p.nameA} + ${p.nameB}',
                      value: '${p.percent}%',
                      fraction: p.percent / 100,
                    ),
                ],
              ),
            ),
            if (r.combo != null)
              SectionCard(
                title: 'Idea de combo',
                child: Text(
                  '${r.combo!.nameA} + ${r.combo!.nameB}: '
                  '${money(r.combo!.comboCents)} en lugar de '
                  '${money(r.combo!.normalCents)}. Acomódalos juntos junto a la caja.',
                ),
              ),
          ],
        );
      });
}

// ───────────────────────── F-17 Tendencias ─────────────────────────

class TrendBody extends StatelessWidget {
  const TrendBody({super.key});
  @override
  Widget build(BuildContext context) => _Scope(builder: (d) {
        final rows = trendsReport(d);
        if (rows.isEmpty) {
          return const EmptyReport(
              'Todavía no hay cambios claros frente a la semana anterior. '
              'Se muestran productos con 3 piezas o más y cambios de 8% o más.');
        }
        return ListView(
          padding: _pad,
          children: [
            const Hint('Últimos 7 días contra los 7 anteriores. Solo se '
                'muestran cambios de 8% o más.'),
            SectionCard(
              child: Column(
                children: [
                  for (final t in rows)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.name),
                      subtitle: Text('Esta semana ${t.current} · antes ${t.previous}'),
                      trailing: Tag(signed(t.percent),
                          t.percent > 0 ? TagKind.ok : TagKind.err),
                    ),
                ],
              ),
            ),
          ],
        );
      });
}

// ───────────────────────── F-18 Resumen semanal ─────────────────────────

class WeekBody extends StatelessWidget {
  const WeekBody({super.key});
  @override
  Widget build(BuildContext context) => _Scope(builder: (d) => _WeekView(d));
}

class _WeekView extends ConsumerWidget {
  const _WeekView(this.d);
  final ReportData d;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final weeks = lastWeeks(d);
    final idx = ref.watch(selectedWeekProvider).clamp(0, weeks.length - 1);
    final w = weeks[idx];
    final maxW = weeks.map((x) => x.sales).reduce((a, b) => a > b ? a : b);
    final maxDay = w.days.map((x) => x.sales).reduce((a, b) => a > b ? a : b);
    final first = weeks.first.sales;
    final last = weeks.last.sales;
    final trendPct = first > 0 ? ((last - first) / first * 100).round() : null;
    final shownDays = [
      for (final day in w.days)
        if (!day.day.isAfter(d.now)) day
    ].reversed.toList();

    return SingleChildScrollView(
      padding: _pad,
      child: RepaintBoundary(
        key: weekCaptureKey,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Semana anterior',
                    onPressed: idx == 0
                        ? null
                        : () => ref.read(selectedWeekProvider.notifier).set(idx - 1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(weekLabel(w),
                            textAlign: TextAlign.center,
                            style: tt.titleSmall),
                        Text(
                          w.isCurrent
                              ? 'Esta semana (en curso)'
                              : 'Semana ${idx + 1} de ${weeks.length}',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Semana siguiente',
                    onPressed: idx == weeks.length - 1
                        ? null
                        : () => ref.read(selectedWeekProvider.notifier).set(idx + 1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              HeroCard(
                label: 'Vendido en la semana',
                big: money(w.sales),
                bottom: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ganancia ${money(w.profit)}'),
                    Flexible(
                      child: Text(
                        w.percent == null
                            ? 'Sin semana anterior para comparar'
                            : '${signed(w.percent!)} vs. semana anterior',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'Últimas 8 semanas',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trendPct == null
                        ? 'Toca una semana para verla.'
                        : 'Tus ventas ${trendPct >= 0 ? 'subieron' : 'bajaron'} '
                            '${trendPct.abs()}% en 8 semanas. Toca una semana para verla.'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < weeks.length; i++)
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () =>
                                    ref.read(selectedWeekProvider.notifier).set(i),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(compactMoney(weeks[i].sales),
                                          style: const TextStyle(fontSize: 10),
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Container(
                                        height: weeks[i].sales == 0 || maxW == 0
                                            ? 2
                                            : 80 * weeks[i].sales / maxW,
                                        decoration: BoxDecoration(
                                          color: i == idx
                                              ? cs.primary
                                              : cs.primaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${weeks[i].start.day.toString().padLeft(2, '0')}/'
                                        '${weeks[i].start.month.toString().padLeft(2, '0')}',
                                        style: tt.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'Ventas por día',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 7; i++)
                      BarRow(
                        label: dayShort[i],
                        value: money(w.days[i].sales),
                        fraction: maxDay == 0 ? 0 : w.days[i].sales / maxDay,
                        highlight: w.hasSales && w.days[i].sales == maxDay,
                      ),
                    if (w.hasSales)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Mejor día: ${dayLong[w.bestDay.day.weekday - 1]}, '
                          'con ${money(w.bestDay.sales)}.',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
              SectionCard(
                title: 'Historial de la semana',
                child: Column(
                  children: [
                    for (final day in shownDays)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${dayShort[day.day.weekday - 1]} ${day.day.day}'),
                        subtitle: Text(
                            '${day.tickets} ${plural(day.tickets, 'venta', 'ventas')} '
                            '· ganancia ${money(day.profit)}'),
                        trailing: Text(money(day.sales), style: tt.titleSmall),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
