import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga Inter del paquete para que la galería mida como en el aparato.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final FontLoader inter = FontLoader('packages/design_system/Inter');
  for (final String weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final Uint8List bytes = File('../assets/fonts/Inter-$weight.ttf').readAsBytesSync();
    inter.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
  }
  await inter.load();
  await testMain();
}
