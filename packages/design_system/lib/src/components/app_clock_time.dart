import 'package:flutter/widgets.dart';

import '../theme/app_tone.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';

/// Tamaño de la hora (`Clock/Time/*`).
enum AppClockSize {
  /// 205: el reloj, de día y de noche.
  hero,

  /// 160: un temporizador solo.
  large,

  /// 96: ruedas y tarjetas grandes.
  medium,

  /// 56: tarjetas de temporizador y filas de alarma.
  small,
}

/// La hora o una cuenta atrás («07:41», «8:24») en cifras tabulares, centrada
/// como bloque para que no baile al cambiar.
///
/// Penpot pone cada dígito en una caja fija; aquí basta con las cifras
/// tabulares de [AppTypography]. Con [dimmed] va en color terciario (alarma
/// desactivada, temporizador en pausa o detenido). [semanticLabel] da la
/// lectura natural («siete y cuarenta y uno»); sin él se lee [text].
class AppClockTime extends StatelessWidget {
  const AppClockTime(
    this.text, {
    super.key,
    this.size = AppClockSize.hero,
    this.tone = AppTone.surface,
    this.color,
    this.dimmed = false,
    this.semanticLabel,
  });

  final String text;
  final AppClockSize size;
  final AppTone tone;

  /// Color fijo que sustituye al del tono (p. ej. ámbar en un temporizador
  /// terminado).
  final Color? color;
  final bool dimmed;
  final String? semanticLabel;

  static TextStyle styleFor(AppClockSize size) => switch (size) {
        AppClockSize.hero => AppTypography.clockHero,
        AppClockSize.large => AppTypography.clockLarge,
        AppClockSize.medium => AppTypography.clockMedium,
        AppClockSize.small => AppTypography.clockSmall,
      };

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final Color resolved = color ??
        switch (tone) {
          AppTone.surface => dimmed ? theme.textTertiary : theme.textPrimary,
          AppTone.photo => theme.textOnPhoto,
          AppTone.night => dimmed ? AppNightColors.textSecondary : AppNightColors.textPrimary,
        };
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        softWrap: false,
        style: styleFor(size).copyWith(color: resolved),
      ),
    );
  }
}
