import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

/// Cabecera de las pantallas de la alarma: botón de volver o cerrar de 72,
/// título, resumen y la acción principal a la derecha.
class AlarmHeader extends StatelessWidget {
  const AlarmHeader({
    super.key,
    required this.title,
    this.subtitle = '',
    this.leading,
    this.leadingLabel = '',
    this.onLeading,
    this.action,
  });

  final String title;
  final String subtitle;
  final AppIconData? leading;
  final String leadingLabel;
  final VoidCallback? onLeading;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final AppIconData? icon = leading;
    final Widget? trailing = action;
    return Padding(
      // 0 + 72 + 16: el contenido empieza en y = 88, como en Penpot.
      padding: const EdgeInsets.fromLTRB(AppSpacing.s200, 0, AppSpacing.s800, AppSpacing.s400),
      child: Row(
        children: <Widget>[
          if (icon != null)
            AppIconButton(icon: icon, semanticLabel: leadingLabel, variant: AppButtonVariant.ghost, onPressed: onLeading)
          else
            const SizedBox(width: AppSpacing.s600),
          const SizedBox(width: AppSpacing.s200),
          Semantics(header: true, child: Text(title, style: AppTypography.title.copyWith(color: theme.textPrimary))),
          const SizedBox(width: AppSpacing.s400),
          Expanded(
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(color: theme.textSecondary),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
