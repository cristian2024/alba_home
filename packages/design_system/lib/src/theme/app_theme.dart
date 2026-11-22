import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';

/// Temas de Alba. [light] y [dark] siguen el tema del sistema; [night] es el
/// modo noche del reloj (ámbar sobre negro), igual sea cual sea el tema.
///
/// Es un sistema plano: sin sombras ni elevación, sin tinte de superficie y
/// sin salpicadura al pulsar (el aparato no tiene puntero ni hover).
abstract final class AppTheme {
  static final ThemeData light = _build(
    brightness: Brightness.light,
    colors: AppThemeColors.light,
    scheme: ColorScheme.light(
      primary: AppThemeColors.light.actionPrimaryDefault,
      onPrimary: AppThemeColors.light.textOnBrand,
      secondary: AppThemeColors.light.actionSecondaryDefault,
      onSecondary: AppThemeColors.light.textPrimary,
      error: AppThemeColors.light.statusDanger,
      onError: AppThemeColors.light.textOnDanger,
      surface: AppThemeColors.light.bgSurface,
      onSurface: AppThemeColors.light.textPrimary,
      onSurfaceVariant: AppThemeColors.light.textSecondary,
      outline: AppThemeColors.light.borderDefault,
      outlineVariant: AppThemeColors.light.borderDefault,
    ),
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    colors: AppThemeColors.dark,
    scheme: ColorScheme.dark(
      primary: AppThemeColors.dark.actionPrimaryDefault,
      onPrimary: AppThemeColors.dark.textOnBrand,
      secondary: AppThemeColors.dark.actionSecondaryDefault,
      onSecondary: AppThemeColors.dark.textPrimary,
      error: AppThemeColors.dark.statusDanger,
      onError: AppThemeColors.dark.textOnDanger,
      surface: AppThemeColors.dark.bgSurface,
      onSurface: AppThemeColors.dark.textPrimary,
      onSurfaceVariant: AppThemeColors.dark.textSecondary,
      outline: AppThemeColors.dark.borderDefault,
      outlineVariant: AppThemeColors.dark.borderDefault,
    ),
  );

  /// Noche: fondo negro, texto ámbar y bordes ámbar tenue. Los componentes
  /// con variante de noche la eligen con su tono (`AppTone.night`); este tema
  /// cubre lo demás (fondo, texto por defecto, iconos).
  static final ThemeData night = _build(
    brightness: Brightness.dark,
    colors: AppThemeColors.dark,
    scheme: const ColorScheme.dark(
      primary: AppNightColors.textPrimary,
      onPrimary: AppNightColors.bg,
      secondary: AppNightColors.action,
      onSecondary: AppNightColors.textPrimary,
      error: AppNightColors.textAlert,
      onError: AppNightColors.bg,
      surface: AppNightColors.bg,
      onSurface: AppNightColors.textPrimary,
      onSurfaceVariant: AppNightColors.textSecondary,
      outline: AppNightColors.border,
      outlineVariant: AppNightColors.border,
    ),
    canvas: AppNightColors.bg,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppThemeColors colors,
    required ColorScheme scheme,
    Color? canvas,
  }) {
    final TextTheme textTheme = _textTheme(scheme.onSurface);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme.copyWith(surfaceTint: AppColors.alphaScrim0, shadow: AppColors.alphaScrim0),
      scaffoldBackgroundColor: canvas ?? colors.bgCanvas,
      canvasColor: canvas ?? colors.bgCanvas,
      fontFamily: AppTypography.fontFamily,
      package: AppTypography.fontPackage,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: scheme.onSurface),
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.alphaScrim0,
      hoverColor: AppColors.alphaScrim0,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.borderFocus,
        selectionColor: colors.bgBrandMuted,
        selectionHandleColor: colors.borderFocus,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  /// Escala de Material apuntando a los estilos de Penpot más cercanos, para
  /// los widgets de Flutter que leen `textTheme`. Los componentes de Alba usan
  /// [AppTypography] directamente.
  static TextTheme _textTheme(Color color) => const TextTheme(
        displayLarge: AppTypography.clockMedium,
        displayMedium: AppTypography.clockSmall,
        displaySmall: AppTypography.display,
        headlineLarge: AppTypography.display,
        headlineMedium: AppTypography.title,
        headlineSmall: AppTypography.subtitle,
        titleLarge: AppTypography.title,
        titleMedium: AppTypography.heading,
        titleSmall: AppTypography.labelLarge,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.label,
        labelSmall: AppTypography.caption,
      ).apply(bodyColor: color, displayColor: color);
}
