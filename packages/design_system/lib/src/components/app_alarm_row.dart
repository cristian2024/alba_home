import 'package:flutter/widgets.dart';

import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_clock_time.dart';
import 'app_pressable.dart';
import 'app_switch.dart';

/// Fila de alarma (`Alarm/Row/*`), de 96 de alto y radio 16: hora de 56,
/// nombre, días y cuándo suena, e interruptor. Desactivada, la hora va en
/// terciario y el nombre en secundario. Tocar la fila la abre para editar.
class AppAlarmRow extends StatelessWidget {
  const AppAlarmRow({
    super.key,
    required this.time,
    required this.label,
    required this.detail,
    required this.enabled,
    required this.onEnabledChanged,
    required this.onTap,
    this.semanticLabel,
  });

  /// Hora ya formateada («06:30»).
  final String time;
  final String label;

  /// «Lun a vie · suena en 7 h 13 min».
  final String detail;
  final bool enabled;
  final ValueChanged<bool>? onEnabledChanged;
  final VoidCallback? onTap;
  final String? semanticLabel;

  static const double height = 96;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final String rowLabel = semanticLabel ?? '$time, $label, $detail';
    return Stack(
      children: <Widget>[
        AppPressable(
          onTap: onTap,
          color: theme.bgSurfaceRaised,
          pressedColor: theme.bgSurfacePressed,
          borderColor: theme.borderDefault,
          borderRadius: BorderRadius.circular(AppRadii.large),
          semanticLabel: rowLabel,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.s600, right: AppSpacing.s600),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 160,
                    child: AppClockTime(time, size: AppClockSize.small, dimmed: !enabled),
                  ),
                  const SizedBox(width: AppSpacing.s800),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: <Widget>[
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyLarge.copyWith(
                            color: enabled ? theme.textPrimary : theme.textSecondary,
                          ),
                        ),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body.copyWith(color: theme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Hueco del interruptor, que va encima como control aparte.
                  const SizedBox(width: AppSwitch.width),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: AppSpacing.s600,
          top: (height - AppSwitch.height) / 2,
          child: AppSwitch(value: enabled, onChanged: onEnabledChanged, semanticLabel: label),
        ),
      ],
    );
  }
}
