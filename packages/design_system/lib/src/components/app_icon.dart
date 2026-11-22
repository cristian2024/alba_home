import 'package:flutter/widgets.dart';

import '../tokens/app_icon_data.dart';
import '../tokens/app_sizes.dart';
import 'svg_path_parser.dart';

/// Dibuja un icono de `AppIcons` a [size] con [color] (por defecto, el del
/// `IconTheme`). Sin [semanticLabel] es decorativo y el lector lo salta.
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = AppSizes.iconMedium, this.color, this.semanticLabel});

  final AppIconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Color paintColor = color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    final Widget painted = SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _IconPainter(SvgPathParser.parseCached(icon.pathData), paintColor)),
    );
    final String? label = semanticLabel;
    if (label == null) {
      return ExcludeSemantics(child: painted);
    }
    return Semantics(label: label, image: true, child: ExcludeSemantics(child: painted));
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.path, this.color);

  final Path path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / AppIconData.viewBox;
    canvas
      ..save()
      ..scale(scale)
      ..drawPath(path, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) => oldDelegate.path != path || oldDelegate.color != color;
}
