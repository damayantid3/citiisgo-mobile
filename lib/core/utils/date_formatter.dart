import 'package:intl/intl.dart';

class DateFormatter {
  static final _full   = DateFormat('dd MMMM yyyy', 'id_ID');
  static final _short  = DateFormat('dd MMM yyyy', 'id_ID');
  static final _input  = DateFormat('dd MMM yyyy');

  static String full(DateTime dt)  => _full.format(dt);
  static String short(DateTime dt) => _short.format(dt);
  static String input(DateTime dt) => _input.format(dt);
}