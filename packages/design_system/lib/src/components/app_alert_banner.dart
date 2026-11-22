import 'package:flutter/widgets.dart';

import '../tokens/app_icon_data.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Variante de banner (`Alert/Banner/*`).
enum AppBannerVariant {
  /// Superficie con icono pizarra.
  info,

  /// Ocre: aviso.
  warning,

  /// Terracota maciza: peligro.
  critical,

  /// Sobre la foto, con el fondo del degradado y borde blanco translúcido.
  photo,

  /// Noche.
  night,
}

/// Banner de aviso (`Alert/Banner/*`), de 96 de alto y radio 16: icono de 28
/// en círculo de 56, título en Label-large, texto en Body y un botón de 72 a
/// 12 del borde por arriba, abajo y a la derecha. Entra arriba, a 24 del borde,
/// con 827 de ancho.
class AppAlertBanner extends StatelessWidget {
  const AppAlertBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.variant = AppBannerVariant.info,
    this.actionSemanticLabel,
  });

  final AppIconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final AppBannerVariant variant;
  final String? actionSemanticLabel;

  static const double height = 96;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final _BannerColors colors = switch (variant) {
      AppBannerVariant.info => _BannerColors(
          background: theme.bgSurfaceRaised,
          border: theme.borderDefault,
          iconBackground: theme.bgInfoSubtle,
          icon: theme.textInfo,
          title: theme.textPrimary,
          message: theme.textSecondary,
          button: AppButtonVariant.secondary,
        ),
      AppBannerVariant.warning => _BannerColors(
          background: theme.bgWarningSubtle,
          border: theme.borderWarning,
          iconBackground: theme.bgSurfaceRaised,
          icon: theme.textWarning,
          title: theme.textWarning,
          message: theme.textPrimary,
          button: AppButtonVariant.secondary,
        ),
      AppBannerVariant.critical => _BannerColors(
          background: theme.actionDangerDefault,
          iconBackground: theme.bgOnPhoto,
          icon: theme.textOnDanger,
          title: theme.textOnDanger,
          message: theme.textOnDanger,
          button: AppButtonVariant.secondary,
        ),
      AppBannerVariant.photo => _BannerColors(
          background: theme.photoScrimEnd,
          border: theme.borderOnPhoto,
          iconBackground: theme.bgOnPhoto,
          icon: theme.statusWarning,
          title: theme.textOnPhoto,
          message: theme.textOnPhoto,
          button: AppButtonVariant.primary,
        ),
      AppBannerVariant.night => const _BannerColors(
          background: AppNightColors.bg,
          border: AppNightColors.border,
          iconBackground: AppNightColors.action,
          icon: AppNightColors.textPrimary,
          title: AppNightColors.textPrimary,
          message: AppNightColors.textSecondary,
          button: AppButtonVariant.night,
        ),
    };
    final Color? border = colors.border;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: border == null ? null : Border.all(color: border, width: AppSizes.strokeThin),
        ),
        // El borde ya ocupa su píxel dentro del Container: el botón queda a 12
        // del borde exterior, como en Penpot.
        padding: EdgeInsets.only(
          left: AppSpacing.s500 - (border == null ? 0 : AppSizes.strokeThin),
          right: AppSpacing.s300 - (border == null ? 0 : AppSizes.strokeThin),
        ),
        child: Row(
          spacing: AppSpacing.s400,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: colors.iconBackground, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: AppIcon(icon, size: 28, color: colors.icon),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge.copyWith(color: colors.title),
                  ),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(color: colors.message),
                  ),
                ],
              ),
            ),
            AppButton(
              label: actionLabel,
              variant: colors.button,
              semanticLabel: actionSemanticLabel,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerColors {
  const _BannerColors({
    required this.background,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.message,
    required this.button,
    this.border,
  });

  final Color background;
  final Color? border;
  final Color iconBackground;
  final Color icon;
  final Color title;
  final Color message;
  final AppButtonVariant button;
}
