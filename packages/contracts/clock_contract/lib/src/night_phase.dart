import 'package:equatable/equatable.dart';

/// En qué parte del día está el horario de noche.
enum NightStage {
  /// Pantalla normal.
  day,

  /// Los minutos antes de que empiece la noche: se va fundiendo a negro y
  /// ámbar (02.4a, 02.4b).
  dusk,

  /// Negro y ámbar (02.3).
  night,

  /// Los minutos después de que termine la noche: vuelve al día.
  dawn,
}

/// La fase de noche en un instante: la etapa, cuánto de noche hay ya y,
/// mientras se acerca, cuándo empieza.
class NightPhase extends Equatable {
  const NightPhase({required this.stage, required this.darkness, this.nightStartsAt})
      : assert(darkness >= 0 && darkness <= 1, 'darkness va de 0 a 1');

  /// De día, sin nada de noche.
  static const NightPhase day = NightPhase(stage: NightStage.day, darkness: 0);

  /// Noche cerrada.
  static const NightPhase night = NightPhase(stage: NightStage.night, darkness: 1);

  final NightStage stage;

  /// De 0 (día) a 1 (noche). Sube durante [NightStage.dusk] y baja durante
  /// [NightStage.dawn].
  final double darkness;

  /// Solo durante [NightStage.dusk]: cuándo empieza la noche, en UTC
  /// (el bloque «22:30 · Modo noche»).
  final DateTime? nightStartsAt;

  /// Si las pantallas van en negro y ámbar.
  bool get isNight => stage == NightStage.night;

  @override
  List<Object?> get props => <Object?>[stage, darkness, nightStartsAt];

  @override
  bool get stringify => true;
}
