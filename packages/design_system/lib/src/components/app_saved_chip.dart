import 'package:flutter/widgets.dart';

import '../tokens/app_radii.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_pressable.dart';

/// Ficha de un tiempo guardado de cocina (`Saved/Chip/*`): píldora de 72 con
/// nombre y minutos («Huevo pasado · 7 min»). La elegida lleva lavado y borde
/// ámbar.
class AppSavedChip extends StatelessWidget {
  const AppSavedChip({
    super.key,
    required this.label,
    required this.duration,
    required this.onTap,
    this.selected = false,
    this.semanticLabel,
  });

  final String label;

  /// Duración ya formateada («7 min»).
  final String duration;
  final VoidCallback? onTap;
  final bool selected;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return AppPressable(
      onTap: onTap,
      color: selected ? theme.bgBrandSubtle : theme.bgSurfaceRaised,
      pressedColor: selected ? theme.bgBrandMuted : theme.bgSurfacePressed,
      borderColor: selected ? theme.borderBrand : theme.borderDefault,
      borderRadius: BorderRadius.circular(AppRadii.full),
      semanticLabel: semanticLabel ?? '$label, $duration',
      selected: selected,
      child: SizedBox(
        height: AppSizes.controlLarge,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s600),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s300,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                style: AppTypography.labelLarge.copyWith(
                  color: selected ? theme.textOnBrandSubtle : theme.textPrimary,
                ),
              ),
              Text(
                duration,
                maxLines: 1,
                style: AppTypography.labelLarge.copyWith(color: selected ? theme.textBrand : theme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
