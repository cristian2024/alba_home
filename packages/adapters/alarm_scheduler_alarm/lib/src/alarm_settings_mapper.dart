import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';

/// Conversión entre [ScheduledAlarm] y los [AlarmSettings] del paquete
/// `alarm`. El id de texto viaja en el `payload` junto con lo que `alarm` no
/// guarda; el id entero es un hash estable del de texto.
abstract final class AlarmSettingsMapper {
  /// Id entero de `alarm` para [id]: FNV-1a de 31 bits, igual en cada
  /// ejecución (a diferencia de `String.hashCode`).
  static int intId(String id) {
    int hash = 0x811c9dc5;
    for (final int unit in utf8.encode(id)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    // Positivo y distinto de 0.
    return (hash & 0x7FFFFFFF) | 1;
  }

  /// [audioPath] es el archivo que suena (de `AlarmSoundFiles`); con `null`,
  /// el tono de alarma del sistema. El asset original va en el payload.
  static AlarmSettings toSettings(ScheduledAlarm alarm, {required String? audioPath}) => AlarmSettings(
        id: intId(alarm.id),
        dateTime: alarm.at.toLocal(),
        assetAudioPath: audioPath,
        loopAudio: alarm.loop,
        vibrate: alarm.vibrate,
        // En Android avisa de que la app se cerró; Alba es el launcher y se
        // reabre sola.
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        // Dos temporizadores pueden terminar a la vez y a la misma hora.
        allowAlarmOverlap: true,
        allowSameSecondScheduling: true,
        volumeSettings: alarm.fadeIn > Duration.zero
            ? VolumeSettings.fade(fadeDuration: alarm.fadeIn, volume: alarm.volume, volumeEnforced: true)
            : VolumeSettings.fixed(volume: alarm.volume, volumeEnforced: true),
        notificationSettings: NotificationSettings(title: alarm.title, body: alarm.body ?? ''),
        payload: jsonEncode(<String, Object?>{
          'id': alarm.id,
          'at': alarm.at.toUtc().toIso8601String(),
          'title': alarm.title,
          'body': alarm.body,
          'sound': alarm.soundAsset,
        }),
      );

  /// `null` si los [settings] no los programó este adaptador (sin payload).
  static ScheduledAlarm? fromSettings(AlarmSettings settings) {
    final String? payload = settings.payload;
    if (payload == null) {
      return null;
    }
    final Object? decoded = jsonDecode(payload);
    if (decoded is! Map<String, Object?> || decoded['id'] is! String) {
      return null;
    }
    final VolumeSettings volume = settings.volumeSettings;
    return ScheduledAlarm(
      id: decoded['id']! as String,
      at: DateTime.parse(decoded['at']! as String).toUtc(),
      title: decoded['title']! as String,
      body: decoded['body'] as String?,
      soundAsset: decoded['sound'] as String? ?? '',
      volume: volume.volume ?? 1,
      fadeIn: volume.fadeDuration ?? Duration.zero,
      vibrate: settings.vibrate,
      loop: settings.loopAudio,
    );
  }
}
