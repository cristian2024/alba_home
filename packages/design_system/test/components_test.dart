import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump.dart';

void main() {
  group('AppPressable', () {
    testWidgets('cambia al color pulsado mientras se pulsa y llama a onTap', (WidgetTester tester) async {
      int taps = 0;
      await pumpOnDevice(
        tester,
        AppPressable(
          onTap: () => taps++,
          color: AppColors.amber400,
          pressedColor: AppColors.amber600,
          semanticLabel: 'Botón',
          child: const SizedBox(width: 100, height: 72),
        ),
      );
      final Finder pressable = find.byType(AppPressable);
      expect(backgroundOf(tester, pressable), AppColors.amber400);

      final TestGesture gesture = await tester.startGesture(tester.getCenter(pressable));
      await tester.pump();
      expect(backgroundOf(tester, pressable), AppColors.amber600);

      await gesture.up();
      await tester.pump();
      expect(backgroundOf(tester, pressable), AppColors.amber400);
      expect(taps, 1);
    });

    testWidgets('sin onTap queda atenuada y se anuncia desactivada', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpOnDevice(
        tester,
        const AppPressable(onTap: null, semanticLabel: 'Apagado', child: SizedBox(width: 100, height: 72)),
      );

      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, AppOpacity.disabled);
      expect(
        tester.getSemantics(find.byType(AppPressable)),
        matchesSemantics(label: 'Apagado', isButton: true, hasEnabledState: true),
      );
      semantics.dispose();
    });

    testWidgets('con teclado muestra el anillo de foco y se activa con Intro', (WidgetTester tester) async {
      int taps = 0;
      await pumpOnDevice(
        tester,
        AppPressable(onTap: () => taps++, semanticLabel: 'Foco', child: const SizedBox(width: 100, height: 72)),
      );
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final Iterable<DecoratedBox> rings = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).where(
            (DecoratedBox box) => box.position == DecorationPosition.foreground,
          );
      expect(rings, isNotEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
    });
  });

  group('botones', () {
    testWidgets('AppButton dibuja todas las variantes en los dos tamaños y anuncia su texto', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int taps = 0;
      await pumpOnDevice(
        tester,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final AppButtonVariant variant in AppButtonVariant.values)
              for (final AppButtonSize size in AppButtonSize.values)
                AppButton(
                  label: '${variant.name}-${size.name}',
                  icon: AppIcons.plus,
                  variant: variant,
                  size: size,
                  onPressed: () => taps++,
                ),
          ],
        ),
      );

      expect(tester.getSize(find.widgetWithText(AppButton, 'primary-large')).height, AppSizes.controlLarge);
      expect(tester.getSize(find.widgetWithText(AppButton, 'primary-standard')).height, AppSizes.controlMedium);
      await tester.tap(find.text('danger-large'));
      expect(taps, 1);
      expect(find.bySemanticsLabel('night-standard'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('los botones hacen una onda al pulsar, cambian de fondo y siguen funcionando', (WidgetTester tester) async {
      int taps = 0;
      await pumpOnDevice(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppButton(label: 'Posponer', onPressed: () => taps++),
            AppIconButton(icon: AppIcons.pause, semanticLabel: 'Pausar', onPressed: () => taps++),
          ],
        ),
      );
      final Finder button = find.byType(AppButton);
      final InkWell ink = tester.widget<InkWell>(find.descendant(of: button, matching: find.byType(InkWell)));
      expect(ink.splashColor, AppThemeColors.light.textOnBrand.withValues(alpha: AppButtonColors.splashOpacity));
      expect(find.descendant(of: find.byType(AppIconButton), matching: find.byType(InkWell)), findsOneWidget);

      final TestGesture gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 100));
      expect(backgroundOf(tester, button), AppThemeColors.light.actionPrimaryPressed);
      final RenderObject inkLayer = tester.renderObject(
        find.descendant(of: button, matching: find.byType(Material)).first,
      );
      expect(inkLayer, paints..circle());
      await gesture.up();
      await tester.pumpAndSettle();
      expect(backgroundOf(tester, button), AppThemeColors.light.actionPrimaryDefault);

      await tester.tap(find.bySemanticsLabel('Pausar'));
      expect(taps, 2);
    });

    testWidgets('la onda es corta: a los 300 ms ya no queda nada pintado', (WidgetTester tester) async {
      await pumpOnDevice(tester, AppButton(label: 'Posponer', onPressed: () {}));
      final Finder button = find.byType(AppButton);

      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 20));
      final RenderObject material = tester.renderObject(find.descendant(of: button, matching: find.byType(Material)).first);
      expect(material, paints..circle());

      await tester.pump(const Duration(milliseconds: 300));
      expect(material, isNot(paints..circle()));
    });

    testWidgets('la onda se recorta a la forma del botón, también en los redondos', (WidgetTester tester) async {
      await pumpOnDevice(
        tester,
        AppIconButton(icon: AppIcons.pause, semanticLabel: 'Pausar', onPressed: () {}),
      );
      final Finder button = find.byType(AppIconButton);

      await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 60));
      final RenderObject material = tester.renderObject(find.descendant(of: button, matching: find.byType(Material)).first);
      expect(material, paints..clipPath()..circle());
    });

    test('AppQuickRipple tarda en total menos de 300 ms', () {
      final Duration total = AppQuickRipple.radiusDuration + AppQuickRipple.fadeOutDuration;

      expect(total, lessThan(const Duration(milliseconds: 300)));
      expect(AppButtonColors.splashOpacity, lessThanOrEqualTo(0.12));
    });

    testWidgets('un botón desactivado no hace onda', (WidgetTester tester) async {
      await pumpOnDevice(tester, const AppButton(label: 'Posponer', onPressed: null));

      expect(find.descendant(of: find.byType(AppButton), matching: find.byType(InkWell)), findsNothing);
    });

    testWidgets('las fichas y filas no hacen onda', (WidgetTester tester) async {
      await pumpOnDevice(tester, AppSavedChip(label: 'Pasta', duration: '10 min', onTap: () {}));

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('AppButton usa semanticLabel con el nombre del objeto', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpOnDevice(
        tester,
        AppButton(label: 'Detener', semanticLabel: 'Detener Pasta', onPressed: () {}),
      );

      expect(find.bySemanticsLabel('Detener Pasta'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('AppIconButton mide 72 o 48 y anuncia lo que hace', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpOnDevice(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIconButton(icon: AppIcons.pause, semanticLabel: 'Pausar Pasta', onPressed: () {}),
            AppIconButton(
              icon: AppIcons.x,
              semanticLabel: 'Detener Pasta',
              size: AppButtonSize.standard,
              variant: AppButtonVariant.ghost,
              onPressed: () {},
            ),
          ],
        ),
      );

      expect(tester.getSize(find.bySemanticsLabel('Pausar Pasta')), const Size(72, 72));
      expect(tester.getSize(find.bySemanticsLabel('Detener Pasta')), const Size(48, 48));
      semantics.dispose();
    });
  });

  group('reloj y estados', () {
    for (final MapEntry<String, ThemeData> theme in allThemes.entries) {
      testWidgets('AppClockTime, bloques y cápsulas en tema ${theme.key}', (WidgetTester tester) async {
        await pumpOnDevice(
          tester,
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                for (final AppClockSize size in AppClockSize.values) AppClockTime('07:41', size: size),
                for (final AppTone tone in AppTone.values)
                  Wrap(
                    children: <Widget>[
                      for (final AppUrgency urgency in AppUrgency.values) ...<Widget>[
                        AppStatusBlock(icon: AppIcons.alarm, value: '6:30', label: 'Alarma', tone: tone, urgency: urgency),
                        AppStatusCapsule(icon: AppIcons.batteryLow, label: '18 %', tone: tone, urgency: urgency),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          theme: theme.value,
        );

        expect(find.text('07:41'), findsNWidgets(AppClockSize.values.length));
        expect(tester.getSize(find.byType(AppStatusBlock).first), const Size(140, 120));
        expect(tester.getSize(find.byType(AppStatusCapsule).first).height, 60);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('AppClockTime usa el estilo y el color de su tamaño y tono', (WidgetTester tester) async {
      await pumpOnDevice(
        tester,
        const Column(
          children: <Widget>[
            AppClockTime('22:05', tone: AppTone.night),
            AppClockTime('09:00', size: AppClockSize.small, dimmed: true),
            AppClockTime('08:24', size: AppClockSize.medium, tone: AppTone.photo, semanticLabel: 'ocho y veinticuatro'),
          ],
        ),
      );

      final TextStyle night = tester.widget<Text>(find.text('22:05')).style!;
      expect(night.fontSize, 205);
      expect(night.color, AppNightColors.textPrimary);
      expect(tester.widget<Text>(find.text('09:00')).style!.color, AppThemeColors.light.textTertiary);
      expect(tester.widget<Text>(find.text('08:24')).style!.color, AppThemeColors.light.textOnPhoto);
      expect(find.bySemanticsLabel('ocho y veinticuatro'), findsOneWidget);
    });

    testWidgets('AppStatusColors elige los colores de Penpot', (WidgetTester tester) async {
      late BuildContext context;
      await pumpOnDevice(
        tester,
        Builder(
          builder: (BuildContext inner) {
            context = inner;
            return const SizedBox();
          },
        ),
      );
      final AppThemeColors theme = AppThemeColors.light;

      expect(AppStatusColors.of(context, AppTone.surface, AppUrgency.warning).capsuleBorder, theme.borderWarning);
      expect(AppStatusColors.of(context, AppTone.photo, AppUrgency.warning).icon, theme.statusWarning);
      expect(AppStatusColors.of(context, AppTone.photo, AppUrgency.urgent).blockBackground, theme.actionDangerDefault);
      expect(AppStatusColors.of(context, AppTone.night, AppUrgency.urgent).text, AppNightColors.textAlert);
      expect(AppStatusColors.of(context, AppTone.surface, AppUrgency.normal).blockBackground, isNull);
    });

    testWidgets('una cápsula con onTap es un botón', (WidgetTester tester) async {
      int taps = 0;
      await pumpOnDevice(
        tester,
        AppStatusCapsule(icon: AppIcons.timer, label: 'Pasta · lista', onTap: () => taps++),
      );

      await tester.tap(find.text('Pasta · lista'));
      expect(taps, 1);
    });

    testWidgets('AppStatusBlock se lee como etiqueta y valor', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpOnDevice(tester, const AppStatusBlock(icon: AppIcons.alarm, value: '6:30', label: 'Alarma'));

      expect(find.bySemanticsLabel('Alarma, 6:30'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('AppModeDots alarga el punto actual', (WidgetTester tester) async {
      await pumpOnDevice(
        tester,
        const Column(
          children: <Widget>[
            AppModeDots(count: 3, index: 1),
            AppModeDots(count: 3, index: 0, tone: AppTone.photo),
            AppModeDots(count: 3, index: 2, tone: AppTone.night),
          ],
        ),
      );

      expect(tester.getSize(find.byType(AppModeDots).first), const Size(56, 8));
    });
  });

  group('controles', () {
    testWidgets('AppSwitch cambia de valor y se anuncia como interruptor', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      bool? changed;
      await pumpOnDevice(
        tester,
        AppSwitch(value: false, semanticLabel: 'Fotos de fondo', onChanged: (bool value) => changed = value),
      );

      expect(tester.getSize(find.byType(AppSwitch)), const Size(72, 48));
      expect(
        tester.getSemantics(find.byType(AppSwitch)),
        isSemantics(label: 'Fotos de fondo', isButton: true, isToggled: false),
      );
      await tester.tap(find.byType(AppSwitch));
      expect(changed, isTrue);
      semantics.dispose();
    });

    testWidgets('AppDayToggle y AppSavedChip cambian al tocarlos', (WidgetTester tester) async {
      bool? day;
      int chips = 0;
      await pumpOnDevice(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppDayToggle(label: 'Lun', semanticLabel: 'Lunes', selected: true, onChanged: (bool value) => day = value),
            const AppDayToggle(label: 'Mar', selected: false, onChanged: null),
            AppSavedChip(label: 'Huevo pasado', duration: '7 min', onTap: () => chips++),
            AppSavedChip(label: 'Pasta', duration: '10 min', selected: true, onTap: () => chips++),
          ],
        ),
      );

      await tester.tap(find.text('Lun'));
      await tester.tap(find.text('Pasta'));
      expect(day, isFalse);
      expect(chips, 1);
      expect(tester.getSize(find.byType(AppDayToggle).first), const Size(64, 64));
    });

    testWidgets('AppStepper sube, baja y desactiva el botón en el límite', (WidgetTester tester) async {
      int value = 0;
      await pumpOnDevice(
        tester,
        AppStepper(
          value: '20 %',
          decrementLabel: 'Bajar',
          incrementLabel: 'Subir',
          onDecrement: null,
          onIncrement: () => value++,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Subir'));
      await tester.tap(find.bySemanticsLabel('Bajar'));
      expect(value, 1);
      expect(find.text('20 %'), findsOneWidget);
    });

    testWidgets('AppWheelPicker cambia al arrastrar y con las acciones del lector', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int selected = 6;
      await pumpOnDevice(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => AppWheelPicker(
            values: <String>[for (int i = 0; i < 60; i++) i.toString().padLeft(2, '0')],
            selectedIndex: selected,
            semanticLabel: 'Minutos',
            onChanged: (int index) => setState(() => selected = index),
          ),
        ),
      );

      expect(tester.widget<Text>(find.text('06')).style!.fontSize, AppTypography.clockMedium.fontSize);
      await tester.drag(find.byType(AppWheelPicker), const Offset(0, -AppWheelPicker.itemExtent));
      await tester.pumpAndSettle();
      expect(selected, 7);

      tester.semantics.performAction(find.semantics.byLabel('Minutos'), SemanticsAction.decrease);
      await tester.pumpAndSettle();
      expect(selected, 6);
      semantics.dispose();
    });

    testWidgets('AppWheelPicker en bucle pasa del último al primero', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int selected = 2;
      await pumpOnDevice(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => AppWheelPicker(
            values: const <String>['0', '1', '2'],
            selectedIndex: selected,
            semanticLabel: 'Horas',
            loop: true,
            tone: AppTone.night,
            onChanged: (int index) => setState(() => selected = index),
          ),
        ),
      );

      tester.semantics.performAction(find.semantics.byLabel('Horas'), SemanticsAction.increase);
      await tester.pumpAndSettle();
      expect(selected, 0);
      semantics.dispose();
    });
  });

  group('filas y tarjetas', () {
    testWidgets('AppSettingsRow navega, muestra valor o interruptor, y avisa en ocre', (WidgetTester tester) async {
      int taps = 0;
      bool? photos;
      await pumpOnDevice(
        tester,
        SizedBox(
          width: 827,
          child: Column(
            children: <Widget>[
              AppSettingsRow(icon: AppIcons.moon, title: 'Horario de noche', subtitle: '22:30 a 6:45', onTap: () => taps++),
              AppSettingsRow(icon: AppIcons.languages, title: 'Idioma', value: 'Español', onTap: () => taps++),
              AppSettingsRow(
                icon: AppIcons.images,
                title: 'Fotos de fondo',
                switchValue: true,
                onSwitchChanged: (bool value) => photos = value,
              ),
              AppSettingsRow(
                icon: AppIcons.shieldAlert,
                title: 'Que Huawei no cierre Alba',
                subtitle: 'Pendiente',
                attention: true,
                onTap: () => taps++,
              ),
              AppSettingsField(label: 'Nombre', value: 'Trabajo', onTap: () => taps++),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Horario de noche'));
      await tester.tap(find.text('Español'));
      await tester.tap(find.text('Fotos de fondo'));
      await tester.tap(find.text('Trabajo'));
      expect(taps, 3);
      expect(photos, isFalse);
      expect(tester.getSize(find.byType(AppSettingsRow).first).height, 80);
      expect(backgroundOf(tester, find.byType(AppSettingsRow).last), AppThemeColors.light.bgWarningSubtle);
    });

    testWidgets('AppAlarmRow: la fila y el interruptor son controles distintos', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int opened = 0;
      bool? enabled;
      await pumpOnDevice(
        tester,
        SizedBox(
          width: 827,
          child: AppAlarmRow(
            time: '06:30',
            label: 'Trabajo',
            detail: 'Lun a vie',
            enabled: true,
            onTap: () => opened++,
            onEnabledChanged: (bool value) => enabled = value,
          ),
        ),
      );

      await tester.tap(find.text('06:30'));
      await tester.tap(find.byType(AppSwitch));
      expect(opened, 1);
      expect(enabled, isFalse);
      expect(find.bySemanticsLabel('06:30, Trabajo, Lun a vie'), findsOneWidget);
      expect(find.bySemanticsLabel('Trabajo'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('AppAlarmRow desactivada atenúa la hora', (WidgetTester tester) async {
      await pumpOnDevice(
        tester,
        SizedBox(
          width: 827,
          child: AppAlarmRow(
            time: '09:00',
            label: 'Fin de semana',
            detail: 'Sáb y dom',
            enabled: false,
            onTap: () {},
            onEnabledChanged: (bool value) {},
          ),
        ),
      );

      expect(tester.widget<Text>(find.text('09:00')).style!.color, AppThemeColors.light.textTertiary);
    });

    testWidgets('AppSoundTile en superficie y de noche, seleccionado o no', (WidgetTester tester) async {
      int taps = 0;
      await pumpOnDevice(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppSoundTile(icon: AppIcons.rain, name: 'Lluvia', detail: 'Reproduciendo', selected: true, onTap: () => taps++),
            AppSoundTile(icon: AppIcons.waves, name: 'Olas', detail: 'Mar en calma', onTap: () => taps++),
            AppSoundTile(icon: AppIcons.fan, name: 'Ventilador', detail: 'Zumbido', tone: AppTone.night, onTap: () => taps++),
            AppSoundTile(
              icon: AppIcons.noise,
              name: 'Ruido',
              detail: 'Reproduciendo',
              tone: AppTone.night,
              selected: true,
              onTap: () => taps++,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Olas'));
      expect(taps, 1);
      expect(tester.getSize(find.byType(AppSoundTile).first), const Size(196, 156));
      expect(backgroundOf(tester, find.byType(AppSoundTile).first), AppThemeColors.light.bgBrandSubtle);
      expect(backgroundOf(tester, find.byType(AppSoundTile).last), AppNightColors.bg);
    });

    const AppTimerCardLabels labels = AppTimerCardLabels(
      addMinute: '1 min',
      addMinuteSemantic: 'Añadir 1 minuto a Pasta',
      pauseSemantic: 'Pausar Pasta',
      resumeSemantic: 'Reanudar Pasta',
      dismissSemantic: 'Listo, Pasta',
      stopSemantic: 'Detener Pasta',
      undo: 'Deshacer',
      undoSemantic: 'Deshacer, Pasta',
    );

    testWidgets('AppTimerCard en marcha: pausa, +1 min y detener', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String> actions = <String>[];
      await pumpOnDevice(
        tester,
        AppTimerCard(
          name: 'Pasta',
          statusLabel: 'Quedan 8 min',
          remaining: '08:24',
          progress: 0.7,
          status: AppTimerStatus.running,
          labels: labels,
          onAddMinute: () => actions.add('add'),
          onToggle: () => actions.add('toggle'),
          onStop: () => actions.add('stop'),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Añadir 1 minuto a Pasta'));
      await tester.tap(find.bySemanticsLabel('Pausar Pasta'));
      await tester.tap(find.bySemanticsLabel('Detener Pasta'));
      expect(actions, <String>['add', 'toggle', 'stop']);
      expect(tester.getSize(find.byType(AppTimerCard)), const Size(264, 268));
      expect(tester.getSize(find.bySemanticsLabel('Detener Pasta')), const Size(48, 48));
      semantics.dispose();
    });

    testWidgets('AppTimerCard en pausa, terminado y detenido', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int undo = 0;
      await pumpOnDevice(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppTimerCard(
              name: 'Huevos',
              statusLabel: 'En pausa',
              remaining: '03:10',
              progress: 0.45,
              status: AppTimerStatus.paused,
              labels: labels,
              onToggle: () {},
            ),
            AppTimerCard(
              name: 'Arroz',
              statusLabel: 'Listo',
              remaining: '00:00',
              progress: 1,
              status: AppTimerStatus.finished,
              labels: labels,
              onToggle: () {},
            ),
            AppTimerCard(
              name: 'Pasta',
              statusLabel: 'Detenido',
              remaining: '06:12',
              progress: 0.3,
              status: AppTimerStatus.stopped,
              labels: labels,
              undoCountdown: '5 s',
              onUndo: () => undo++,
            ),
          ],
        ),
      );

      expect(find.bySemanticsLabel('Reanudar Pasta'), findsOneWidget);
      expect(find.bySemanticsLabel('Listo, Pasta'), findsOneWidget);
      expect(tester.widget<Text>(find.text('03:10')).style!.color, AppThemeColors.light.textTertiary);
      expect(tester.widget<Text>(find.text('00:00')).style!.color, AppThemeColors.light.textBrand);
      expect(find.text('5 s'), findsOneWidget);
      await tester.tap(find.text('Deshacer'));
      expect(undo, 1);
      semantics.dispose();
    });
  });

  group('avisos', () {
    for (final AppBannerVariant variant in AppBannerVariant.values) {
      testWidgets('AppAlertBanner ${variant.name}', (WidgetTester tester) async {
        int taps = 0;
        await pumpOnDevice(
          tester,
          SizedBox(
            width: 827,
            child: AppAlertBanner(
              icon: AppIcons.batteryLow,
              title: 'Batería baja · 18 %',
              message: 'Conecta el cargador.',
              actionLabel: 'Entendido',
              variant: variant,
              onAction: () => taps++,
            ),
          ),
          theme: variant == AppBannerVariant.night ? AppTheme.night : AppTheme.light,
        );

        await tester.tap(find.text('Entendido'));
        expect(taps, 1);
        expect(tester.getSize(find.byType(AppAlertBanner)).height, 96);
        final Rect banner = tester.getRect(find.byType(AppAlertBanner));
        final Rect button = tester.getRect(find.byType(AppButton));
        expect(banner.right - button.right, 12);
        expect(button.top - banner.top, 12);
      });
    }

    for (final AppFullScreenVariant variant in AppFullScreenVariant.values) {
      testWidgets('AppFullScreenAlert ${variant.name} ocupa la pantalla con dos acciones', (WidgetTester tester) async {
        final List<String> actions = <String>[];
        tester.view
          ..physicalSize = const Size(AppLayout.screenWidth, AppLayout.screenHeight)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: AppFullScreenAlert(
              icon: AppIcons.timer,
              title: 'Pasta lista',
              subtitle: 'Temporizador de 12 min',
              variant: variant,
              secondary: AppAlertAction(label: 'Añadir 1 min', icon: AppIcons.plus, onPressed: () => actions.add('add')),
              primary: AppAlertAction(label: 'Detener', icon: AppIcons.x, onPressed: () => actions.add('stop')),
            ),
          ),
        );

        await tester.tap(find.text('Añadir 1 min'));
        await tester.tap(find.text('Detener'));
        expect(actions, <String>['add', 'stop']);
        expect(tester.getSize(find.byType(AppFullScreenAlert)), const Size(891, 411));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('AppEmptyState con y sin acción', (WidgetTester tester) async {
      int taps = 0;
      await pumpOnDevice(
        tester,
        AppEmptyState(
          icon: AppIcons.folderOpen,
          title: 'La carpeta de fotos está vacía',
          message: 'Copia fotos por USB.',
          action: AppAlertAction(label: 'Cómo copiar fotos', icon: AppIcons.info, onPressed: () => taps++),
        ),
      );

      await tester.tap(find.text('Cómo copiar fotos'));
      expect(taps, 1);
      expect(tester.getSize(find.byType(AppEmptyState)).width, 600);
    });

    testWidgets('AppPhotoScrim es un degradado de 371 que no recibe toques', (WidgetTester tester) async {
      await pumpOnDevice(tester, const SizedBox(width: 891, height: 411, child: AppPhotoScrim()));

      expect(tester.getSize(find.descendant(of: find.byType(AppPhotoScrim), matching: find.byType(SizedBox))).height, 371);
      expect(find.descendant(of: find.byType(AppPhotoScrim), matching: find.byType(IgnorePointer)), findsOneWidget);
    });

    testWidgets('AppIcon es decorativo sin etiqueta y una imagen con ella', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpOnDevice(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(AppIcons.sun),
            AppIcon(AppIcons.moon, size: 48, semanticLabel: 'Noche'),
          ],
        ),
      );

      expect(find.bySemanticsLabel('Noche'), findsOneWidget);
      expect(tester.getSize(find.byType(AppIcon).last), const Size(48, 48));
      semantics.dispose();
    });
  });

  testWidgets('registerDesignSystemLicenses añade Inter y Lucide', (WidgetTester tester) async {
    registerDesignSystemLicenses();
    final List<LicenseEntry> entries = await tester.runAsync(() => LicenseRegistry.licenses.toList()) ?? <LicenseEntry>[];

    final Iterable<String> packages = entries.expand((LicenseEntry entry) => entry.packages);
    expect(packages, contains('design_system'));
  });
}
