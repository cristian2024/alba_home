import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'gallery_page.dart';

/// Galería con un selector de tema arriba a la derecha (claro u oscuro). Las
/// variantes de noche y sobre foto aparecen en sus paneles en los dos temas,
/// como en las hojas de Penpot.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key, this.initialDark = false});

  final bool initialDark;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late bool _dark = widget.initialDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'design_system',
      debugShowCheckedModeBanner: false,
      theme: _dark ? AppTheme.dark : AppTheme.light,
      home: GalleryPage(dark: _dark, onDarkChanged: (bool dark) => setState(() => _dark = dark)),
    );
  }
}
