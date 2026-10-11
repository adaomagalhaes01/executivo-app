import 'package:intl/intl.dart';

/// Shared formatters for the Rent a Car module.
///
/// Kept in `core/utils` so screens, widgets and models all render prices and
/// dates exactly the same way. The currency is the Angolan Kwanza, formatted
/// without decimals and with a dot as the thousands separator (25.000 Kz).
abstract final class RentFormatters {
  static const String currency = 'Kz';
  static const List<String> _months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  /// `25.000 Kz`
  static String kwanza(num amount) {
    final formatter = NumberFormat.decimalPattern('pt_PT');
    return '${formatter.format(amount.round())} $currency';
  }

  /// `25.000` — used where the currency is already stated nearby.
  static String amount(num value) => NumberFormat.decimalPattern('pt_PT')
      .format(value.round());

  /// `25.000 Kz / dia`
  static String perDay(num value) => '${kwanza(value)} / dia';

  /// `25 mil` / `1,2 M` — compact enough for slider labels and badges.
  static String kwanzaCompact(num value) {
    if (value.abs() >= 1000000) {
      final millions = value / 1000000;
      final digits = millions == millions.roundToDouble() ? 0 : 1;
      return '${millions.toStringAsFixed(digits).replaceAll('.', ',')} M $currency';
    }
    if (value.abs() >= 1000) {
      return '${amount(value / 1000).replaceAll(RegExp(r'[,.]0+$'), '')} mil';
    }
    return amount(value);
  }

  /// `12 Out 2026`
  static String shortDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// `12 Out, 14:30`
  static String shortDateTime(DateTime date) =>
      '${shortDate(date)}, ${twoDigits(date.hour)}:${twoDigits(date.minute)}';

  /// `12 Out 2026 – 15 Out 2026`
  static String dateRange(DateTime start, DateTime end) =>
      '${shortDate(start)} – ${shortDate(end)}';

  /// `12 – 15 Out 2026`
  static String compactDateRange(DateTime start, DateTime end) {
    if (start.month == end.month && start.year == end.year) {
      return '${start.day} – ${end.day} ${_months[end.month - 1]} ${end.year}';
    }
    return dateRange(start, end);
  }

  /// `12 de Out de 2026`
  static String longDate(DateTime date) =>
      DateFormat("d 'de' MMMM 'de' yyyy", 'pt').format(date);

  /// `Manhã` / `Tarde` / `Noite`
  static String dayPeriod(int hour) {
    if (hour < 12) return 'Manhã';
    if (hour < 18) return 'Tarde';
    return 'Noite';
  }

  /// `há 2 dias` — relative age for rental history rows.
  static String relativeFrom(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'agora mesmo';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'há $h ${h == 1 ? 'hora' : 'horas'}';
    }
    final d = diff.inDays;
    if (d < 30) return 'há $d ${d == 1 ? 'dia' : 'dias'}';
    final m = d ~/ 30;
    return 'há $m ${m == 1 ? 'mês' : 'meses'}';
  }

  static String twoDigits(int value) => value.toString().padLeft(2, '0');

  /// `12 Out` — compact label for the gallery and chips.
  static String dayMonth(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}';
}