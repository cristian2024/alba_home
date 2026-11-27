import 'dart:async';

import 'package:async/async.dart';
import 'package:clock_contract/clock_contract.dart';
import 'package:clock_domain/clock_domain.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_frame_contract/photo_frame_contract.dart';
import 'package:plugin_clock/plugin_clock.dart';
import 'package:plugin_clock/src/presentation/clock/clock_cubit.dart';

import 'helpers/harness.dart';

const CurrentPhoto snow = CurrentPhoto(id: 'nieve', filePath: '/no/existe/nieve.jpg');

AmbientAlert batteryBanner() => AmbientAlert(
      id: 'battery.low',
      sourceId: 'battery',
      priority: 7,
      presentation: AmbientAlertPresentation.banner,
      urgency: AmbientUrgency.warning,
      icon: AppIcons.battery.iconData,
      title: 'Batería baja · 18 %',
      message: 'Conecta el cargador para que suene la alarma de las 6:30.',
      actions: const <AmbientAlertAction>[AmbientAlertAction(id: 'ok', label: 'Entendido', isPrimary: true)],
    );

ClockState stateOf(WidgetTester tester) => tester.element(find.byType(ClockScreenProbe)).read<ClockCubit>().state;

/// Para leer el cubit desde los tests.
typedef ClockScreenProbe = Scaffold;

AppClockTime clockTime(WidgetTester tester) => tester.widget<AppClockTime>(find.byType(AppClockTime));

void main() {
  late Harness harness;

  tearDown(() => harness.dispose());

  group('reloj (02.x)', () {
    testWidgets('de día con foto: fecha, hora, bloques y degradado (02.1)', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      harness.photos.photo = snow;
      harness.ambient.resolution = AmbientResolution(statuses: <AmbientStatus>[alarmStatus()]);
      await harness.pump(tester, ClockRoutes.base);

      expect(find.text('miércoles, 18 de noviembre'), findsOneWidget);
      expect(find.text('07:41'), findsOneWidget);
      expect(clockTime(tester).tone, AppTone.photo);
      expect(find.text('6:30'), findsOneWidget);
      expect(find.text('Alarma'), findsOneWidget);
      expect(tester.widget<AppPhotoScrim>(find.byType(AppPhotoScrim)).opacity, PhotoScrim.baseline);
      expect(find.bySemanticsLabel(RegExp('Son las 07:41')), findsOneWidget);
    });

    testWidgets('con una foto clara el degradado casi negro de Alba basta (02.8)', (WidgetTester tester) async {
      harness = Harness();
      harness.luminance.value = 1;
      await harness.start();
      harness.photos.photo = snow;
      await harness.pump(tester, ClockRoutes.base);
      await tester.pump();

      // #0B0A09 al 72 %: una foto blanca da 7,75:1 en el tramo sólido.
      expect(tester.widget<AppPhotoScrim>(find.byType(AppPhotoScrim)).opacity, PhotoScrim.baseline);

      harness.luminance.value = null;
      harness.photos.photo = const CurrentPhoto(id: 'otra', filePath: '/no/existe/otra.jpg');
      await tester.pump();
      await tester.pump();
      expect(tester.widget<AppPhotoScrim>(find.byType(AppPhotoScrim)).opacity, PhotoScrim.baseline);

      harness.photos.photo = null;
      await tester.pump();
      await tester.pump();
      expect(find.byType(AppPhotoScrim), findsNothing);
    });

    testWidgets('sin fotos ni feed: fondo liso y sin bloques (02.2)', (WidgetTester tester) async {
      harness = Harness();
      await harness.start(withPhotos: false, withAmbient: false);
      await harness.pump(tester, ClockRoutes.base);

      expect(clockTime(tester).tone, AppTone.surface);
      expect(find.byType(AppPhotoScrim), findsNothing);
      expect(find.byType(AppStatusBlock), findsNothing);
    });

    testWidgets('de noche: negro y ámbar, sin foto (02.3)', (WidgetTester tester) async {
      harness = Harness(now: local(23, 17));
      await harness.start();
      harness.photos.photo = snow;
      await harness.pump(tester, ClockRoutes.base);

      expect(find.text('23:17'), findsOneWidget);
      expect(clockTime(tester).tone, AppTone.night);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('al atardecer la foto se funde a negro (02.4b)', (WidgetTester tester) async {
      harness = Harness(now: local(22, 15));
      await harness.start();
      harness.photos.photo = snow;
      await harness.pump(tester, ClockRoutes.base);

      expect(clockTime(tester).tone, AppTone.photo);
      final ColoredBox veil = tester.widgetList<ColoredBox>(find.byType(ColoredBox)).last;
      expect(veil.color.a, closeTo(0.5, 0.01));
    });

    testWidgets('el banner que gana, con su acción (02.6)', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      harness.ambient.resolution = AmbientResolution(banner: batteryBanner(), statuses: <AmbientStatus>[alarmStatus()]);
      await harness.pump(tester, ClockRoutes.base);

      expect(find.text('Batería baja · 18 %'), findsOneWidget);
      await tester.tap(find.text('Entendido'));
      await tester.pump();
      expect(harness.ambient.actions, <(String, String)>[('battery.low', 'ok')]);
      expect(tester.widget<AppAlertBanner>(find.byType(AppAlertBanner)).variant, AppBannerVariant.warning);
    });

    testWidgets('tocar un bloque abre su pantalla', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      harness.ambient.resolution = AmbientResolution(statuses: <AmbientStatus>[alarmStatus()]);
      await harness.pump(tester, ClockRoutes.base);

      await tester.tap(find.text('6:30'));
      await tester.pumpAndSettle();
      expect(find.text('alarmas'), findsOneWidget);
    });

    testWidgets('mantener la hora 2 s abre ajustes; antes, la barra se llena (02.7)', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      await harness.pump(tester, ClockRoutes.base);

      final TestGesture gesture = await tester.startGesture(tester.getCenter(find.byType(AppClockTime)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('Sigue pulsando para abrir ajustes'), findsOneWidget);
      expect(find.text('miércoles, 18 de noviembre'), findsNothing);
      await tester.pump(const Duration(milliseconds: 900));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('ajustes'), findsOneWidget);
    });

    testWidgets('soltar a medias no abre nada; un toque corto muestra la pista (02.9)', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      harness.ambient.resolution = AmbientResolution(banner: batteryBanner());
      await harness.pump(tester, ClockRoutes.base);

      TestGesture gesture = await tester.startGesture(tester.getCenter(find.byType(AppClockTime)));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await tester.pump();
      expect(find.text('Sigue pulsando para abrir ajustes'), findsNothing);
      expect(find.text('Mantén pulsada la hora para abrir ajustes'), findsNothing);

      gesture = await tester.startGesture(tester.getCenter(find.byType(AppClockTime)));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pump();
      expect(find.text('Mantén pulsada la hora para abrir ajustes'), findsOneWidget);
      expect(find.text('Batería baja · 18 %'), findsNothing, reason: 'la pista tapa el banner');

      gesture = await tester.startGesture(tester.getCenter(find.byType(AppClockTime)));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Mantén pulsada la hora para abrir ajustes'), findsNothing);
      expect(find.text('inicio'), findsNothing);
    });

    testWidgets('con TalkBack, mantener pulsado abre ajustes al momento', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      await harness.pump(tester, ClockRoutes.base);

      tester.semantics.performAction(find.semantics.byLabel(RegExp('Son las')), SemanticsAction.longPress);
      await tester.pumpAndSettle();
      expect(find.text('ajustes'), findsOneWidget);
    });

    testWidgets('la hora avanza al minuto', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      await harness.pump(tester, ClockRoutes.base);

      harness.clock.advance(const Duration(seconds: 60));
      tester.element(find.byType(AppClockTime)).read<ClockCubit>().tickNow();
      await tester.pump();
      await tester.pump();
      expect(find.text('07:42'), findsOneWidget);
    });

    testWidgets('de noche, el banner y el halo van en negro y ámbar', (WidgetTester tester) async {
      harness = Harness(now: local(23, 17));
      await harness.start();
      harness.ambient.resolution = AmbientResolution(banner: batteryBanner());
      await harness.pump(tester, ClockRoutes.base);

      expect(tester.widget<AppAlertBanner>(find.byType(AppAlertBanner)).variant, AppBannerVariant.night);
      final TestGesture gesture = await tester.startGesture(tester.getCenter(find.byType(AppClockTime)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Sigue pulsando para abrir ajustes'), findsOneWidget);
      await gesture.up();
      await tester.pump();
    });

    testWidgets('sobre foto el banner es de foto; sin foto, según su urgencia', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      harness.photos.photo = snow;
      harness.ambient.resolution = AmbientResolution(banner: batteryBanner());
      await harness.pump(tester, ClockRoutes.base);
      expect(tester.widget<AppAlertBanner>(find.byType(AppAlertBanner)).variant, AppBannerVariant.photo);

      final TestGesture gesture = await tester.startGesture(tester.getCenter(find.byType(AppClockTime)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.up();
      await tester.pump();

      for (final (AmbientUrgency urgency, AppBannerVariant variant) in <(AmbientUrgency, AppBannerVariant)>[
        (AmbientUrgency.normal, AppBannerVariant.info),
        (AmbientUrgency.urgent, AppBannerVariant.critical),
      ]) {
        harness.photos.photo = null;
        harness.ambient.resolution = AmbientResolution(
          banner: AmbientAlert(
            id: 'x',
            sourceId: 'x',
            priority: 5,
            presentation: AmbientAlertPresentation.banner,
            urgency: urgency,
            icon: AppIcons.info.iconData,
            title: 'Aviso',
          ),
          statuses: <AmbientStatus>[
            AmbientStatus(
              id: 's',
              sourceId: 'x',
              icon: AppIcons.info.iconData,
              label: '1',
              semanticLabel: 'uno',
              priority: 1,
              urgency: urgency == AmbientUrgency.urgent ? AmbientUrgency.urgent : AmbientUrgency.warning,
            ),
          ],
        );
        await tester.pump();
        await tester.pump();
        expect(tester.widget<AppAlertBanner>(find.byType(AppAlertBanner)).variant, variant);
        expect(find.text('Aviso'), findsOneWidget);
      }
    });
  });

  group('horario de noche (08.2)', () {
    testWidgets('muestra el horario y guarda al girar', (WidgetTester tester) async {
      harness = Harness();
      await harness.start();
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(ClockRoutes.nightSchedule));
      await tester.pumpAndSettle();

      expect(find.text('Horario de noche'), findsOneWidget);
      expect(find.text('Empieza'), findsOneWidget);
      expect(find.text('Termina'), findsOneWidget);
      expect(find.textContaining('se funde a negro'), findsOneWidget);

      for (final String wheel in <String>['Horas de inicio', 'Minutos de inicio', 'Horas de fin', 'Minutos de fin']) {
        tester.semantics.performAction(find.semantics.byLabel(wheel), SemanticsAction.increase);
        await tester.pumpAndSettle();
      }
      expect(await harness.repository.get(), NightSchedule(start: LocalTime(23, 31), end: LocalTime(7, 46)));

      await tester.tap(find.bySemanticsLabel('Volver'));
      await tester.pumpAndSettle();
      expect(find.text('inicio'), findsOneWidget);
    });

    testWidgets('no deja que empiece y termine a la vez; sin pila, volver va al reloj', (WidgetTester tester) async {
      harness = Harness();
      await harness.repository.save(NightSchedule(start: LocalTime(6, 44), end: LocalTime(6, 45)));
      await harness.start();
      await harness.pump(tester, ClockRoutes.nightSchedule);

      tester.semantics.performAction(find.semantics.byLabel('Minutos de inicio'), SemanticsAction.increase);
      await tester.pumpAndSettle();
      expect(find.text('La noche no puede empezar y terminar a la misma hora.'), findsOneWidget);
      expect((await harness.repository.get()).start, LocalTime(6, 44));

      await tester.tap(find.bySemanticsLabel('Volver'));
      await tester.pumpAndSettle();
      expect(find.byType(AppClockTime), findsOneWidget);
    });
  });

  group('ClockPlugin', () {
    test('identidad y ruta de entrada', () async {
      harness = Harness();
      await harness.start();

      expect(harness.plugin.id, 'clock');
      expect(harness.plugin.nameKey, 'clock.name');
      expect(harness.plugin.descriptionKey, 'clock.description');
      expect(harness.plugin.icon, AppIcons.sun.iconData);
      expect(harness.plugin.version, '0.1.0');
      expect(harness.plugin.entryRoute, ClockRoutes.base);
      expect(await harness.plugin.isAvailable(), isTrue);
      expect(harness.plugin.routes, hasLength(2));
      expect(harness.locator.get<NightModeQuery>(), isA<NightModeQuery>());
      expect(harness.localization.translate('clock.name'), 'Reloj');
      expect(harness.localization.translate('clock.weekdays'), 'clock.weekdays', reason: 'una lista no es un texto');
      harness.localization.overrideTranslations('clock', 'es', <String, Object?>{
        'clock': <String, Object?>{'name': 'Hora'},
      });
      expect(harness.localization.translate('clock.name'), 'Hora');
    });

    test('publica «Modo noche» al atardecer y lo repite al cambiar de idioma', () async {
      harness = Harness(now: local(21, 50));
      await harness.start();
      final StreamQueue<List<AmbientStatus>> statuses = StreamQueue<List<AmbientStatus>>(harness.plugin.watchStatuses());
      expect(await statuses.next, isEmpty);

      harness.clock.advance(const Duration(minutes: 15));
      final NightModeQuery query = harness.locator.get<NightModeQuery>();
      expect((await query.watchPhase().first).stage, NightStage.day);
      await harness.repository.save(NightSchedule(start: LocalTime(22, 20), end: LocalTime(6, 45)));
      final List<AmbientStatus> dusk = await statuses.next;
      expect(dusk.single.label, '22:20');

      harness.localization.setLanguage('en');
      expect((await statuses.next).single.detail, 'Night mode');
      harness.localization.setLanguage('es');
      await statuses.cancel();
    });

    test('con refresco y tick periódicos se puede liberar', () async {
      harness = Harness();
      final ClockPlugin periodic = ClockPlugin(locator: harness.locator, settingsRoute: '/settings', localization: harness.localization);
      harness.locator.registerSingleton<NightScheduleRepository>(harness.repository);
      await periodic.initialize();
      await periodic.dispose();
      await periodic.dispose();
    });
  });
}
