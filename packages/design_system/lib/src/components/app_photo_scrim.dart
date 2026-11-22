import 'package:flutter/widgets.dart';

import '../tokens/app_layout.dart';
import '../tokens/app_theme_colors.dart';

/// Degradado que sube desde el borde inferior de la foto del reloj y da a la
/// hora su contraste (7:1 o más): alto 371, sólido al 72 % hasta el 42 % y
/// luego hasta transparente. Va encima de la foto y debajo de la hora.
class AppPhotoScrim extends StatelessWidget {
  const AppPhotoScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        child: SizedBox(
          height: AppLayout.scrimHeight,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[theme.photoScrimEnd, theme.photoScrimEnd, theme.photoScrimStart],
                stops: const <double>[0, AppLayout.scrimSolidFrom, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
