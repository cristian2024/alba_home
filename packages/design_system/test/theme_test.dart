import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los temas llevan sus colores semánticos y no tienen sombras', () {
    expect(AppTheme.light.extension<AppThemeColors>(), AppThemeColors.light);
    expect(AppTheme.dark.extension<AppThemeColors>(), AppThemeColors.dark);
    expect(AppTheme.light.scaffoldBackgroundColor, AppThemeColors.light.bgCanvas);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppThemeColors.dark.bgCanvas);
    expect(AppTheme.light.colorScheme.primary, AppThemeColors.light.actionPrimaryDefault);
    expect(AppTheme.light.colorScheme.surfaceTint.a, 0);
    expect(AppTheme.light.splashFactory, NoSplash.splashFactory);
  });

  test('el tema de noche es ámbar sobre negro', () {
    expect(AppTheme.night.scaffoldBackgroundColor, AppNightColors.bg);
    expect(AppTheme.night.colorScheme.onSurface, AppNightColors.textPrimary);
    expect(AppTheme.night.textTheme.bodyMedium?.color, AppNightColors.textPrimary);
    expect(AppTheme.night.iconTheme.color, AppNightColors.textPrimary);
  });

  test('el textTheme usa Inter del paquete y cifras tabulares', () {
    final TextStyle body = AppTheme.light.textTheme.bodyMedium!;

    expect(body.fontFamily, contains(AppTypography.fontFamily));
    expect(body.fontSize, AppTypography.body.fontSize);
    expect(body.fontFeatures, AppTypography.fontFeatures);
  });

  testWidgets('AppThemeColors.of usa el tema y, sin él, el claro', (WidgetTester tester) async {
    late AppThemeColors inDark;
    late AppThemeColors withoutTheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (BuildContext context) {
            inDark = AppThemeColors.of(context);
            return Theme(
              data: ThemeData(),
              child: Builder(
                builder: (BuildContext inner) {
                  withoutTheme = AppThemeColors.of(inner);
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );

    expect(inDark, AppThemeColors.dark);
    expect(withoutTheme, AppThemeColors.light);
  });

  test('copyWith y lerp de AppThemeColors', () {
    final AppThemeColors changed = AppThemeColors.light.copyWith(bgCanvas: AppColors.amber50);

    expect(changed.bgCanvas, AppColors.amber50);
    expect(changed.textPrimary, AppThemeColors.light.textPrimary);
    expect(AppThemeColors.light.copyWith(), isNot(same(AppThemeColors.light)));
    expect(AppThemeColors.light.lerp(AppThemeColors.dark, 1).bgCanvas, AppThemeColors.dark.bgCanvas);
    expect(AppThemeColors.light.lerp(null, 0.5), same(AppThemeColors.light));
  });
}
