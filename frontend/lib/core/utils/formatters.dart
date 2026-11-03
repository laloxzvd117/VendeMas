import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final _currencyFormatDecimals = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String money(num amount) => _currencyFormat.format(amount);

  static String currency(num amount) => money(amount);

  static String moneyDecimals(num amount) =>
      _currencyFormatDecimals.format(amount);

  static String percent(num value) => '${value.round()}%';

  static String signedPercent(num value) {
    final abs = value.abs().round();
    if (value > 0) return '+$abs%';
    if (value < 0) return '−$abs%';
    return '0%';
  }

  static String dateHeader(DateTime date) {
    final f = DateFormat("EEEE d 'de' MMMM", 'es_MX');
    final s = f.format(date);
    return s[0].toUpperCase() + s.substring(1);
  }
}
