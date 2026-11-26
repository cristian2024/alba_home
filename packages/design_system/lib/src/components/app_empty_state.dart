import 'package:flutter/widgets.dart';

import '../tokens/app_icon_data.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';
import 'app_icon.dart';
import 'app_full_screen_alert.dart';

/// Estado vacío (`Empty/State`), de 600 de ancho: icono de 48 en círculo de
/// 96, título, explicación y una acción opcional, de 48 ([actionSize]) o de
/// 72 donde Penpot la pide grande (la lista de alarmas vacía).
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.actionSize = AppButtonSize.standard,
  });

  final AppIconData icon;
  final String title;
  final String message;
  final AppAlertAction? action;
  final AppButtonSize actionSize;

  static const double width = 600;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final AppAlertAction? act = action;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: theme.bgSurfaceSunken, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AppIcon(icon, size: AppSizes.iconXLarge, color: theme.textTertiary),
          ),
          const SizedBox(height: AppSpacing.s500),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(color: theme.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1000),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: theme.textSecondary),
            ),
          ),
          if (act != null) ...<Widget>[
            const SizedBox(height: AppSpacing.s1000),
            AppButton(
              label: act.label,
              icon: act.icon,
              size: actionSize,
              semanticLabel: act.semanticLabel,
              onPressed: act.onPressed,
            ),
          ],
        ],
      ),
    );
  }
}
