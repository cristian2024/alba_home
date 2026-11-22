import 'package:flutter/widgets.dart';

import '../tokens/app_radii.dart';
import '../tokens/app_theme_colors.dart';
import 'app_pressable.dart';

/// Interruptor (`Settings/Switch/*`): área de 72 × 48, pista de 56 × 32 y
/// botón de 24. Encendido, pista ámbar y botón a la derecha.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged, required this.semanticLabel});

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Qué enciende («Alarma Trabajo»); el lector añade el estado.
  final String semanticLabel;

  static const double width = 72;
  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final ValueChanged<bool>? changed = onChanged;
    return AppPressable(
      onTap: changed == null ? null : () => changed(!value),
      semanticLabel: semanticLabel,
      toggled: value,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 32,
            padding: const EdgeInsets.all(4),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            decoration: BoxDecoration(
              color: value ? theme.actionPrimaryDefault : theme.actionSecondaryPressed,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: theme.bgSurface, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}
