import 'package:flutter/widgets.dart';

import '../tokens/app_icon_data.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_sizes.dart';
import 'app_button.dart';
import 'app_icon.dart';
import 'app_pressable.dart';

/// Botón circular de solo icono: 72 con icono de 32 (`Button/Icon72`) o 48
/// con icono de 24 (`Button/Icon48`). [semanticLabel] es obligatorio: dice qué
/// hace y sobre qué («Pausar Pasta»).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.size = AppButtonSize.large,
  });

  final AppIconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final AppButtonColors colors = AppButtonColors.of(context, variant);
    final bool large = size == AppButtonSize.large;
    final double side = large ? AppSizes.controlLarge : AppSizes.controlMedium;
    return AppPressable(
      onTap: onPressed,
      color: colors.background,
      pressedColor: colors.pressed,
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(AppRadii.full),
      semanticLabel: semanticLabel,
      child: SizedBox.square(
        dimension: side,
        child: Center(
          child: AppIcon(icon, size: large ? AppSizes.iconLarge : AppSizes.iconMedium, color: colors.foreground),
        ),
      ),
    );
  }
}
