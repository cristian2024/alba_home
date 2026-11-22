import 'package:flutter/widgets.dart';

import 'app_tone.dart';

/// Indica a las pantallas de debajo sobre qué fondo van: la app lo pone en
/// [AppTone.night] durante el horario de noche, y las pantallas que tienen
/// variante de noche (alarma sonando, avisos) la eligen sin saber del horario.
class AppToneScope extends InheritedWidget {
  const AppToneScope({super.key, required this.tone, required super.child});

  final AppTone tone;

  /// El tono más cercano; [AppTone.surface] si no hay ninguno.
  static AppTone of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppToneScope>()?.tone ?? AppTone.surface;

  @override
  bool updateShouldNotify(AppToneScope oldWidget) => oldWidget.tone != tone;
}
