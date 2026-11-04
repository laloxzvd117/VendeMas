import 'package:intl/intl.dart';

final _money0 = NumberFormat.currency(locale: 'es_MX', symbol: r'$', decimalDigits: 0);
final _money2 = NumberFormat.currency(locale: 'es_MX', symbol: r'$', decimalDigits: 2);

/// Dinero sin decimales cuando son exactos: $55, $12.50.
String money(int cents) =>
    cents % 100 == 0 ? _money0.format(cents / 100) : _money2.format(cents / 100);

/// Siempre con dos decimales (cambio, faltante).
String money2(int cents) => _money2.format(cents / 100);

String longDate(DateTime d) {
  final s = DateFormat("EEEE d 'de' MMMM", 'es_MX').format(d);
  return s[0].toUpperCase() + s.substring(1);
}

String hm(DateTime d) => DateFormat('HH:mm', 'es_MX').format(d);
