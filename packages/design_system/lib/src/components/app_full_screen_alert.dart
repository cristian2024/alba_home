import 'package:flutter/widgets.dart';

import '../tokens/app_icon_data.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Variante de aviso a pantalla completa (`Alert/FullScreen/*`).
enum AppFullScreenVariant {
  /// Icono ámbar sobre lavado ámbar (temporizador terminado).
  normal,

  /// Icono terracota (batería crítica).
  danger,

  /// Noche.
  night,
}

/// Una acción de un aviso: etiqueta, icono y qué hace.
class AppAlertAction {
  const AppAlertAction({required this.label, required this.onPressed, this.icon, this.semanticLabel});

  final String label;
  final AppIconData? icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
}

/// Aviso a pantalla completa (`Alert/FullScreen/*`): sustituye la pantalla
/// entera. Icono de 40 en círculo de 80, título en Display, subtítulo y uno o
/// dos botones de 72 centrados (el principal a la derecha).
class AppFullScreenAlert extends StatelessWidget {
  const AppFullScreenAlert({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
    this.secondary,
    this.variant = AppFullScreenVariant.normal,
  });

  final AppIconData icon;
  final String title;
  final String subtitle;
  final AppAlertAction primary;
  final AppAlertAction? secondary;
  final AppFullScreenVariant variant;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final bool night = variant == AppFullScreenVariant.night;
    final (Color iconBackground, Color iconColor) = switch (variant) {
      AppFullScreenVariant.normal => (theme.bgBrandMuted, theme.textBrand),
      AppFullScreenVariant.danger => (theme.bgDangerSubtle, theme.textDanger),
      AppFullScreenVariant.night => (AppNightColors.action, AppNightColors.textPrimary),
    };
    final AppAlertAction? second = secondary;
    return Semantics(
      container: true,
      liveRegion: true,
      child: ColoredBox(
        color: night ? AppNightColors.bg : theme.bgCanvas,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s1200, AppSpacing.s1000, AppSpacing.s1200, AppSpacing.s1200),
          child: Column(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: AppIcon(icon, size: 40, color: iconColor),
              ),
              const SizedBox(height: AppSpacing.s500),
              Text(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(color: night ? AppNightColors.textPrimary : theme.textPrimary),
              ),
              const SizedBox(height: AppSpacing.s200),
              Text(
                subtitle,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  color: night ? AppNightColors.textSecondary : theme.textSecondary,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.s600,
                children: <Widget>[
                  if (second != null)
                    AppButton(
                      label: second.label,
                      icon: second.icon,
                      variant: night ? AppButtonVariant.night : AppButtonVariant.secondary,
                      semanticLabel: second.semanticLabel,
                      onPressed: second.onPressed,
                    ),
                  AppButton(
                    label: primary.label,
                    icon: primary.icon,
                    variant: night ? AppButtonVariant.night : AppButtonVariant.primary,
                    semanticLabel: primary.semanticLabel,
                    onPressed: primary.onPressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
