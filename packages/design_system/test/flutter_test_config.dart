import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga Inter antes de los tests: con la fuente de pruebas de Flutter (cada
/// letra un cuadrado) las medidas no se parecen a las de Penpot.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final FontLoader inter = FontLoader('packages/design_system/Inter');
  for (final String weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final Uint8List bytes = File('assets/fonts/Inter-$weight.ttf').readAsBytesSync();
    inter.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
  }
  await inter.load();
  final FontLoader icons = FontLoader('packages/design_system/AlbaIcons')
    ..addFont(Future<ByteData>.value(ByteData.view(File('assets/fonts/AlbaIcons.ttf').readAsBytesSync().buffer)));
  await icons.load();
  await testMain();
}
