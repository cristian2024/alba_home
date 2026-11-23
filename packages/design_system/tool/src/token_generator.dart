import 'dart:convert';

/// Genera los tokens del sistema de diseño a partir de las exportaciones de
/// Penpot (`tokens.json` y los iconos de `spec.json`).
///
/// Devuelve el contenido de cada archivo por su ruta dentro de
/// `lib/src/tokens/`. No toca el disco: lo escribe `generate_tokens.dart` y el
/// test comprueba que lo versionado coincide.
Map<String, String> generateTokens({required String tokensJson, required String specJson}) {
  final Map<String, Object?> tokens = jsonDecode(tokensJson) as Map<String, Object?>;
  final Map<String, Object?> spec = jsonDecode(specJson) as Map<String, Object?>;
  final List<Map<String, Object?>> primitives = _list(tokens['colors']);
  final Map<String, String> primitiveNames = <String, String>{
    for (final Map<String, Object?> color in primitives) color['name']! as String: _camel(color['name']! as String),
  };

  return <String, String>{
    'app_colors.dart': _colors(primitives),
    'app_theme_colors.dart': _themeColors(_list(tokens['semantic']), primitiveNames),
    'app_night_colors.dart': _nightColors(_list(tokens['night']), primitiveNames),
    'app_spacing.dart': _numbers(
      'AppSpacing',
      'Escala de espaciado (`spacing.*`), en dp.',
      _map(tokens['spacing']),
    ),
    'app_radii.dart': _numbers('AppRadii', 'Radios de borde (`radii.*`), en dp. `full` es la píldora.', _map(tokens['radii'])),
    'app_sizes.dart': _numbers(
      'AppSizes',
      'Tamaños de controles, iconos y trazos (`sizes.*`), en dp.',
      _map(tokens['sizes']),
    ),
    'app_layout.dart': _numbers(
      'AppLayout',
      'Lienzo fijo del aparato y medidas de la composición (`layout.*`).',
      _map(tokens['layout']),
    ),
    'app_opacity.dart': _numbers('AppOpacity', 'Opacidades (`opacity.*`), de 0 a 1.', _map(tokens['opacity'])),
    'app_typography.dart': _typography(_list(tokens['styles']), _map(tokens['fonts'])),
    'app_icons.dart': _icons(_list(spec['icons'])),
  };
}

const String _header = '// GENERADO por tool/generate_tokens.dart desde design/referencia_penpot.\n'
    '// No editar a mano: cambia el JSON exportado de Penpot y vuelve a generar.\n';

String _colors(List<Map<String, Object?>> primitives) {
  final StringBuffer out = StringBuffer()
    ..writeln(_header)
    ..writeln("import 'dart:ui';")
    ..writeln()
    ..writeln('/// Colores primitivos de Penpot (`warm.50` es `warm50`). Los componentes')
    ..writeln('/// no los usan directamente: leen [AppThemeColors] o [AppNightColors].')
    ..writeln('abstract final class AppColors {');
  for (final Map<String, Object?> color in primitives) {
    final String name = color['name']! as String;
    out
      ..writeln('  /// `$name`')
      ..writeln('  static const Color ${_camel(name)} = Color(${_argb(color['value']! as String)});');
  }
  out.writeln('}');
  return out.toString();
}

String _themeColors(List<Map<String, Object?>> semantic, Map<String, String> primitiveNames) {
  final List<String> fields = <String>[for (final Map<String, Object?> token in semantic) token['dart']! as String];
  final StringBuffer out = StringBuffer()
    ..writeln(_header)
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln("import 'app_colors.dart';")
    ..writeln()
    ..writeln('/// Colores semánticos de los temas claro y oscuro (`bg.surface-raised` es')
    ..writeln('/// `bgSurfaceRaised`). Se leen del tema con [AppThemeColors.of].')
    ..writeln('@immutable')
    ..writeln('class AppThemeColors extends ThemeExtension<AppThemeColors> {')
    ..writeln('  const AppThemeColors({');
  for (final String field in fields) {
    out.writeln('    required this.$field,');
  }
  out
    ..writeln('  });')
    ..writeln();
  for (final String mode in <String>['light', 'dark']) {
    out.writeln('  static const AppThemeColors $mode = AppThemeColors(');
    for (final Map<String, Object?> token in semantic) {
      out.writeln('    ${token['dart']}: AppColors.${primitiveNames[token[mode]]!},');
    }
    out
      ..writeln('  );')
      ..writeln();
  }
  for (final Map<String, Object?> token in semantic) {
    out
      ..writeln('  /// `${token['name']}`')
      ..writeln('  final Color ${token['dart']};');
  }
  out
    ..writeln()
    ..writeln('  /// Colores del tema de [context]; los del tema claro si no hay ninguno.')
    ..writeln('  static AppThemeColors of(BuildContext context) => Theme.of(context).extension<AppThemeColors>() ?? light;')
    ..writeln()
    ..writeln('  @override')
    ..writeln('  AppThemeColors copyWith({');
  for (final String field in fields) {
    out.writeln('    Color? $field,');
  }
  out
    ..writeln('  }) =>')
    ..writeln('      AppThemeColors(');
  for (final String field in fields) {
    out.writeln('        $field: $field ?? this.$field,');
  }
  out
    ..writeln('      );')
    ..writeln()
    ..writeln('  @override')
    ..writeln('  AppThemeColors lerp(covariant AppThemeColors? other, double t) {')
    ..writeln('    if (other == null) {')
    ..writeln('      return this;')
    ..writeln('    }')
    ..writeln('    return AppThemeColors(');
  for (final String field in fields) {
    out.writeln('      $field: Color.lerp($field, other.$field, t)!,');
  }
  out
    ..writeln('    );')
    ..writeln('  }')
    ..writeln('}');
  return out.toString();
}

String _nightColors(List<Map<String, Object?>> night, Map<String, String> primitiveNames) {
  final StringBuffer out = StringBuffer()
    ..writeln(_header)
    ..writeln("import 'dart:ui';")
    ..writeln()
    ..writeln("import 'app_colors.dart';")
    ..writeln()
    ..writeln('/// Colores de noche: ámbar sobre negro, iguales en los dos temas')
    ..writeln('/// (`night.text-primary` es `textPrimary`).')
    ..writeln('abstract final class AppNightColors {');
  for (final Map<String, Object?> token in night) {
    final String dart = token['dart']! as String;
    final String field = dart.substring(5, 6).toLowerCase() + dart.substring(6);
    out
      ..writeln('  /// `${token['name']}`')
      ..writeln('  static const Color $field = AppColors.${primitiveNames[token['value']]!};');
  }
  out.writeln('}');
  return out.toString();
}

String _numbers(String className, String doc, Map<String, Object?> values) {
  final StringBuffer out = StringBuffer()
    ..writeln(_header)
    ..writeln('/// $doc')
    ..writeln('abstract final class $className {');
  for (final MapEntry<String, Object?> entry in values.entries) {
    final num value = entry.value! as num;
    out
      ..writeln('  /// `${entry.key}`')
      ..writeln('  static const double ${_identifier(entry.key)} = ${_double(value)};');
  }
  out.writeln('}');
  return out.toString();
}

String _typography(List<Map<String, Object?>> styles, Map<String, Object?> fonts) {
  final List<String> features = <String>[for (final Object? feature in fonts['features']! as List<Object?>) feature! as String];
  final StringBuffer out = StringBuffer()
    ..writeln(_header)
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln('/// Estilos de texto de Penpot (`type.clock.hero` es `clockHero`), con')
    ..writeln('/// ${fonts['sans']} incluida en el paquete (${fonts['license']}) y cifras')
    ..writeln('/// tabulares en todos, para que las cifras que cambian no bailen.')
    ..writeln('abstract final class AppTypography {')
    ..writeln("  static const String fontFamily = '${fonts['sans']}';")
    ..writeln()
    ..writeln('  /// Un `TextStyle` propio debe indicar este paquete o Flutter no encuentra')
    ..writeln('  /// la fuente.')
    ..writeln("  static const String fontPackage = 'design_system';")
    ..writeln()
    ..writeln('  static const List<FontFeature> fontFeatures = <FontFeature>[');
  for (final String feature in features) {
    out.writeln(feature == 'tnum' ? '    FontFeature.tabularFigures(),' : "    FontFeature.enable('$feature'),");
  }
  out
    ..writeln('  ];')
    ..writeln();
  for (final Map<String, Object?> style in styles) {
    final num size = style['size']! as num;
    final num lineHeight = style['lh']! as num;
    final String tracking = (style['ls']! as String).split('*').last.trim();
    out
      ..writeln('  /// `${style['token']}`: ${style['weight']}, ${_double(size)}/${_double(lineHeight)}.')
      ..writeln('  static const TextStyle ${style['name']} = TextStyle(')
      ..writeln('    fontFamily: fontFamily,')
      ..writeln('    package: fontPackage,')
      ..writeln('    fontSize: ${_double(size)},')
      ..writeln('    height: ${_double(lineHeight / size)},')
      ..writeln('    fontWeight: FontWeight.w${style['weight']},')
      ..writeln('    letterSpacing: ${_double(size * double.parse(tracking))},')
      ..writeln('    fontFeatures: fontFeatures,')
      ..writeln('  );')
      ..writeln();
  }
  out.writeln('}');
  return out.toString();
}

/// Primer código de la fuente `AlbaIcons` (`tool/generate_icon_font.py`):
/// cada icono va en este más su posición en `spec.json`.
const int firstIconCodepoint = 0xE000;

String _icons(List<Map<String, Object?>> icons) {
  final StringBuffer out = StringBuffer()
    ..writeln(_header)
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln("import 'app_icon_data.dart';")
    ..writeln()
    ..writeln('/// Iconos de Penpot (Lucide con el trazo ya convertido en relleno), en una')
    ..writeln('/// caja de 24. Se dibujan con `AppIcon`; `iconData` da el glifo de la')
    ..writeln('/// fuente `AlbaIcons` para quien necesite un `IconData`.')
    ..writeln('abstract final class AppIcons {');
  for (int index = 0; index < icons.length; index++) {
    final Map<String, Object?> icon = icons[index];
    final String name = icon['name']! as String;
    final String codepoint = '0x${(firstIconCodepoint + index).toRadixString(16).toUpperCase()}';
    out
      ..writeln('  /// `$name`')
      ..writeln('  static const AppIconData ${_camel(name)} = AppIconData(')
      ..writeln("    '$name',")
      ..writeln('    IconData($codepoint, fontFamily: AppIconData.fontFamily, fontPackage: AppIconData.fontPackage),')
      ..writeln("    '${icon['d']}',")
      ..writeln('  );');
  }
  out
    ..writeln()
    ..writeln('  /// Todos, en el orden de Penpot (el de sus códigos).')
    ..writeln('  static const List<AppIconData> all = <AppIconData>[');
  for (final Map<String, Object?> icon in icons) {
    out.writeln('    ${_camel(icon['name']! as String)},');
  }
  out
    ..writeln('  ];')
    ..writeln()
    ..writeln('  /// El icono de [codepoint] (p. ej. el `IconData` de una cápsula); `null` si')
    ..writeln('  /// no es de `AlbaIcons`.')
    ..writeln('  static AppIconData? byCodepoint(int codepoint) {')
    ..writeln('    final int index = codepoint - $firstIconCodepoint;')
    ..writeln('    return index >= 0 && index < all.length ? all[index] : null;')
    ..writeln('  }')
    ..writeln('}');
  return out.toString();
}

List<Map<String, Object?>> _list(Object? value) =>
    <Map<String, Object?>>[for (final Object? item in value! as List<Object?>) item! as Map<String, Object?>];

Map<String, Object?> _map(Object? value) => value! as Map<String, Object?>;

/// `warm.50` → `warm50`, `night.amber-dim` → `nightAmberDim`, `moon-star` →
/// `moonStar`.
String _camel(String name) {
  final List<String> parts = name.split(RegExp(r'[.\-]')).where((String part) => part.isNotEmpty).toList();
  final StringBuffer out = StringBuffer(parts.first);
  for (final String part in parts.skip(1)) {
    out.write(part[0].toUpperCase() + part.substring(1));
  }
  return _identifier(out.toString());
}

/// Un nombre que empieza por cifra (`2xLarge`) no es un identificador válido.
String _identifier(String name) => RegExp(r'^\d').hasMatch(name) ? 'x$name' : name;

/// `#RRGGBB` o `#RRGGBBAA` → `0xAARRGGBB`.
String _argb(String hex) {
  final String value = hex.substring(1).toUpperCase();
  final String alpha = value.length == 8 ? value.substring(6) : 'FF';
  return '0x$alpha${value.substring(0, 6)}';
}

String _double(num value) {
  final double rounded = double.parse(value.toDouble().toStringAsFixed(4));
  return rounded == rounded.roundToDouble() ? rounded.toStringAsFixed(0) : rounded.toString();
}
