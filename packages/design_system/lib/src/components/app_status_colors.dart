import 'package:flutter/widgets.dart';

import '../theme/app_tone.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_theme_colors.dart';

/// Colores de una cápsula o bloque de estado según el fondo y la urgencia
/// (`Status/Capsule/*` y `Status/Block/*`).
class AppStatusColors {
  const AppStatusColors({
    required this.icon,
    required this.text,
    required this.secondaryText,
    this.capsuleBackground,
    this.capsuleBorder,
    this.blockBackground,
  });

  factory AppStatusColors.of(BuildContext context, AppTone tone, AppUrgency urgency) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return switch ((tone, urgency)) {
      (AppTone.surface, AppUrgency.normal) => AppStatusColors(
          icon: theme.textBrand,
          text: theme.textPrimary,
          secondaryText: theme.textSecondary,
          capsuleBackground: theme.bgSurfaceRaised,
          capsuleBorder: theme.borderDefault,
        ),
      (AppTone.surface, AppUrgency.warning) => AppStatusColors(
          icon: theme.textWarning,
          text: theme.textPrimary,
          secondaryText: theme.textWarning,
          capsuleBackground: theme.bgWarningSubtle,
          capsuleBorder: theme.borderWarning,
        ),
      (AppTone.surface, AppUrgency.urgent) => AppStatusColors(
          icon: theme.textDanger,
          text: theme.textDanger,
          secondaryText: theme.textDanger,
          capsuleBackground: theme.bgDangerSubtle,
          capsuleBorder: theme.borderDanger,
          blockBackground: theme.bgDangerSubtle,
        ),
      (AppTone.photo, AppUrgency.normal) => AppStatusColors(
          icon: theme.textOnPhoto,
          text: theme.textOnPhoto,
          secondaryText: theme.textOnPhoto,
          capsuleBackground: theme.photoScrimEnd,
          capsuleBorder: theme.borderOnPhoto,
        ),
      (AppTone.photo, AppUrgency.warning) => AppStatusColors(
          icon: theme.statusWarning,
          text: theme.textOnPhoto,
          secondaryText: theme.textOnPhoto,
          capsuleBackground: theme.photoScrimEnd,
          capsuleBorder: theme.borderOnPhoto,
        ),
      (AppTone.photo, AppUrgency.urgent) => AppStatusColors(
          icon: theme.textOnDanger,
          text: theme.textOnDanger,
          secondaryText: theme.textOnDanger,
          capsuleBackground: theme.actionDangerDefault,
          blockBackground: theme.actionDangerDefault,
        ),
      (AppTone.night, AppUrgency.normal) => const AppStatusColors(
          icon: AppNightColors.textSecondary,
          text: AppNightColors.textPrimary,
          secondaryText: AppNightColors.textSecondary,
          capsuleBackground: AppNightColors.bg,
          capsuleBorder: AppNightColors.border,
        ),
      (AppTone.night, AppUrgency.warning) => const AppStatusColors(
          icon: AppNightColors.textPrimary,
          text: AppNightColors.textPrimary,
          secondaryText: AppNightColors.textSecondary,
          capsuleBackground: AppNightColors.bg,
          capsuleBorder: AppNightColors.border,
        ),
      (AppTone.night, AppUrgency.urgent) => const AppStatusColors(
          icon: AppNightColors.textAlert,
          text: AppNightColors.textAlert,
          secondaryText: AppNightColors.textAlert,
          capsuleBackground: AppNightColors.bg,
          capsuleBorder: AppNightColors.textAlert,
        ),
    };
  }

  final Color icon;

  /// Texto principal: la etiqueta de la cápsula o el valor del bloque.
  final Color text;

  /// Etiqueta bajo el valor de un bloque.
  final Color secondaryText;
  final Color? capsuleBackground;
  final Color? capsuleBorder;

  /// Solo los bloques urgentes llevan fondo.
  final Color? blockBackground;
}
