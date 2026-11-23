import 'package:flutter/widgets.dart';

import '../tokens/app_icons.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_clock_time.dart';
import 'app_icon.dart';
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
    this.blocked = false,
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

  /// Android bloqueó las alarmas (03.7): el detalle va en rojo y un escudo
  /// sustituye al interruptor, que no sirve de nada hasta dar el permiso.
  final bool blocked;

  static const double height = 96;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final Color dangerColor = theme.textDanger;
    final Color secondaryColor = theme.textSecondary;
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
                            color: enabled ? theme.textPrimary : secondaryColor,
                          ),
                        ),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body.copyWith(color: blocked ? dangerColor : secondaryColor),
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
          child: blocked
              ? SizedBox(
                  width: AppSwitch.width,
                  height: AppSwitch.height,
                  child: Center(child: AppIcon(AppIcons.shieldAlert, size: AppSizes.iconLarge, color: dangerColor)),
                )
              : AppSwitch(value: enabled, onChanged: onEnabledChanged, semanticLabel: label),
        ),
      ],
    );
  }
}
