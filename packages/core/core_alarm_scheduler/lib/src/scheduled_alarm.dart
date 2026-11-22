import 'package:equatable/equatable.dart';

/// Alarma programada para sonar en un instante exacto, aunque la app esté
/// cerrada o el teléfono se haya reiniciado.
///
/// Es un disparo único: repetir cada día o posponer lo decide quien la
/// programa, que programa la siguiente.
class ScheduledAlarm extends Equatable {
  const ScheduledAlarm({
    required this.id,
    required this.at,
    required this.title,
    required this.soundAsset,
    this.body,
    this.volume = 1,
    this.fadeIn = Duration.zero,
    this.vibrate = true,
    this.loop = true,
  });

  /// Identificador estable de quien la programa (p. ej. el UUID de la alarma o
  /// del temporizador). Programar otra con el mismo id la sustituye.
  final String id;

  /// Cuándo suena, en UTC.
  final DateTime at;

  /// Texto principal de la notificación del sistema (ya traducido).
  final String title;

  /// Texto secundario de la notificación (ya traducido).
  final String? body;

  /// Asset del sonido, tal como lo declara el `pubspec.yaml` que lo aporta.
  final String soundAsset;

  /// Volumen final, entre 0 y 1.
  final double volume;

  /// Tiempo que tarda en subir de 0 a [volume] («sube en 1 min»).
  final Duration fadeIn;

  final bool vibrate;

  /// Si el sonido se repite hasta que alguien la detiene.
  final bool loop;

  ScheduledAlarm copyWith({DateTime? at}) => ScheduledAlarm(
        id: id,
        at: at ?? this.at,
        title: title,
        body: body,
        soundAsset: soundAsset,
        volume: volume,
        fadeIn: fadeIn,
        vibrate: vibrate,
        loop: loop,
      );

  @override
  List<Object?> get props => <Object?>[id, at, title, body, soundAsset, volume, fadeIn, vibrate, loop];

  @override
  bool get stringify => true;
}
