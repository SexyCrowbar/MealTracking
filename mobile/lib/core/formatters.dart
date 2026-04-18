import 'package:intl/intl.dart';

String formatKcal(num v) => '${v.round()}';

String formatGrams(num v) {
  if (v is int) return '${v}g';
  if (v == v.roundToDouble()) return '${v.round()}g';
  return '${v.toStringAsFixed(1)}g';
}

String formatDateLong(DateTime d, {String locale = 'en'}) =>
    DateFormat.yMMMMEEEEd(locale).format(d);

String formatDateShort(DateTime d, {String locale = 'en'}) =>
    DateFormat.yMMMd(locale).format(d);

String formatTime(DateTime d, {String locale = 'en'}) =>
    DateFormat.Hm(locale).format(d);

String maskApiKey(String key) {
  if (key.isEmpty) return '';
  if (key.length <= 4) return '•' * key.length;
  return '•••••${key.substring(key.length - 4)}';
}
