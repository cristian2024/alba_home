import 'package:flutter/widgets.dart';

import '../tokens/app_radii.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_pressable.dart';

/// Día de la semana para repetir una alarma (`Day/Toggle/*`): círculo de 64,
/// ámbar si está elegido.
class AppDayToggle extends StatelessWidget {
  const AppDayToggle({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
    this.semanticLabel,
  });

  /// Abreviatura visible («Lun»).
  final String label;
  final bool selected;
  final ValueChanged<bool>? onChanged;

  /// Nombre completo para el lector («Lunes»).
  final String? semanticLabel;

  static const double size = 64;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final ValueChanged<bool>? changed = onChanged;
    return AppPressable(
      onTap: changed == null ? null : () => changed(!selected),
      color: selected ? theme.actionPrimaryDefault : theme.bgSurfaceRaised,
      pressedColor: selected ? theme.actionPrimaryPressed : theme.bgSurfacePressed,
      borderColor: selected ? null : theme.borderDefault,
      borderRadius: BorderRadius.circular(AppRadii.full),
      semanticLabel: semanticLabel ?? label,
      toggled: selected,
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            style: AppTypography.labelLarge.copyWith(color: selected ? theme.textOnBrand : theme.textSecondary),
          ),
        ),
      ),
    );
  }
}
