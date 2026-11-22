import 'package:flutter/widgets.dart';

import '../theme/app_tone.dart';
import '../tokens/app_icon_data.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_typography.dart';
import 'app_icon.dart';
import 'app_status_colors.dart';

/// Bloque de estado (`Status/Block/*`), de 140 × 120 y sin fondo salvo si es
/// urgente: icono de 28, valor en Display y etiqueta en Label, centrados. Va a
/// los lados de la hora («6:30 · Alarma», «18 % · Batería»).
class AppStatusBlock extends StatelessWidget {
  const AppStatusBlock({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.tone = AppTone.surface,
    this.urgency = AppUrgency.normal,
    this.semanticLabel,
  });

  final AppIconData icon;
  final String value;
  final String label;
  final AppTone tone;
  final AppUrgency urgency;

  /// Lectura completa para TalkBack; sin ella, «[label], [value]».
  final String? semanticLabel;

  static const double width = 140;
  static const double height = 120;

  @override
  Widget build(BuildContext context) {
    final AppStatusColors colors = AppStatusColors.of(context, tone, urgency);
    return Semantics(
      label: semanticLabel ?? '$label, $value',
      excludeSemantics: true,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.blockBackground,
          borderRadius: BorderRadius.circular(AppRadii.large),
        ),
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: <Widget>[
            AppIcon(icon, size: 28, color: colors.icon),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: AppTypography.display.copyWith(color: colors.text),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.label.copyWith(color: colors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
