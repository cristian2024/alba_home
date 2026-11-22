import 'package:flutter/material.dart';

import '../tokens/app_opacity.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_theme_colors.dart';
import 'app_quick_ripple.dart';

/// Superficie pulsable plana: cambia a [pressedColor] mientras se pulsa,
/// muestra el anillo de foco de 3 px con teclado o Switch Access y se anuncia
/// como botón. Sin [onTap] queda desactivada (atenuada al 40 %).
///
/// Con [splashColor], además, una onda sale del punto que se toca (la usan
/// los botones).
///
/// Es la base de los botones, fichas, filas y tarjetas pulsables; sirve
/// también para controles propios.
class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.onTap,
    required this.child,
    this.color,
    this.pressedColor,
    this.borderColor,
    this.borderRadius = BorderRadius.zero,
    this.semanticLabel,
    this.selected,
    this.toggled,
    this.focusColor,
    this.splashColor,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color? color;

  /// Fondo mientras se pulsa; por defecto, [color].
  final Color? pressedColor;

  /// Borde de 1 px; sin él no hay borde.
  final Color? borderColor;
  final BorderRadius borderRadius;

  /// Lo que anuncia el lector. Sin él, el texto de [child].
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;

  /// Color del anillo de foco; por defecto `borderFocus` del tema.
  final Color? focusColor;

  /// Color de la onda al pulsar; sin él no hay onda.
  final Color? splashColor;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _pressed = false;
  bool _focused = false;

  VoidCallback? get _onTap => widget.onTap;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) {
      setState(() => _pressed = pressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = _onTap != null;
    final Color? background = _pressed && enabled ? (widget.pressedColor ?? widget.color) : widget.color;
    final Color? border = widget.borderColor;
    final Color focus = widget.focusColor ?? AppThemeColors.of(context).borderFocus;
    final Color? splash = widget.splashColor;
    final bool withSplash = splash != null && enabled;
    final Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: widget.borderRadius,
        border: border == null ? null : Border.all(color: border, width: AppSizes.strokeThin),
      ),
      child: withSplash
          ? Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: _onTap,
                onHighlightChanged: _setPressed,
                canRequestFocus: false,
                excludeFromSemantics: true,
                splashColor: splash,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashFactory: AppQuickRipple.splashFactory,
                customBorder: RoundedRectangleBorder(borderRadius: widget.borderRadius),
                child: widget.child,
              ),
            )
          : widget.child,
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      selected: widget.selected,
      toggled: widget.toggled,
      excludeSemantics: widget.semanticLabel != null,
      child: FocusableActionDetector(
        enabled: enabled,
        onShowFocusHighlight: (bool focused) => setState(() => _focused = focused),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (ActivateIntent intent) => _onTap?.call()),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Con onda, los toques los recibe el InkWell.
          onTap: withSplash ? null : _onTap,
          onTapDown: enabled && !withSplash ? (TapDownDetails details) => _setPressed(true) : null,
          onTapUp: enabled && !withSplash ? (TapUpDetails details) => _setPressed(false) : null,
          onTapCancel: enabled && !withSplash ? () => _setPressed(false) : null,
          child: Opacity(
            opacity: enabled ? 1 : AppOpacity.disabled,
            child: _focused
                ? DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                      border: Border.all(
                        color: focus,
                        width: AppSizes.strokeFocus,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: surface,
                  )
                : surface,
          ),
        ),
      ),
    );
  }
}
