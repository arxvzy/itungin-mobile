import 'package:intl/intl.dart';

final _rupiahFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

String formatRupiah(num value) => _rupiahFormatter.format(value);
