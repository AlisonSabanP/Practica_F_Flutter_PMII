import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final NumberFormat _money = NumberFormat('#,##0.00');
  static final NumberFormat _integer = NumberFormat('#,##0');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _fileStamp = DateFormat('yyyyMMdd_HHmmss');

  static String money(double value) => 'Q ${_money.format(value)}';

  static String integer(int value) => _integer.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String date(DateTime value) => _date.format(value);

  static String fileStamp(DateTime value) => _fileStamp.format(value);

  static String percent(double value) => '${(value * 100).toStringAsFixed(1)} %';
}
