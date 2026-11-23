import 'package:alarm_domain/alarm_domain.dart';

import '../../i18n/strings.g.dart';

/// Formatos de la alarma: horas, duraciones, días y resúmenes, ya traducidos.
abstract final class AlarmFormat {
  static AlarmTranslations$alarm$es get _strings => alarmStrings.alarm;

  /// «06:30», con cero delante, como en las filas y las ruedas.
  static String padded(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// «6:30», sin cero delante, para los textos.
  static String short(int hour, int minute) => '$hour:${minute.toString().padLeft(2, '0')}';

  static String timeOf(AlarmTime time) => short(time.hour, time.minute);

  static String paddedOf(AlarmTime time) => padded(time.hour, time.minute);

  /// La hora local de [utc].
  static String localTime(DateTime utc, WallClock wallClock) {
    final DateTime local = wallClock.toLocal(utc);
    return short(local.hour, local.minute);
  }

  /// «7 h 13 min», «13 min» o «menos de 1 min». Redondea hacia arriba al
  /// minuto: a las 23:16:30, una alarma de las 6:30 suena en 7 h 14 min.
  static String remaining(Duration duration) {
    if (duration < const Duration(minutes: 1)) {
      return _strings.duration.lessThanMinute;
    }
    final int minutes = (duration.inSeconds / 60).ceil();
    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;
    return hours == 0
        ? _strings.duration.minutes(minutes: rest)
        : _strings.duration.hoursMinutes(hours: hours, minutes: rest);
  }

  static String dayShort(Weekday day) => switch (day) {
        Weekday.monday => _strings.days.short.monday,
        Weekday.tuesday => _strings.days.short.tuesday,
        Weekday.wednesday => _strings.days.short.wednesday,
        Weekday.thursday => _strings.days.short.thursday,
        Weekday.friday => _strings.days.short.friday,
        Weekday.saturday => _strings.days.short.saturday,
        Weekday.sunday => _strings.days.short.sunday,
      };

  static String dayLong(Weekday day) => switch (day) {
        Weekday.monday => _strings.days.long.monday,
        Weekday.tuesday => _strings.days.long.tuesday,
        Weekday.wednesday => _strings.days.long.wednesday,
        Weekday.thursday => _strings.days.long.thursday,
        Weekday.friday => _strings.days.long.friday,
        Weekday.saturday => _strings.days.long.saturday,
        Weekday.sunday => _strings.days.long.sunday,
      };

  static List<Weekday> _ordered(Set<Weekday> days) =>
      Weekday.values.where(days.contains).toList();

  /// Resumen corto de los días: «Lun a vie», «Sáb y dom», «Todos los días»,
  /// «Lun, Mié, Vie». Sin días, «Solo hoy» o «Solo mañana» según cuándo
  /// suene ([ringsToday]).
  static String repeatShort(Set<Weekday> days, {required bool ringsToday}) {
    if (days.isEmpty) {
      return ringsToday ? _strings.repeat.onlyToday : _strings.repeat.onlyTomorrow;
    }
    if (days.length == Weekday.everyDay.length) {
      return _strings.repeat.everyDay;
    }
    if (_sameDays(days, Weekday.weekdays)) {
      return _strings.repeat.weekdays;
    }
    if (_sameDays(days, Weekday.weekend)) {
      return _strings.repeat.weekend;
    }
    return _ordered(days).map(dayShort).join(_strings.repeat.listSeparator);
  }

  /// Resumen largo para frases: «de lunes a viernes», «todos los días»,
  /// «una sola vez», «lunes, miércoles».
  static String repeatLong(Set<Weekday> days) {
    if (days.isEmpty) {
      return _strings.repeat.longOnce;
    }
    if (days.length == Weekday.everyDay.length) {
      return _strings.repeat.longEveryDay;
    }
    if (_sameDays(days, Weekday.weekdays)) {
      return _strings.repeat.longWeekdays;
    }
    if (_sameDays(days, Weekday.weekend)) {
      return _strings.repeat.longWeekend;
    }
    return _ordered(days).map(dayLong).join(_strings.repeat.listSeparator);
  }

  static bool _sameDays(Set<Weekday> a, Set<Weekday> b) => a.length == b.length && a.containsAll(b);

  /// Si [nextUtc] cae hoy en la hora local de [nowUtc].
  static bool isToday(DateTime nextUtc, DateTime nowUtc, WallClock wallClock) {
    final DateTime next = wallClock.toLocal(nextUtc);
    final DateTime now = wallClock.toLocal(nowUtc);
    return next.year == now.year && next.month == now.month && next.day == now.day;
  }

  /// Nombre visible de una alarma: el suyo o «Alarma».
  static String label(Alarm alarm) => alarm.label.isEmpty ? _strings.defaultLabel : alarm.label;

  /// Nombre de un sonido del catálogo.
  static String soundName(String soundId) => switch (soundId) {
        'bell' => _strings.sounds.bell,
        'pulse' => _strings.sounds.pulse,
        _ => _strings.sounds.sunrise,
      };
}
