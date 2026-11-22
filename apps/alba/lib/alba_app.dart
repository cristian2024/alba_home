import 'package:core_di/core_di.dart';
import 'package:flutter/material.dart';

/// Raíz de la app. De momento muestra el nombre sobre negro; el reloj, el
/// tema y la navegación llegan con `design_system` y los plugins.
class AlbaApp extends StatelessWidget {
  const AlbaApp({super.key, required this.services});

  /// Dependencias registradas por los adaptadores y los plugins.
  final ServiceLocator services;

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Alba',
      debugShowCheckedModeBanner: false,
      home: ColoredBox(
        color: Color(0xFF000000),
        child: Center(
          child: Text(
            'Alba',
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 48),
          ),
        ),
      ),
    );
  }
}
