import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:design_system_example/src/gallery_app.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ancho de las hojas de Penpot (`01_componentes_*.png`, a 1×).
const double _sheetWidth = 2924;

/// Con `--dart-define=GALLERY_OUT=<carpeta>`, guarda la galería entera en
/// claro y oscuro para compararla con las hojas de Penpot.
const String _out = String.fromEnvironment('GALLERY_OUT');

void main() {
  for (final bool dark in <bool>[false, true]) {
    final String theme = dark ? 'oscuro' : 'claro';

    testWidgets('la galería se monta sin errores en tema $theme', (WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(_sheetWidth, 8000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(RepaintBoundary(child: GalleryApp(initialDark: dark)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppTimerCard), findsNWidgets(4));
      expect(find.byType(AppIcon), findsWidgets);

      if (_out.isNotEmpty) {
        await _capture(tester, '$_out/galeria_$theme.png');
      }
    });
  }

  testWidgets('el interruptor cambia de tema', (WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(_sheetWidth, 8000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GalleryApp());

    await tester.tap(find.bySemanticsLabel('Tema oscuro'));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(AppTimerCard).first);
    expect(AppThemeColors.of(context), AppThemeColors.dark);
  });
}

Future<void> _capture(WidgetTester tester, String path) async {
  final RenderRepaintBoundary boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage();
    final ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
