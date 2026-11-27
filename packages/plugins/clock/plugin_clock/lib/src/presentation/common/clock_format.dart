import 'package:clock_domain/clock_domain.dart';

import '../../i18n/strings.g.dart';

/// Textos del reloj a partir de fechas y horas.
abstract final class ClockFormat {
  /// La hora del reloj, con dos cifras: «07:41».
  static String clock(DateTime local) => '${_two(local.hour)}:${_two(local.minute)}';

  /// Una hora de bloque, sin cero delante: «6:30», «22:30».
  static String short(DateTime local) => '${local.hour}:${_two(local.minute)}';

  /// «miércoles, 18 de noviembre».
  static String date(DateTime local) {
    final ClockTranslations$clock$es strings = clockStrings.clock;
    return strings.date(
      weekday: strings.weekdays[local.weekday - 1],
      day: local.day,
      month: strings.months[local.month - 1],
    );
  }

  /// Dos cifras de una hora de rueda: «06».
  static String two(int value) => _two(value);

  /// Una [LocalTime] como «22:30».
  static String localTime(LocalTime time) => '${time.hour}:${_two(time.minute)}';

  static String _two(int value) => value.toString().padLeft(2, '0');
}
