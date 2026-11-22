import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Onda corta para los botones: entra en 40 ms, crece en 120 ms y se apaga
/// en 120 ms. El `InkRipple` de Material tarda casi un segundo y sus tiempos
/// no se pueden cambiar.
class AppQuickRipple extends InteractiveInkFeature {
  AppQuickRipple({
    required super.controller,
    required super.referenceBox,
    required Offset position,
    required super.color,
    required TextDirection textDirection,
    super.customBorder,
    BorderRadius? borderRadius,
    super.onRemoved,
  })  : _position = position,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _textDirection = textDirection,
        _targetRadius = _farthestCorner(referenceBox.size, position) {
    _fadeInController = AnimationController(duration: fadeInDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    _radiusController = AnimationController(duration: radiusDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    _fadeOutController = AnimationController(duration: fadeOutDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleFadeOutStatus);
    controller.addInkFeature(this);
  }

  static const Duration fadeInDuration = Duration(milliseconds: 40);
  static const Duration radiusDuration = Duration(milliseconds: 120);
  static const Duration fadeOutDuration = Duration(milliseconds: 120);

  /// Para `InkWell.splashFactory`.
  static const InteractiveInkFeatureFactory splashFactory = _AppQuickRippleFactory();

  final Offset _position;
  final BorderRadius _borderRadius;
  final TextDirection _textDirection;
  final double _targetRadius;

  late final AnimationController _fadeInController;
  late final AnimationController _radiusController;
  late final AnimationController _fadeOutController;

  static double _farthestCorner(Size size, Offset position) {
    final List<Offset> corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    return corners.map((Offset corner) => (corner - position).distance).reduce(math.max);
  }

  @override
  void confirm() {
    _radiusController.forward();
    _fadeInController.forward();
    _fadeOutController.forward();
  }

  @override
  void cancel() {
    _fadeInController.stop();
    _fadeOutController.forward();
  }

  void _handleFadeOutStatus(AnimationStatus status) {
    if (status.isCompleted) {
      dispose();
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _radiusController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final double opacity = _fadeInController.value * (1 - _fadeOutController.value);
    final double radius = _targetRadius * Curves.easeOut.transform(_radiusController.value);
    paintInkCircle(
      canvas: canvas,
      transform: transform,
      paint: Paint()..color = color.withValues(alpha: color.a * opacity),
      center: _position,
      textDirection: _textDirection,
      radius: radius,
      customBorder: customBorder,
      borderRadius: _borderRadius,
    );
  }
}

class _AppQuickRippleFactory extends InteractiveInkFeatureFactory {
  const _AppQuickRippleFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) =>
      AppQuickRipple(
        controller: controller,
        referenceBox: referenceBox,
        position: position,
        color: color,
        textDirection: textDirection,
        customBorder: customBorder,
        borderRadius: borderRadius,
        onRemoved: onRemoved,
      );
}
