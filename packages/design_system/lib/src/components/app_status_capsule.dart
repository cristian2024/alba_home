import 'package:flutter/widgets.dart';

import '../theme/app_tone.dart';
import '../tokens/app_icon_data.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_icon.dart';
import 'app_pressable.dart';
import 'app_status_colors.dart';

/// Cápsula de estado (`Status/Capsule/*`): icono de 28 y texto en Title, en
/// una píldora de 60. Es lo que muestra el reloj de cada plugin («Alarma
/// 6:30», «Batería 18 %», «Pasta · lista»). Con [onTap] es pulsable.
class AppStatusCapsule extends StatelessWidget {
  const AppStatusCapsule({
    super.key,
    required this.icon,
    required this.label,
    this.tone = AppTone.surface,
    this.urgency = AppUrgency.normal,
    this.onTap,
    this.semanticLabel,
  });

  final AppIconData icon;
  final String label;
  final AppTone tone;
  final AppUrgency urgency;
  final VoidCallback? onTap;
  final String? semanticLabel;

  static const double height = 60;

  @override
  Widget build(BuildContext context) {
    final AppStatusColors colors = AppStatusColors.of(context, tone, urgency);
    final BorderRadius radius = BorderRadius.circular(AppRadii.full);
    final Widget content = SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.s500, right: AppSpacing.s500),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: <Widget>[
            AppIcon(icon, size: 28, color: colors.icon),
            Text(label, maxLines: 1, style: AppTypography.title.copyWith(color: colors.text)),
          ],
        ),
      ),
    );
    final VoidCallback? tap = onTap;
    if (tap == null) {
      final Color? border = colors.capsuleBorder;
      return Semantics(
        label: semanticLabel,
        excludeSemantics: semanticLabel != null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.capsuleBackground,
            borderRadius: radius,
            border: border == null ? null : Border.all(color: border, width: AppSizes.strokeThin),
          ),
          child: content,
        ),
      );
    }
    return AppPressable(
      onTap: tap,
      color: colors.capsuleBackground,
      borderColor: colors.capsuleBorder,
      borderRadius: radius,
      semanticLabel: semanticLabel ?? label,
      child: content,
    );
  }
}
