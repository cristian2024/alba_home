import 'package:equatable/equatable.dart';

import 'alarm.dart';

/// Una alarma que ha sonado y aún no se ha apagado: suena ahora o está
/// pospuesta. Se guarda para sobrevivir a que la app se cierre o el teléfono
/// se reinicie entre dos posposiciones.
class AlarmSession extends Equatable {
  const AlarmSession({required this.alarmId, required this.startedAt, this.snoozesUsed = 0, this.snoozedUntil});

  final String alarmId;

  /// Cuándo sonó por primera vez, en UTC.
  final DateTime startedAt;

  /// Veces que se ha pospuesto («pospuesta 1 de 3 veces»).
  final int snoozesUsed;

  /// Hasta cuándo está pospuesta, en UTC; `null` mientras suena.
  final DateTime? snoozedUntil;

  bool get isSnoozed => snoozedUntil != null;

  /// Si [alarm] admite otra posposición («quedan 2»).
  bool canSnooze(Alarm alarm) => snoozesUsed < alarm.maxSnoozes;

  /// Posposiciones que le quedan a [alarm].
  int snoozesLeft(Alarm alarm) => (alarm.maxSnoozes - snoozesUsed).clamp(0, alarm.maxSnoozes);

  /// Pospone [alarm] desde [nowUtc]. Lanza [StateError] si ya no quedan.
  AlarmSession snooze(Alarm alarm, DateTime nowUtc) {
    if (!canSnooze(alarm)) {
      throw StateError('La alarma ${alarm.id} ya se pospuso ${alarm.maxSnoozes} veces');
    }
    return AlarmSession(
      alarmId: alarmId,
      startedAt: startedAt,
      snoozesUsed: snoozesUsed + 1,
      snoozedUntil: nowUtc.add(alarm.snooze),
    );
  }

  /// Vuelve a sonar al acabar la posposición.
  AlarmSession ringAgain() => AlarmSession(alarmId: alarmId, startedAt: startedAt, snoozesUsed: snoozesUsed);

  @override
  List<Object?> get props => <Object?>[alarmId, startedAt, snoozesUsed, snoozedUntil];

  @override
  bool get stringify => true;
}

/// Cómo queda una alarma al apagarla: sin repetición se desactiva; con
/// repetición sigue igual y vuelve a sonar el próximo día.
Alarm afterDismiss(Alarm alarm) => alarm.isRepeating ? alarm : alarm.copyWith(enabled: false);
