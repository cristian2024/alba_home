import 'package:equatable/equatable.dart';

import 'alarm_time.dart';
import 'weekday.dart';

/// Una alarma: hora local, días de repetición y cómo suena.
///
/// Sin días de repetición suena una sola vez («Solo hoy») y, al apagarla,
/// queda desactivada.
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

  bool get isRepeating => repeat.isNotEmpty;

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
      );

  @override
  List<Object?> get props => <Object?>[id, time, label, repeat, enabled, soundId, rise, snooze, maxSnoozes, vibrate];

  @override
  bool get stringify => true;
}
