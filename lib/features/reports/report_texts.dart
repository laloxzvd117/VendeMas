import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../domain/reports.dart';

const dayShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const dayLong = [
  'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
];

String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String plural(int n, String one, String many) => n == 1 ? one : many;

String signed(int pct) => pct > 0 ? '+$pct%' : '$pct%';

/// Dinero corto para barras: $850, $1.2k.
String compactMoney(int cents) {
  final pesos = cents / 100;
  if (pesos >= 1000) return '\$${(pesos / 1000).toStringAsFixed(1)}k';
  return money(cents);
}

String percentText(double v) => v < 1 ? '<1%' : '${v.round()}%';

String weekLabel(WeekSummary w) {
  final a = w.start;
  final b = w.end;
  String month(DateTime d) => DateFormat('MMMM', 'es_MX').format(d);
  return a.month == b.month
      ? 'Semana del ${a.day} al ${b.day} de ${month(b)}'
      : 'Semana del ${a.day} de ${month(a)} al ${b.day} de ${month(b)}';
}

String _period(int h) =>
    h < 12 ? 'de la mañana' : (h < 19 ? 'de la tarde' : 'de la noche');

String hourRangeText(int start, int end) =>
    'de $start a $end ${_period(start)}';

/// Titular de cada reporte en el menú (F-10).
class ReportHeadline {
  const ReportHeadline(this.big, this.text);
  final String big;
  final String text;
}

const noSalesHeadline =
    ReportHeadline('—', 'Se llena cuando registres tus primeras ventas.');

/// Recomendaciones cortas para "Para hoy" en el inicio.
List<String> recommendations(ReportData d) {
  final out = <String>[];
  if (!d.hasSales) return out;

  final dead = deadProducts(d);
  if (dead.isNotEmpty) {
    out.add('Tienes ${money(deadTotal(dead))} parados en ${dead.length} '
        '${plural(dead.length, 'producto', 'productos')} sin venderse. '
        'Ofrécelos en promoción o deja de comprarlos.');
  }
  final stats = productStats(d);
  final abc = abcAnalysis(stats);
  if (!abc.isEmpty) {
    out.add('${abc.countA} de ${abc.total} '
        '${plural(abc.total, 'producto genera', 'productos generan')} el '
        '${abc.shareA.round()}% de tu ganancia. Que nunca te falten.');
  }
  final q = quadrants(stats);
  if (q.busy.isNotEmpty) {
    out.add('${q.busy.first.name} se vende mucho pero deja poco. '
        'Revisa su precio o su costo.');
  }
  return out.take(2).toList();
}
