import 'package:core_events/core_events.dart';

/// Empezó a sonar una alarma (también al volver de una posposición).
class AlarmRang extends CrossPluginEvent {
  AlarmRang({required this.alarmId, required this.label, required DateTime rangAt}) : super(emittedAt: rangAt);

  final String alarmId;
  final String label;

  DateTime get rangAt => emittedAt;
}

/// Se pospuso una alarma que sonaba.
class AlarmSnoozed extends CrossPluginEvent {
  AlarmSnoozed({required this.alarmId, required this.until, required DateTime snoozedAt})
      : super(emittedAt: snoozedAt);

  final String alarmId;

  /// Cuándo vuelve a sonar, en UTC.
  final DateTime until;
}

/// Se apagó una alarma que sonaba o estaba pospuesta.
class AlarmDismissed extends CrossPluginEvent {
  AlarmDismissed({required this.alarmId, required DateTime dismissedAt}) : super(emittedAt: dismissedAt);

  final String alarmId;
}
