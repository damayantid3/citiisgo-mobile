import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );

  static String format(int amount) => _formatter.format(amount);

  static String formatShort(int amount) {
    if (amount >= 1000000) return 'Rp ${(amount / 1000000).toStringAsFixed(0)}jt';
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    return 'Rp $amount';
  }
}