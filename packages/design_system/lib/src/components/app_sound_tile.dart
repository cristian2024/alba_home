import 'package:flutter/widgets.dart';

import '../theme/app_tone.dart';
import '../tokens/app_icon_data.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_icon.dart';
import 'app_pressable.dart';

/// Sonido para dormir (`Sound/Tile/*`), de 196 × 156 y radio 24: icono de
/// 40, nombre en Heading y detalle en Caption. El que suena va seleccionado.
/// Con [tone] noche, ámbar sobre negro.
class AppSoundTile extends StatelessWidget {
  const AppSoundTile({
    super.key,
    required this.icon,
    required this.name,
    required this.detail,
    required this.onTap,
    this.selected = false,
    this.tone = AppTone.surface,
  });

  final AppIconData icon;
  final String name;

  /// «Bucle sin cortes», o «Reproduciendo» si está seleccionado.
  final String detail;
  final VoidCallback? onTap;
  final bool selected;
  final AppTone tone;

  static const double width = 196;
  static const double height = 156;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final Color secondaryColor = theme.textSecondary;
    final bool night = tone == AppTone.night;
    final Color background = night ? AppNightColors.bg : (selected ? theme.bgBrandSubtle : theme.bgSurfaceRaised);
    final Color border = night
        ? (selected ? AppNightColors.textSecondary : AppNightColors.border)
        : (selected ? theme.borderBrand : theme.borderDefault);
    final Color iconColor = night
        ? (selected ? AppNightColors.textPrimary : AppNightColors.textSecondary)
        : (selected ? theme.textBrand : secondaryColor);
    final Color nameColor = night ? (selected ? AppNightColors.textPrimary : AppNightColors.textSecondary) : theme.textPrimary;
    final Color detailColor = night
        ? AppNightColors.textSecondary
        : (selected ? theme.textOnBrandSubtle : secondaryColor);
    return AppPressable(
      onTap: onTap,
      color: background,
      pressedColor: night ? AppNightColors.action : theme.bgSurfacePressed,
      borderColor: border,
      borderRadius: BorderRadius.circular(AppRadii.extraLarge),
      semanticLabel: '$name, $detail',
      selected: selected,
      focusColor: night ? AppNightColors.textPrimary : null,
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppIcon(icon, size: 40, color: iconColor),
              const Spacer(),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading.copyWith(color: nameColor),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(color: detailColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
