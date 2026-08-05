import 'package:intl/intl.dart';

/// Formats quantities, prices, and dates with Latin digits always.
abstract final class AppFormat {
  static const String _numericLocale = 'en_US';

  static String quantity(num value) {
    return NumberFormat('#,##0.###', _numericLocale).format(value);
  }

  static String price(num value, {String? currency}) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: _numericLocale,
      symbol: currency ?? '',
      decimalDigits: 2,
    );
    return formatter.format(value).trim();
  }

  static String date(DateTime value) {
    return DateFormat.yMMMd(_numericLocale).format(value);
  }
}
