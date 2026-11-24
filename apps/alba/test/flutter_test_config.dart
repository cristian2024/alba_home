import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga Inter y AlbaIcons de design_system para medir como en el aparato.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const String fonts = '../../packages/design_system/assets/fonts';
  final FontLoader inter = FontLoader('packages/design_system/Inter');
  for (final String weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    inter.addFont(Future<ByteData>.value(ByteData.view(File('$fonts/Inter-$weight.ttf').readAsBytesSync().buffer)));
  }
  await inter.load();
  await (FontLoader('packages/design_system/AlbaIcons')
        ..addFont(Future<ByteData>.value(ByteData.view(File('$fonts/AlbaIcons.ttf').readAsBytesSync().buffer))))
      .load();
  await testMain();
}
