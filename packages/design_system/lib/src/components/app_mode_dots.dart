import 'package:flutter/widgets.dart';

import '../theme/app_tone.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_theme_colors.dart';

/// Puntos de modo (`Mode/Dots/*`): uno por modo, el actual alargado a 24.
/// Aparecen solo al deslizar entre modos. [semanticLabel] dice dónde se está
/// («Modo 2 de 3, Sonidos»).
class AppModeDots extends StatelessWidget {
  const AppModeDots({
    super.key,
    required this.count,
    required this.index,
    this.tone = AppTone.surface,
    this.semanticLabel,
  }) : assert(index >= 0 && index < count, 'index fuera de rango');

  final int count;
  final int index;
  final AppTone tone;
  final String? semanticLabel;

  static const double _dot = 8;
  static const double _activeWidth = 24;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final (Color active, Color inactive) = switch (tone) {
      AppTone.surface => (theme.actionPrimaryDefault, theme.borderStrong),
      AppTone.photo => (theme.textOnPhoto, theme.borderOnPhoto),
      AppTone.night => (AppNightColors.textSecondary, AppNightColors.border),
    };
    final List<Widget> dots = <Widget>[];
    for (int i = 0; i < count; i++) {
      final bool current = i == index;
      dots.add(
        Container(
          width: current ? _activeWidth : _dot,
          height: _dot,
          decoration: BoxDecoration(
            color: current ? active : inactive,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
        ),
      );
    }
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(mainAxisSize: MainAxisSize.min, spacing: AppSpacing.s200, children: dots),
    );
  }
}
