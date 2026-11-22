import 'package:flutter/widgets.dart';

import '../tokens/app_icon_data.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_icon.dart';
import 'app_pressable.dart';
import 'app_switch.dart';

/// Fila de ajustes (`Settings/Row/*`), de 80 de alto y radio 16: icono en
/// círculo de 48, título y subtítulo opcional, y a la derecha un valor y un
/// *chevron* (con [onTap]) o un interruptor (con [switchValue]).
///
/// Ocupa el ancho que le den: 827 en una columna, 405 en el índice de dos
/// columnas. Con [attention] va en ocre (algo pendiente, como la guía de
/// Huawei).
class AppSettingsRow extends StatelessWidget {
  const AppSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.switchValue,
    this.onSwitchChanged,
    this.attention = false,
    this.semanticLabel,
  }) : assert(switchValue == null || onTap == null, 'una fila con interruptor no navega');

  final AppIconData icon;
  final String title;
  final String? subtitle;

  /// Valor a la derecha, antes del *chevron* («Español»).
  final String? value;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final bool attention;
  final String? semanticLabel;

  static const double height = 80;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final String? sub = subtitle;
    final String? trailingValue = value;
    final bool? toggle = switchValue;
    final Widget row = SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.s400, right: AppSpacing.s400),
        child: Row(
          spacing: AppSpacing.s400,
          children: <Widget>[
            Container(
              width: AppSizes.controlMedium,
              height: AppSizes.controlMedium,
              decoration: BoxDecoration(
                color: attention ? theme.bgSurfaceRaised : theme.bgSurfaceSunken,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcon(icon, color: attention ? theme.textWarning : theme.textPrimary),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge.copyWith(color: theme.textPrimary),
                  ),
                  if (sub != null)
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(color: attention ? theme.textWarning : theme.textSecondary),
                    ),
                ],
              ),
            ),
            if (trailingValue != null)
              Text(trailingValue, maxLines: 1, style: AppTypography.body.copyWith(color: theme.textSecondary)),
            if (toggle != null)
              ExcludeSemantics(child: AppSwitch(value: toggle, onChanged: onSwitchChanged, semanticLabel: title))
            else if (onTap != null)
              AppIcon(AppIcons.chevronRight, color: theme.textTertiary),
          ],
        ),
      ),
    );
    final Color background = attention ? theme.bgWarningSubtle : theme.bgSurfaceRaised;
    final Color border = attention ? theme.borderWarning : theme.borderDefault;
    final BorderRadius radius = BorderRadius.circular(AppRadii.large);
    final String label = semanticLabel ?? <String?>[title, sub, trailingValue].whereType<String>().join(', ');
    if (toggle != null) {
      final ValueChanged<bool>? changed = onSwitchChanged;
      return AppPressable(
        onTap: changed == null ? null : () => changed(!toggle),
        color: background,
        pressedColor: theme.bgSurfacePressed,
        borderColor: border,
        borderRadius: radius,
        semanticLabel: label,
        toggled: toggle,
        child: row,
      );
    }
    return AppPressable(
      onTap: onTap,
      color: background,
      pressedColor: theme.bgSurfacePressed,
      borderColor: border,
      borderRadius: radius,
      semanticLabel: label,
      child: row,
    );
  }
}

/// Campo de un formulario de ajustes (`Settings/Row/Field`), de 72 de alto:
/// etiqueta pequeña encima del valor y *chevron* («Nombre · Trabajo»).
class AppSettingsField extends StatelessWidget {
  const AppSettingsField({super.key, required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return AppPressable(
      onTap: onTap,
      color: theme.bgSurfaceRaised,
      pressedColor: theme.bgSurfacePressed,
      borderColor: theme.borderDefault,
      borderRadius: BorderRadius.circular(AppRadii.large),
      semanticLabel: '$label, $value',
      child: SizedBox(
        height: AppSizes.controlLarge,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s500, right: AppSpacing.s600),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: <Widget>[
                    Text(label, maxLines: 1, style: AppTypography.label.copyWith(color: theme.textSecondary)),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge.copyWith(color: theme.textPrimary),
                    ),
                  ],
                ),
              ),
              AppIcon(AppIcons.chevronRight, color: theme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
