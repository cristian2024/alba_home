import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta [child] en el lienzo del aparato (891 × 411) con [theme].
Future<void> pumpOnDevice(WidgetTester tester, Widget child, {ThemeData? theme}) async {
  tester.view
    ..physicalSize = const Size(AppLayout.screenWidth, AppLayout.screenHeight)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

/// Los tres temas, para recorrerlos en un test.
final Map<String, ThemeData> allThemes = <String, ThemeData>{
  'claro': AppTheme.light,
  'oscuro': AppTheme.dark,
  'noche': AppTheme.night,
};

/// Color de fondo del primer `DecoratedBox` con color dentro de [finder].
Color? backgroundOf(WidgetTester tester, Finder finder) {
  for (final DecoratedBox box in tester.widgetList<DecoratedBox>(find.descendant(of: finder, matching: find.byType(DecoratedBox)))) {
    final Decoration decoration = box.decoration;
    if (decoration is BoxDecoration && decoration.color != null) {
      return decoration.color;
    }
  }
  return null;
}
