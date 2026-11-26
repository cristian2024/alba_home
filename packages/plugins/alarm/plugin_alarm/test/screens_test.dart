import 'dart:async';

import 'package:alarm_contract/alarm_contract.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plugin_alarm/plugin_alarm.dart';

import 'helpers/harness.dart';

void main() {
  late Harness harness;

  setUp(() => harness = Harness());
  tearDown(() => harness.dispose());

  group('lista (03.1, 03.2, 03.7)', () {
    testWidgets('vacía: invita a crear una', (WidgetTester tester) async {
      await harness.start();
      await harness.pump(tester, AlarmRoutes.base);

      expect(find.text('No hay alarmas'), findsOneWidget);
      expect(find.text('Nueva'), findsNothing, reason: 'vacía, la única acción es la del centro');
      expect(tester.getSize(find.widgetWithText(AppButton, 'Nueva alarma')).height, AppSizes.controlLarge);
      await tester.tap(find.text('Nueva alarma'));
      await tester.pumpAndSettle();
      expect(find.text('Nueva alarma'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('con alarmas: próxima, días, «suena en» y desactivada, como en 03.1', (WidgetTester tester) async {
      await harness.start(
        alarms: <Alarm>[
          alarm('work', 6, 30, label: 'Trabajo', repeat: Weekday.weekdays),
          alarm('weekend', 9, 0, label: 'Fin de semana', repeat: Weekday.weekend, enabled: false),
          alarm('nap', 16, 30, label: 'Fin de la siesta'),
        ],
      );
      await harness.pump(tester, AlarmRoutes.base);

      expect(find.text('Próxima: 6:30, en 7 h 13 min'), findsOneWidget);
      // 72 y no 48 como en Penpot: decisión del proyecto (ESTADO_desarrollo.md).
      expect(tester.getSize(find.widgetWithText(AppButton, 'Nueva')).height, AppSizes.controlLarge);
      expect(find.text('Lun a vie · suena en 7 h 13 min'), findsOneWidget);
      expect(find.text('Sáb y dom · desactivada'), findsOneWidget);
      expect(find.text('Solo mañana'), findsOneWidget);
      expect(find.text('06:30'), findsOneWidget);
    });

    testWidgets('el interruptor desactiva la alarma y tocar la fila la abre', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo', repeat: Weekday.weekdays)]);
      await harness.pump(tester, AlarmRoutes.base);

      await tester.tap(find.byType(AppSwitch));
      await tester.pumpAndSettle();
      expect((await harness.repository.getAlarm('work'))!.enabled, isFalse);
      expect(find.text('Lun a vie · desactivada'), findsOneWidget);

      await tester.tap(find.text('Trabajo'));
      await tester.pumpAndSettle();
      expect(find.text('Editar alarma'), findsOneWidget);
    });

    testWidgets('sin permiso: banner rojo, filas bloqueadas y «Activar» pide el permiso (03.7)', (WidgetTester tester) async {
      harness.scheduler
        ..currentPermissions = const AlarmPermissions(exactAlarms: false, notifications: true, fullScreen: true)
        ..permissionsAfterRequest = AlarmPermissions.granted;
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo', repeat: Weekday.weekdays)]);
      await harness.pump(tester, AlarmRoutes.base);

      expect(find.text('Las alarmas no sonarán'), findsOneWidget);
      expect(find.textContaining('Próxima'), findsNothing, reason: 'bloqueadas no suenan');
      expect(find.text('Lun a vie · bloqueada por Android'), findsOneWidget);
      expect(find.byType(AppSwitch), findsNothing);

      await tester.tap(find.text('Activar'));
      await tester.pumpAndSettle();
      expect(harness.scheduler.permissionRequests, 1);
      expect(find.text('Las alarmas no sonarán'), findsNothing);
    });

    testWidgets('volver solo aparece si hay a dónde volver', (WidgetTester tester) async {
      await harness.start();
      final GoRouter router = await harness.pump(tester, '/');
      expect(find.byType(AppIconButton), findsNothing);

      unawaited(router.push(AlarmRoutes.base));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Volver'));
      await tester.pumpAndSettle();
      expect(find.text('inicio'), findsOneWidget);
    });

    testWidgets('«suena en» se actualiza con el paso del tiempo', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo', repeat: Weekday.weekdays)]);
      await harness.pump(tester, AlarmRoutes.base);

      harness.clock.advance(const Duration(hours: 1));
      await tester.pump(const Duration(minutes: 1));
      expect(find.text('Lun a vie · suena en 6 h 13 min'), findsOneWidget);
    });
  });

  group('edición (03.3, 03.3b, 03.4)', () {
    testWidgets('crear: las ruedas fijan la hora y Guardar la programa', (WidgetTester tester) async {
      await harness.start();
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.create));
      await tester.pumpAndSettle();

      expect(find.text('Sonará en 43 min'), findsOneWidget);
      tester.semantics.performAction(find.semantics.byLabel('Horas'), SemanticsAction.increase);
      await tester.pumpAndSettle();
      expect(find.text('Sonará en 1 h 43 min'), findsOneWidget);

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      final List<Alarm> alarms = await harness.repository.getAlarms();
      expect(alarms.single.time, AlarmTime(1, 0));
      expect((await harness.scheduler.scheduled()).single.id, alarms.single.id);
      expect(find.text('inicio'), findsOneWidget);
    });

    testWidgets('editar: nombre, sonido y posposición desde sus diálogos', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo', repeat: Weekday.weekdays)]);
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.edit('work')));
      await tester.pumpAndSettle();

      expect(find.text('Amanecer suave · sube en 1 min'), findsOneWidget);
      expect(find.text('10 min · hasta 3 veces'), findsOneWidget);

      await tester.tap(find.text('Trabajo'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Gimnasio');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Gimnasio'), findsOneWidget);

      await tester.tap(find.text('Amanecer suave · sube en 1 min'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Campana'));
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      expect(find.text('Campana · sube en 1 min'), findsOneWidget);

      await tester.tap(find.text('10 min · hasta 3 veces'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Posponer +'));
      await tester.tap(find.bySemanticsLabel('hasta 3 veces −'));
      await tester.pump();
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      expect(find.text('15 min · hasta 2 veces'), findsOneWidget);

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      final Alarm saved = (await harness.repository.getAlarm('work'))!;
      expect(saved.label, 'Gimnasio');
      expect(saved.soundId, 'bell');
      expect(saved.snooze, const Duration(minutes: 15));
      expect(saved.maxSnoozes, 2);
    });

    testWidgets('repetir: días, atajos y frase de cuándo suena', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo')]);
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.edit('work')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Solo mañana'));
      await tester.pumpAndSettle();
      expect(find.text('Sin días marcados, suena una sola vez.'), findsOneWidget);

      await tester.tap(find.text('Entre semana'));
      await tester.pumpAndSettle();
      expect(find.text('Sonará de lunes a viernes a las 6:30.\nSin días marcados, suena una sola vez.'), findsOneWidget);
      await tester.tap(find.text('Vie'));
      await tester.tap(find.text('Sáb'));
      await tester.pumpAndSettle();
      expect(find.textContaining('lunes, martes, miércoles, jueves, sábado'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Listo'));
      await tester.pumpAndSettle();
      expect(find.text('Lun, Mar, Mié, Jue, Sáb'), findsOneWidget);
    });

    testWidgets('salir con cambios pregunta; «Seguir editando» se queda y «Descartar» sale', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo', repeat: Weekday.weekdays)]);
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.edit('work')));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('inicio'), findsOneWidget);

      unawaited(router.push(AlarmRoutes.edit('work')));
      await tester.pumpAndSettle();
      tester.semantics.performAction(find.semantics.byLabel('Minutos'), SemanticsAction.increase);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar los cambios?'), findsOneWidget);
      expect(find.text('La alarma seguirá como estaba: 6:30, de lunes a viernes.'), findsOneWidget);

      await tester.tap(find.text('Seguir editando'));
      await tester.pumpAndSettle();
      expect(find.text('Editar alarma'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Descartar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('inicio'), findsOneWidget);
      expect((await harness.repository.getAlarm('work'))!.time, AlarmTime(6, 30));
    });

    testWidgets('una alarma nueva siempre pregunta antes de descartar', (WidgetTester tester) async {
      await harness.start();
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.create));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('La alarma no se creará.'), findsOneWidget);
    });

    testWidgets('eliminar la borra y sale', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo')]);
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.edit('work')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar alarma'));
      await tester.pumpAndSettle();
      expect(await harness.repository.getAlarms(), isEmpty);
      expect(find.text('inicio'), findsOneWidget);
    });

    testWidgets('editar una alarma que ya no existe vuelve atrás', (WidgetTester tester) async {
      await harness.start();
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.edit('borrada')));
      await tester.pumpAndSettle();

      expect(find.text('inicio'), findsOneWidget);
    });
  });

  group('sonando y pospuesta (03.5, 03.5b, 03.6b)', () {
    /// Hace sonar la alarma. Dentro de testWidgets, `pumpEventQueue` no
    /// avanza con el reloj simulado: hay que bombear frames.
    Future<void> ring(WidgetTester tester) async {
      harness.scheduler.fire('work');
      for (int i = 0; i < 5; i++) {
        await tester.pump();
      }
    }

    testWidgets('muestra nombre, hora, posponer y cuántas quedan', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo', repeat: Weekday.everyDay)]);
      await ring(tester);
      await harness.pump(tester, AlarmRoutes.ringing);

      expect(find.text('Trabajo'), findsOneWidget);
      expect(find.text('23:30'), findsOneWidget);
      expect(find.text('Posponer 10 min'), findsOneWidget);
      expect(find.text('Toca en cualquier sitio para posponer · quedan 3'), findsOneWidget);
    });

    testWidgets('posponer cierra la pantalla y la alarma queda pospuesta', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo', repeat: Weekday.everyDay)]);
      await ring(tester);
      await harness.pump(tester, AlarmRoutes.ringing);

      await tester.tap(find.text('Posponer 10 min'));
      await tester.pumpAndSettle();

      expect((await harness.repository.getSession())!.isSnoozed, isTrue);
      expect(find.text('inicio'), findsOneWidget);
    });

    testWidgets('tocar en cualquier sitio también pospone', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo', repeat: Weekday.everyDay)]);
      await ring(tester);
      await harness.pump(tester, AlarmRoutes.ringing);

      await tester.tapAt(const Offset(40, 200));
      await tester.pumpAndSettle();

      expect((await harness.repository.getSession())!.isSnoozed, isTrue);
    });

    testWidgets('mantener 1 s apaga; soltar antes no', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo')]);
      await ring(tester);
      await harness.pump(tester, AlarmRoutes.ringing);
      final Finder hold = find.text('Mantén para apagar');

      TestGesture gesture = await tester.startGesture(tester.getCenter(hold));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Sigue pulsando…'), findsOneWidget);
      bool hintVisible() => tester
          .widget<Visibility>(
            find.ancestor(of: find.textContaining('Toca en cualquier sitio'), matching: find.byType(Visibility)),
          )
          .visible;
      expect(hintVisible(), isFalse, reason: 'la pista deja sitio a la barra (03.5b)');
      await gesture.up();
      await tester.pumpAndSettle();
      expect(hintVisible(), isTrue);
      final AlarmSession? afterRelease = await harness.repository.getSession();
      expect(afterRelease, isNotNull);
      expect(afterRelease!.isSnoozed, isFalse, reason: 'soltar antes no pospone');

      gesture = await tester.startGesture(tester.getCenter(find.text('Mantén para apagar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(await harness.repository.getSession(), isNull);
      expect((await harness.repository.getAlarm('work'))!.enabled, isFalse);
      expect(find.text('inicio'), findsOneWidget);
    });

    testWidgets('con TalkBack, mantener pulsado apaga al momento', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo')]);
      await ring(tester);
      await harness.pump(tester, AlarmRoutes.ringing);

      tester.semantics.performAction(
        find.semantics.byLabel('Apagar la alarma Trabajo. Mantén pulsado.'),
        SemanticsAction.longPress,
      );
      await tester.pumpAndSettle();

      expect(await harness.repository.getSession(), isNull);
    });

    testWidgets('sin posposiciones: sin botón de posponer y el toque no hace nada', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo').copyWith(maxSnoozes: 0)]);
      await ring(tester);
      await harness.pump(tester, AlarmRoutes.ringing);

      expect(find.text('Posponer 10 min'), findsNothing);
      expect(find.text('ya no se puede posponer'), findsOneWidget);
      await tester.tapAt(const Offset(40, 200));
      await tester.pumpAndSettle();
      expect((await harness.repository.getSession())!.isSnoozed, isFalse);
    });

    testWidgets('de noche va en negro y ámbar (03.5n)', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo')]);
      await ring(tester);
      await harness.pump(tester, AlarmRoutes.ringing, tone: AppTone.night);

      expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, AppNightColors.bg);
      expect(tester.widget<Text>(find.text('23:30')).style!.color, AppNightColors.textPrimary);
    });

    testWidgets('sin nada sonando, la pantalla se cierra sola', (WidgetTester tester) async {
      await harness.start();
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.ringing));
      await tester.pumpAndSettle();

      expect(find.text('inicio'), findsOneWidget);
    });

    testWidgets('pospuesta (03.6b): cuándo vuelve, «Seguir durmiendo» y «Apagar alarma»', (WidgetTester tester) async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo', repeat: Weekday.everyDay)]);
      await ring(tester);
      harness.clock.advance(const Duration(minutes: 13));
      await harness.plugin.onAction('alarm.ringing', 'snooze');
      await tester.pump();
      final GoRouter router = await harness.pump(tester, '/');

      unawaited(router.push(AlarmRoutes.snoozed));
      await tester.pumpAndSettle();
      expect(find.text('Vuelve a sonar a las 23:40'), findsOneWidget);
      expect(find.text('Trabajo · pospuesta 1 de 3 veces'), findsOneWidget);
      await tester.tap(find.text('Seguir durmiendo'));
      await tester.pumpAndSettle();
      expect(find.text('inicio'), findsOneWidget);

      unawaited(router.push(AlarmRoutes.snoozed));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar alarma'));
      await tester.pumpAndSettle();
      expect(await harness.repository.getSession(), isNull);
      expect(find.text('inicio'), findsOneWidget);
    });

    testWidgets('pospuesta sin sesión se cierra sola', (WidgetTester tester) async {
      await harness.start();
      final GoRouter router = await harness.pump(tester, '/');
      unawaited(router.push(AlarmRoutes.snoozed));
      await tester.pumpAndSettle();

      expect(find.text('inicio'), findsOneWidget);
    });
  });

  group('AlarmPlugin', () {
    test('identidad, icono y ruta de entrada', () async {
      expect(harness.plugin.id, 'alarm');
      expect(harness.plugin.nameKey, 'alarm.name');
      expect(harness.plugin.descriptionKey, 'alarm.description');
      expect(harness.plugin.icon, AppIcons.alarm.iconData);
      expect(harness.plugin.version, '0.1.2');
      expect(harness.plugin.entryRoute, AlarmRoutes.base);
      expect(await harness.plugin.isAvailable(), isTrue);
      expect(harness.plugin.routes, hasLength(5));
      expect(AlarmRoutes.edit('a b'), '/alarm/a%20b/edit');
    });

    test('registra NextAlarmQuery, programa al arrancar y traduce su nombre', () async {
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo')]);

      expect(harness.locator.get<NextAlarmQuery>(), isA<NextAlarmQuery>());
      expect((await harness.scheduler.scheduled()).single.title, 'Trabajo');
      expect(harness.localization.translate('alarm.name'), 'Alarma');
    });

    test('cápsulas: la próxima, la pospuesta y la bloqueada', () async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo', repeat: Weekday.everyDay)]);

      AmbientStatusLike next = AmbientStatusLike.of(await harness.plugin.watchStatuses().first);
      expect(next.label, '23:30');
      expect(next.detail, 'Alarma');
      expect(next.route, AlarmRoutes.base);

      harness.scheduler.fire('work');
      await pumpEventQueue();
      harness.clock.advance(const Duration(minutes: 13));
      await harness.plugin.onAction('alarm.ringing', 'snooze');
      await pumpEventQueue();
      next = AmbientStatusLike.of(await harness.plugin.watchStatuses().first);
      expect(next.label, '23:40');
      expect(next.detail, 'Pospuesta');
      expect(next.route, AlarmRoutes.snoozed);

      harness.scheduler.currentPermissions = const AlarmPermissions(exactAlarms: false, notifications: true, fullScreen: true);
      await (harness.locator.get<NextAlarmQuery>() as dynamic).refresh();
      await pumpEventQueue();
      next = AmbientStatusLike.of(await harness.plugin.watchStatuses().first);
      expect(next.detail, 'No sonará');
      expect(next.urgent, isTrue);
    });

    test('sin alarmas no publica cápsulas ni avisos', () async {
      await harness.start();

      expect(await harness.plugin.watchStatuses().first, isEmpty);
      expect(await harness.plugin.watchAlerts().first, isEmpty);
    });

    test('avisos: la alarma sonando a pantalla completa y sus acciones', () async {
      await harness.start(alarms: <Alarm>[alarm('work', 23, 30, label: 'Trabajo')]);
      harness.scheduler.fire('work');
      await pumpEventQueue();

      final List<Object> alerts = await harness.plugin.watchAlerts().first;
      expect(alerts, hasLength(1));
      final dynamic ringing = alerts.single;
      expect(ringing.id, 'alarm.ringing');
      expect(ringing.priority, 1);
      expect(ringing.title, 'Trabajo');
      expect((ringing.actions as List<dynamic>).map((dynamic a) => a.id), <String>['snooze', 'dismiss']);

      await harness.plugin.onAction('alarm.ringing', 'dismiss');
      await pumpEventQueue();
      expect(await harness.plugin.watchAlerts().first, isEmpty);
    });

    test('aviso de permiso: banner con «Activar», que pide el permiso', () async {
      harness.scheduler
        ..currentPermissions = const AlarmPermissions(exactAlarms: false, notifications: true, fullScreen: true)
        ..permissionsAfterRequest = AlarmPermissions.granted;
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo', repeat: Weekday.weekdays)]);

      final dynamic banner = (await harness.plugin.watchAlerts().first).single;
      expect(banner.id, 'alarm.blocked');
      expect(banner.title, 'La alarma de las 6:30 no sonará');

      await harness.plugin.onAction('alarm.blocked', 'activate');
      await pumpEventQueue();
      expect(await harness.plugin.watchAlerts().first, isEmpty);
      await harness.plugin.onAction('desconocido', 'nada');
    });

    test('al cambiar de idioma vuelve a publicar en el nuevo', () async {
      await harness.start(alarms: <Alarm>[alarm('work', 6, 30, label: 'Trabajo')]);

      harness.localization.setLanguage('en');
      await pumpEventQueue();
      expect(AmbientStatusLike.of(await harness.plugin.watchStatuses().first).detail, 'Alarm');
      harness.localization.setLanguage('es');
    });
  });
}

/// Lectura cómoda de la única cápsula publicada.
class AmbientStatusLike {
  AmbientStatusLike(this.label, this.detail, this.route, {required this.urgent});

  factory AmbientStatusLike.of(List<Object> statuses) {
    final dynamic status = statuses.single;
    return AmbientStatusLike(
      status.label as String,
      status.detail as String?,
      status.route as String?,
      urgent: status.urgency.toString().endsWith('urgent'),
    );
  }

  final String label;
  final String? detail;
  final String? route;
  final bool urgent;
}
