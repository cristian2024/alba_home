import 'package:equatable/equatable.dart';

/// La próxima alarma que va a sonar, tal como la ven otros plugins.
class NextAlarm extends Equatable {
  const NextAlarm({required this.alarmId, required this.ringsAt, required this.label, this.isSnoozed = false});

  final String alarmId;

  /// Cuándo suena, en UTC.
  final DateTime ringsAt;

  /// Nombre que le puso el usuario; puede estar vacío.
  final String label;

  /// Si es una alarma pospuesta que vuelve a sonar.
  final bool isSnoozed;

  @override
  List<Object?> get props => <Object?>[alarmId, ringsAt, label, isSnoozed];

  @override
  bool get stringify => true;
}
