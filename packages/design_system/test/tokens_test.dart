import 'dart:io';
import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:design_system/src/components/svg_path_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/src/token_generator.dart';

void main() {
  const String source = '../../design/referencia_penpot';

  test('los tokens versionados coinciden con lo que genera tokens.json', () {
    final Map<String, String> generated = generateTokens(
      tokensJson: File('$source/tokens.json').readAsStringSync(),
      specJson: File('$source/spec.json').readAsStringSync(),
    );

    for (final MapEntry<String, String> file in generated.entries) {
      expect(
        File('lib/src/tokens/${file.key}').readAsStringSync(),
        file.value,
        reason: '${file.key} no coincide: ejecuta `dart run tool/generate_tokens.dart` en packages/design_system',
      );
    }
  });

  test('los colores salen del JSON en ARGB', () {
    expect(AppColors.warm50, const Color(0xFFFAF6EF));
    expect(AppColors.alphaScrim72, const Color(0xB80B0A09));
    expect(AppNightColors.bg, const Color(0xFF000000));
    expect(AppNightColors.textPrimary, AppColors.nightAmber);
    expect(AppThemeColors.light.bgCanvas, AppColors.warm50);
    expect(AppThemeColors.dark.bgCanvas, AppColors.warm950);
  });

  test('las medidas y la tipografía siguen a Penpot', () {
    expect(AppSizes.touchLarge, 72);
    expect(AppRadii.full, 999);
    expect(AppRadii.x2xLarge, 32);
    expect(AppLayout.screenWidth, 891);
    expect(AppLayout.screenHeight, 411);
    expect(AppTypography.clockHero.fontSize, 205);
    expect(AppTypography.clockHero.letterSpacing, closeTo(-6.15, 0.001));
    expect(AppTypography.body.height, closeTo(24 / 18, 0.001));
    expect(AppTypography.caption.fontFeatures, contains(const FontFeature.tabularFigures()));
    expect(AppTypography.title.fontFamily, 'packages/${AppTypography.fontPackage}/${AppTypography.fontFamily}');
  });

  test('hay un icono por cada uno de spec.json y todos se pueden dibujar', () {
    expect(AppIcons.all, hasLength(58));
    for (final AppIconData icon in AppIcons.all) {
      final Rect bounds = SvgPathParser.parse(icon.pathData).getBounds();
      expect(bounds.left, greaterThanOrEqualTo(0), reason: icon.name);
      expect(bounds.right, lessThanOrEqualTo(AppIconData.viewBox), reason: icon.name);
      expect(bounds.isEmpty, isFalse, reason: icon.name);
    }
    expect(AppIcons.batteryLow.toString(), 'AppIconData(battery-low)');
  });

  test('cada icono tiene su código en AlbaIcons y se recupera por él', () {
    for (int index = 0; index < AppIcons.all.length; index++) {
      final AppIconData icon = AppIcons.all[index];
      expect(icon.codepoint, 0xE000 + index, reason: icon.name);
      expect(AppIcons.byCodepoint(icon.iconData.codePoint), same(icon));
    }
    expect(AppIcons.alarm.iconData.fontFamily, 'AlbaIcons');
    expect(AppIcons.alarm.iconData.fontPackage, 'design_system');
    expect(AppIcons.byCodepoint(0xDFFF), isNull);
    expect(AppIcons.byCodepoint(0xE000 + AppIcons.all.length), isNull);
  });

  test('la fuente AlbaIcons existe y está declarada', () {
    expect(File('assets/fonts/AlbaIcons.ttf').lengthSync(), greaterThan(10000));
    expect(File('pubspec.yaml').readAsStringSync(), contains('assets/fonts/AlbaIcons.ttf'));
  });

  group('SvgPathParser', () {
    test('admite M, L, H, V, Q y Z con varias coordenadas seguidas', () {
      final Path path = SvgPathParser.parse('M0 0L10 0H20V10Q20 20 10 20L0 20 0 10Z');

      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 20, 20));
    });

    test('rechaza comandos que Penpot no exporta', () {
      expect(() => SvgPathParser.parse('M0 0C1 1 2 2 3 3'), throwsFormatException);
    });

    test('guarda en caché cada trazado', () {
      expect(SvgPathParser.parseCached('M0 0L1 1Z'), same(SvgPathParser.parseCached('M0 0L1 1Z')));
    });
  });
}
