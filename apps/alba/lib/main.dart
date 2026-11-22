import 'package:core_di/core_di.dart';
import 'package:flutter/widgets.dart';

import 'alba_app.dart';

/// Punto de composición. Por ahora solo prepara el [ServiceLocator]; los
/// plugins y sus adaptadores se registran aquí a medida que existan.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ServiceLocator services = ServiceLocator.instance;
  runApp(AlbaApp(services: services));
}
