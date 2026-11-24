import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import 'src/alba_app.dart';
import 'src/alba_bootstrap.dart';

/// Punto de composición: elige los adaptadores y los plugins
/// (`alba_composition.dart`), los arranca y muestra la app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDesignSystemLicenses();
  final AlbaEnvironment environment = await bootstrapAlba(
    languageCode: LocalizationCoordinator.resolveLanguage(PlatformDispatcher.instance.locales),
  );
  runApp(AlbaApp(environment: environment));
}
