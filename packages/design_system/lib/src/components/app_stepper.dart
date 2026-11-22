import 'package:flutter/widgets.dart';

import '../tokens/app_icons.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';
import 'app_icon_button.dart';

/// Selector de un valor con − y + (`Settings/Stepper`), de 264 × 48 («20 %»).
/// Sin [onDecrement] o [onIncrement], ese botón queda desactivado (en el
/// límite).
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.decrementLabel,
    required this.incrementLabel,
    this.semanticValue,
  });

  /// Valor ya formateado.
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  /// Para el lector («Bajar el aviso de batería baja»).
  final String decrementLabel;
  final String incrementLabel;

  /// Lectura del valor si difiere de [value].
  final String? semanticValue;

  static const double width = 264;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return SizedBox(
      width: width,
      child: Row(
        children: <Widget>[
          AppIconButton(
            icon: AppIcons.minus,
            semanticLabel: decrementLabel,
            onPressed: onDecrement,
            size: AppButtonSize.standard,
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              label: semanticValue,
              excludeSemantics: semanticValue != null,
              child: Text(
                value,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(color: theme.textPrimary),
              ),
            ),
          ),
          AppIconButton(
            icon: AppIcons.plus,
            semanticLabel: incrementLabel,
            onPressed: onIncrement,
            size: AppButtonSize.standard,
          ),
        ],
      ),
    );
  }
}
