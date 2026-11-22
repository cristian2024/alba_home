import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Añade a la lista de licencias de la app la de Inter (SIL OFL 1.1) y la de
/// los iconos Lucide (ISC), redibujados desde Penpot.
void registerDesignSystemLicenses() => LicenseRegistry.addLicense(() async* {
      for (final (String name, String file) in const <(String, String)>[
        ('Inter', 'OFL-Inter.txt'),
        ('Lucide', 'LICENSE-Lucide.txt'),
      ]) {
        final String text = await rootBundle.loadString('packages/design_system/assets/$file');
        yield LicenseEntryWithLineBreaks(<String>['design_system', name], text);
      }
    });
