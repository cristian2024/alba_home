import 'package:equatable/equatable.dart';

import 'alarm_time.dart';
import 'weekday.dart';

/// Una alarma: hora local, días de repetición y cómo suena.
///
/// Sin días de repetición suena una sola vez («Solo hoy») y, al apagarla,
/// queda desactivada. Para saber si ya sonó con la app cerrada, guarda el
/// instante para el que se programó ([onceAt]).
class Alarm extends Equatable {
  const Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.soundId,
    this.repeat = const <Weekday>{},
    this.enabled = true,
    this.rise = const Duration(minutes: 1),
    this.snooze = const Duration(minutes: 10),
    this.maxSnoozes = 3,
    this.vibrate = true,
    this.onceAt,
  });

  /// UUID v4.
  final String id;
  final AlarmTime time;

  /// Nombre que pone el usuario («Trabajo»); puede estar vacío.
  final String label;

  /// Días en que se repite. Vacío: una sola vez.
  final Set<Weekday> repeat;
  final bool enabled;

  /// Identificador del sonido del catálogo del plugin («sunrise»).
  final String soundId;

  /// Lo que tarda el volumen en llegar al máximo («sube en 1 min»).
  final Duration rise;

  /// Cuánto se pospone cada vez («10 min»).
  final Duration snooze;

  /// Cuántas veces se puede posponer seguidas («hasta 3 veces»).
  final int maxSnoozes;
  final bool vibrate;

  /// Solo sin repetición: el instante (UTC) para el que se programó. Si ya
  /// pasó, la alarma sonó (o se perdió con el teléfono apagado). `null` hasta
  /// que se programa; cambiar la hora, los días o activarla lo borra.
  final DateTime? onceAt;

  bool get isRepeating => repeat.isNotEmpty;

  /// La misma alarma programada para sonar una vez en [at].
  Alarm armedFor(DateTime at) => _copy(onceAt: at.toUtc());

  /// Cambiar [time], [repeat] o [enabled] borra [onceAt]: la próxima vez que
  /// suena hay que calcularla de nuevo.
  Alarm copyWith({
    AlarmTime? time,
    String? label,
    Set<Weekday>? repeat,
    bool? enabled,
    String? soundId,
    Duration? rise,
    Duration? snooze,
    int? maxSnoozes,
    bool? vibrate,
  }) =>
      _copy(
        time: time,
        label: label,
        repeat: repeat,
        enabled: enabled,
        soundId: soundId,
        rise: rise,
        snooze: snooze,
        maxSnoozes: maxSnoozes,
        vibrate: vibrate,
        onceAt: (time != null && time != this.time) ||
                (repeat != null && !_sameDays(repeat, this.repeat)) ||
                (enabled != null && enabled != this.enabled)
            ? null
            : onceAt,
      );

  Alarm _copy({
    AlarmTime? time,
    String? label,
    Set<Weekday>? repeat,
    bool? enabled,
    String? soundId,
    Duration? rise,
    Duration? snooze,
    int? maxSnoozes,
    bool? vibrate,
    DateTime? onceAt,
  }) =>
      Alarm(
        id: id,
        time: time ?? this.time,
        label: label ?? this.label,
        repeat: repeat ?? this.repeat,
        enabled: enabled ?? this.enabled,
        soundId: soundId ?? this.soundId,
        rise: rise ?? this.rise,
        snooze: snooze ?? this.snooze,
        maxSnoozes: maxSnoozes ?? this.maxSnoozes,
        vibrate: vibrate ?? this.vibrate,
        onceAt: onceAt,
      );

  static bool _sameDays(Set<Weekday> a, Set<Weekday> b) => a.length == b.length && a.containsAll(b);

  @override
  List<Object?> get props => <Object?>[id, time, label, repeat, enabled, soundId, rise, snooze, maxSnoozes, vibrate, onceAt];

  @override
  bool get stringify => true;
}
