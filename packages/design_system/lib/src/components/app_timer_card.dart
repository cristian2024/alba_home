import 'package:flutter/widgets.dart';

import '../tokens/app_icons.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';
import 'app_clock_time.dart';
import 'app_icon_button.dart';

/// Estado de un temporizador de cocina.
enum AppTimerStatus { running, paused, finished, stopped }

/// Textos para el lector de los botones de una tarjeta de temporizador, con el
/// nombre del temporizador («Pausar Pasta», «Detener Pasta»).
class AppTimerCardLabels {
  const AppTimerCardLabels({
    required this.addMinute,
    required this.addMinuteSemantic,
    required this.pauseSemantic,
    required this.resumeSemantic,
    required this.dismissSemantic,
    required this.stopSemantic,
    required this.undo,
    required this.undoSemantic,
  });

  /// Etiqueta visible del botón de añadir («1 min»).
  final String addMinute;
  final String addMinuteSemantic;
  final String pauseSemantic;
  final String resumeSemantic;

  /// Dar por visto un temporizador terminado («Listo, Arroz»).
  final String dismissSemantic;
  final String stopSemantic;

  /// Etiqueta visible de deshacer una detención («Deshacer»).
  final String undo;
  final String undoSemantic;
}

/// Tarjeta de temporizador (`Timer/Card/*`), de 264 × 268 y radio 24: nombre,
/// estado, cuenta atrás de 56, pista de progreso de 8 y botones de 72.
///
/// - En marcha: pausa, +1 min y × de detener de 48 (pequeña a propósito, para
///   no parar sin querer).
/// - En pausa: cifra y progreso atenuados, play.
/// - Terminado: lavado y borde ámbar, cifra ámbar y ✓ para darlo por visto.
/// - Detenido: hundida, con «Deshacer» y la cuenta de [undoCountdown].
class AppTimerCard extends StatelessWidget {
  const AppTimerCard({
    super.key,
    required this.name,
    required this.statusLabel,
    required this.remaining,
    required this.progress,
    required this.status,
    required this.labels,
    this.remainingSemantic,
    this.onAddMinute,
    this.onToggle,
    this.onStop,
    this.onUndo,
    this.undoCountdown,
  });

  final String name;

  /// «Quedan 8 min», «En pausa», «Listo», «Detenido».
  final String statusLabel;

  /// Cuenta atrás ya formateada («08:24»).
  final String remaining;

  /// Lectura natural de [remaining] («8 minutos y 24 segundos»).
  final String? remainingSemantic;

  /// Parte transcurrida, de 0 a 1.
  final double progress;
  final AppTimerStatus status;
  final AppTimerCardLabels labels;
  final VoidCallback? onAddMinute;

  /// Pausar, reanudar o, terminado, darlo por visto.
  final VoidCallback? onToggle;
  final VoidCallback? onStop;
  final VoidCallback? onUndo;

  /// Segundos que quedan para deshacer, ya formateados («5 s»).
  final String? undoCountdown;

  static const double width = 264;
  static const double height = 268;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final bool finished = status == AppTimerStatus.finished;
    final bool stopped = status == AppTimerStatus.stopped;
    final bool dimmed = status == AppTimerStatus.paused || stopped;
    final String? countdown = undoCountdown;
    return Semantics(
      container: true,
      label: name,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: finished ? theme.bgBrandSubtle : (stopped ? theme.bgSurfaceSunken : theme.bgSurfaceRaised),
          borderRadius: BorderRadius.circular(AppRadii.extraLarge),
          border: Border.all(color: finished ? theme.borderBrand : theme.borderDefault, width: AppSizes.strokeThin),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              // 20 de Penpot menos el píxel del borde, que ya ocupa sitio.
              padding: const EdgeInsets.fromLTRB(19, 17, 19, 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.heading.copyWith(color: theme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusLabel,
                    maxLines: 1,
                    style: AppTypography.labelLarge.copyWith(color: finished ? theme.textBrand : theme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 160,
                    child: AppClockTime(
                      remaining,
                      size: AppClockSize.small,
                      dimmed: dimmed,
                      color: finished ? theme.textBrand : null,
                      semanticLabel: remainingSemantic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!stopped) _ProgressTrack(progress: progress, active: !dimmed),
                  const Spacer(),
                  if (stopped)
                    AppButton(
                      label: labels.undo,
                      icon: AppIcons.repeat,
                      variant: AppButtonVariant.secondary,
                      semanticLabel: labels.undoSemantic,
                      onPressed: onUndo,
                    )
                  else
                    Row(
                      spacing: 1,
                      children: <Widget>[
                        Expanded(
                          child: AppButton(
                            label: labels.addMinute,
                            icon: AppIcons.plus,
                            variant: AppButtonVariant.secondary,
                            semanticLabel: labels.addMinuteSemantic,
                            onPressed: onAddMinute,
                            expand: true,
                          ),
                        ),
                        AppIconButton(
                          icon: switch (status) {
                            AppTimerStatus.running => AppIcons.pause,
                            AppTimerStatus.paused => AppIcons.play,
                            _ => AppIcons.check,
                          },
                          semanticLabel: switch (status) {
                            AppTimerStatus.running => labels.pauseSemantic,
                            AppTimerStatus.paused => labels.resumeSemantic,
                            _ => labels.dismissSemantic,
                          },
                          variant: finished ? AppButtonVariant.primary : AppButtonVariant.secondary,
                          onPressed: onToggle,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (!finished && !stopped)
              Positioned(
                top: AppSpacing.s300,
                right: 16,
                child: AppIconButton(
                  icon: AppIcons.x,
                  semanticLabel: labels.stopSemantic,
                  variant: AppButtonVariant.ghost,
                  size: AppButtonSize.standard,
                  onPressed: onStop,
                ),
              ),
            if (stopped && countdown != null)
              Positioned(
                right: AppSpacing.s500,
                bottom: 44,
                child: Text(countdown, style: AppTypography.labelLarge.copyWith(color: theme.textSecondary)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress, required this.active});

  final double progress;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: Container(
        height: 8,
        color: theme.bgSurfaceSunken,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              color: active ? theme.actionPrimaryDefault : theme.borderStrong,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
          ),
        ),
      ),
    );
  }
}
