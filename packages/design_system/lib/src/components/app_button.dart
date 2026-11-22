import 'package:flutter/widgets.dart';

import '../tokens/app_icon_data.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_icon.dart';
import 'app_pressable.dart';

/// Variantes de botón de Penpot (`Button/Large/*`, `Button/Standard/*`,
/// `Button/Icon72/*`, `Button/Icon48/*`).
enum AppButtonVariant {
  /// Ámbar: la única acción principal de la pantalla.
  primary,

  /// Hundido con borde.
  secondary,

  /// Sin fondo.
  ghost,

  /// Terracota, para acciones peligrosas.
  danger,

  /// Noche: ámbar casi negro con borde ámbar tenue.
  night,

  /// Noche, acción principal: ámbar macizo con texto negro.
  nightPrimary,
}

/// Alto de un botón.
enum AppButtonSize {
  /// 72: lo que se toca medio dormido o con las manos ocupadas.
  large,

  /// 48: solo en configuración.
  standard,
}

/// Botón píldora con etiqueta e icono opcional.
///
/// Large: 72 de alto, 32 de relleno, icono de 24 y Label-large. Standard: 48,
/// 24 de relleno, icono de 20 y Label. El texto para TalkBack lleva el objeto
/// («Detener Pasta») con [semanticLabel].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.semanticLabel,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppIconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final String? semanticLabel;

  /// Ocupa todo el ancho que le den, con el contenido centrado.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final AppButtonColors colors = AppButtonColors.of(context, variant);
    final bool large = size == AppButtonSize.large;
    final AppIconData? leading = icon;
    return AppPressable(
      onTap: onPressed,
      color: colors.background,
      pressedColor: colors.pressed,
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(AppRadii.full),
      splashColor: colors.splash,
      semanticLabel: semanticLabel ?? label,
      child: SizedBox(
        height: large ? AppSizes.controlLarge : AppSizes.controlMedium,
        child: Padding(
          // Con expand el contenido va centrado y el relleno no se ve: basta con
          // un mínimo para que quepa una etiqueta en un hueco justo.
          padding: EdgeInsets.symmetric(
            horizontal: expand ? AppSpacing.s400 : (large ? AppSpacing.s800 : AppSpacing.s600),
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: large ? AppSpacing.s300 : AppSpacing.s200,
            children: <Widget>[
              if (leading != null)
                AppIcon(leading, size: large ? AppSizes.iconMedium : AppSizes.iconSmall, color: colors.foreground),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (large ? AppTypography.labelLarge : AppTypography.label).copyWith(color: colors.foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colores de una variante de botón en el tema actual.
class AppButtonColors {
  const AppButtonColors({required this.background, required this.pressed, required this.foreground, this.border});

  factory AppButtonColors.of(BuildContext context, AppButtonVariant variant) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return switch (variant) {
      AppButtonVariant.primary => AppButtonColors(
          background: theme.actionPrimaryDefault,
          pressed: theme.actionPrimaryPressed,
          foreground: theme.textOnBrand,
        ),
      AppButtonVariant.secondary => AppButtonColors(
          background: theme.actionSecondaryDefault,
          pressed: theme.actionSecondaryPressed,
          foreground: theme.textPrimary,
          border: theme.borderDefault,
        ),
      AppButtonVariant.ghost => AppButtonColors(
          background: null,
          pressed: theme.actionGhostPressed,
          foreground: theme.textPrimary,
        ),
      AppButtonVariant.danger => AppButtonColors(
          background: theme.actionDangerDefault,
          pressed: theme.actionDangerPressed,
          foreground: theme.textOnDanger,
        ),
      AppButtonVariant.night => const AppButtonColors(
          background: AppNightColors.action,
          pressed: AppNightColors.border,
          foreground: AppNightColors.textPrimary,
          border: AppNightColors.border,
        ),
      AppButtonVariant.nightPrimary => const AppButtonColors(
          background: AppNightColors.textPrimary,
          pressed: AppNightColors.textSecondary,
          foreground: AppNightColors.bg,
        ),
    };
  }

  final Color? background;
  final Color pressed;
  final Color foreground;
  final Color? border;

  /// Onda al pulsar: el color del texto, translúcido.
  Color get splash => foreground.withValues(alpha: splashOpacity);

  /// Opacidad de la onda. Penpot no la define: está elegida para que se vea
  /// sobre el ámbar y sobre el negro de noche sin tapar la etiqueta.
  static const double splashOpacity = 0.24;
}
