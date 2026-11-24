import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Botón de 72 que hay que mantener pulsado [holdDuration] para actuar
/// (03.5b): mientras se mantiene cambia la etiqueta y una pista de 8 se va
/// llenando debajo. Soltar antes no hace nada. Con TalkBack, mantener
/// pulsado (doble toque largo) actúa al momento.
class HoldToDismissButton extends StatefulWidget {
  const HoldToDismissButton({
    super.key,
    required this.label,
    required this.holdingLabel,
    required this.semanticLabel,
    required this.onDismiss,
    this.icon = AppIcons.alarmOff,
    this.variant = AppButtonVariant.secondary,
    this.holdDuration = const Duration(seconds: 1),
  });

  final String label;
  final String holdingLabel;
  final String semanticLabel;
  final VoidCallback onDismiss;
  final AppIconData icon;
  final AppButtonVariant variant;
  final Duration holdDuration;

  @override
  State<HoldToDismissButton> createState() => _HoldToDismissButtonState();
}

class _HoldToDismissButtonState extends State<HoldToDismissButton> with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this, duration: widget.holdDuration)
    ..addStatusListener(_onStatus);

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onDismiss();
    }
  }

  void _start() => _progress.forward(from: 0);

  void _cancel() {
    if (!_progress.isCompleted) {
      _progress.reverse();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppButtonColors colors = AppButtonColors.of(context, widget.variant);
    final bool night = widget.variant == AppButtonVariant.night;
    final AppThemeColors theme = AppThemeColors.of(context);
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      onLongPress: widget.onDismiss,
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        CustomSemanticsAction(label: widget.label): widget.onDismiss,
      },
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (BuildContext context, Widget? child) {
          final bool holding = _progress.value > 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Se queda con el toque: soltar antes de tiempo no debe contar como
              // tocar la pantalla (que pospone).
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Listener(
                  onPointerDown: (PointerDownEvent event) => _start(),
                  onPointerUp: (PointerUpEvent event) => _cancel(),
                  onPointerCancel: (PointerCancelEvent event) => _cancel(),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: holding ? colors.pressed : colors.background,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      border: colors.border == null
                          ? null
                          : Border.all(color: colors.border!, width: AppSizes.strokeThin),
                    ),
                    child: SizedBox(
                      height: AppSizes.controlLarge,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s800),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: AppSpacing.s300,
                          children: <Widget>[
                            AppIcon(widget.icon, color: colors.foreground),
                            Text(
                              holding ? widget.holdingLabel : widget.label,
                              style: AppTypography.labelLarge.copyWith(color: colors.foreground),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s300),
              SizedBox(
                width: 223,
                height: 8,
                child: Opacity(
                  opacity: holding ? 1 : 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      minHeight: 8,
                      backgroundColor: night ? AppNightColors.action : theme.borderDefault,
                      color: night ? AppNightColors.textPrimary : theme.actionPrimaryDefault,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
