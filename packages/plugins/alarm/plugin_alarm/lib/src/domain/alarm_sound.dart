import 'package:equatable/equatable.dart';

/// Un sonido de alarma del catálogo del plugin. Su nombre visible sale de las
/// traducciones por [id].
class AlarmSound extends Equatable {
  const AlarmSound({required this.id, required this.asset});

  final String id;

  /// Asset tal como lo resuelve Flutter desde la app
  /// (`packages/plugin_alarm/assets/sounds/<id>.wav`).
  final String asset;

  @override
  List<Object?> get props => <Object?>[id, asset];
}

/// Sonidos que trae el plugin, en el orden en que se ofrecen.
abstract final class AlarmSounds {
  static const String _base = 'packages/plugin_alarm/assets/sounds';

  /// «Amanecer suave»: el de por defecto.
  static const AlarmSound sunrise = AlarmSound(id: 'sunrise', asset: '$_base/sunrise.wav');

  /// «Campana».
  static const AlarmSound bell = AlarmSound(id: 'bell', asset: '$_base/bell.wav');

  /// «Pulso»: más insistente.
  static const AlarmSound pulse = AlarmSound(id: 'pulse', asset: '$_base/pulse.wav');

  static const List<AlarmSound> all = <AlarmSound>[sunrise, bell, pulse];

  /// El sonido [id]; el de por defecto si ya no existe.
  static AlarmSound byId(String id) =>
      all.firstWhere((AlarmSound sound) => sound.id == id, orElse: () => sunrise);
}
