import 'package:intl/intl.dart';

String apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String displayDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return DateFormat('d MMM yyyy', 'id_ID').format(parsed);
}
