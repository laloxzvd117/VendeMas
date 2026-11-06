import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../domain/reports.dart';
import 'report_bodies.dart';
import 'report_texts.dart';

/// Los 8 reportes: los usa el menú del celular (F-10) y la barra lateral de
/// la computadora (F-23).
class ReportDef {
  const ReportDef({
    required this.key,
    required this.title,
    required this.icon,
    required this.body,
    required this.headline,
  });
  final String key;
  final String title;
  final IconData icon;
  final Widget Function() body;
  final ReportHeadline Function(ReportData d) headline;
}

ReportHeadline _rank(ReportData d) {
  final s = productStats(d);
  if (s.isEmpty) return noSalesHeadline;
  final u = rankByUnits(s).first;
  final p = rankByProfit(s).first;
  return ReportHeadline(
      money(p.profit), 'Más piezas: ${u.name}. Más ganancia: ${p.name}.');
}

ReportHeadline _abc(ReportData d) {
  final a = abcAnalysis(productStats(d));
  if (a.isEmpty) return noSalesHeadline;
  return ReportHeadline('${a.shareA.round()}%',
      '${a.countA} de ${a.total} ${plural(a.total, 'producto genera', 'productos generan')} el ${a.shareA.round()}% de la ganancia.');
}

ReportHeadline _matrix(ReportData d) {
  final q = quadrants(productStats(d));
  if (q.isEmpty) return noSalesHeadline;
  return ReportHeadline('${q.busy.length}',
      '${q.busy.length} ${plural(q.busy.length, 'producto vende', 'productos venden')} mucho y deja${q.busy.length == 1 ? '' : 'n'} poco por pieza.');
}

ReportHeadline _dead(ReportData d) {
  final x = deadProducts(d);
  if (x.isEmpty) {
    return const ReportHeadline('\$0', 'No tienes productos parados.');
  }
  return ReportHeadline(money(deadTotal(x)),
      '${x.length} ${plural(x.length, 'producto sin venderse', 'productos sin venderse')} hace más de 2 semanas.');
}

ReportHeadline _hours(ReportData d) {
  final h = hoursReport(d);
  if (h.isEmpty) return noSalesHeadline;
  return ReportHeadline('${h.peakHour} h',
      'Tu hora más fuerte es ${hourRangeText(h.peakHour, h.peakHour + 1)}.');
}

ReportHeadline _pairs(ReportData d) {
  final r = pairsReport(d);
  if (r.rows.isEmpty) {
    return const ReportHeadline('—', 'Aún no hay productos que se vendan juntos.');
  }
  final t = r.rows.first;
  return ReportHeadline('${t.percent}%',
      'Quien lleva ${t.nameA}, ${t.percent}% de las veces lleva ${t.nameB}.');
}

ReportHeadline _trend(ReportData d) {
  final t = trendsReport(d);
  if (t.isEmpty) {
    return const ReportHeadline('—', 'Sin cambios claros frente a la semana anterior.');
  }
  return ReportHeadline(
      signed(t.first.percent), '${t.first.name} es lo que más cambia esta semana.');
}

ReportHeadline _week(ReportData d) {
  final w = lastWeeks(d).last;
  return ReportHeadline(money(w.sales),
      'Historial de ventas semana por semana y lo más importante.');
}

final reportDefs = <ReportDef>[
  ReportDef(
      key: 'week',
      title: 'Resumen semanal',
      icon: Icons.calendar_view_week,
      body: WeekBody.new,
      headline: _week),
  ReportDef(
      key: 'rank',
      title: 'Más vendidos y rentables',
      icon: Icons.emoji_events,
      body: RankBody.new,
      headline: _rank),
  ReportDef(
      key: 'abc',
      title: 'Clasificación ABC',
      icon: Icons.pie_chart,
      body: AbcBody.new,
      headline: _abc),
  ReportDef(
      key: 'matrix',
      title: 'Margen y rotación',
      icon: Icons.grid_view,
      body: MatrixBody.new,
      headline: _matrix),
  ReportDef(
      key: 'dead',
      title: 'Productos muertos',
      icon: Icons.remove_shopping_cart,
      body: DeadBody.new,
      headline: _dead),
  ReportDef(
      key: 'hours',
      title: 'Horas y días fuertes',
      icon: Icons.schedule,
      body: HoursBody.new,
      headline: _hours),
  ReportDef(
      key: 'pairs',
      title: 'Se venden juntos',
      icon: Icons.join_inner,
      body: PairsBody.new,
      headline: _pairs),
  ReportDef(
      key: 'trend',
      title: 'Tendencias',
      icon: Icons.trending_up,
      body: TrendBody.new,
      headline: _trend),
];

ReportDef? reportByKey(String key) {
  for (final r in reportDefs) {
    if (r.key == key) return r;
  }
  return null;
}
