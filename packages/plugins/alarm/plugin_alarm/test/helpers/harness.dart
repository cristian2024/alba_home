import 'package:alarm_domain/alarm_domain.dart';
import 'package:alarm_domain/testing.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_alarm_scheduler/testing.dart';
import 'package:core_di/core_di.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/testing.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plugin_alarm/plugin_alarm.dart';

const WallClock bogota = FixedOffsetWallClock(Duration(hours: -5));

/// Miércoles 18 de noviembre de 2026, 23:17 en Bogotá.
final DateTime t0 = bogota.localToUtc(2026, 11, 18, 23, 17);

class SequenceIds implements IdGenerator {
  int _next = 1;

  @override
  String newId() => 'alarm-${_next++}';
}

/// El plugin con dobles en memoria, como lo compondría una app.
class Harness {
  final ServiceLocator locator = ServiceLocator();
  final InMemoryAlarmRepository repository = InMemoryAlarmRepository();
  final FixedClock clock = FixedClock(t0);
  late final InMemoryAlarmScheduler scheduler = InMemoryAlarmScheduler(clock: clock);
  final RecordingEventBus events = RecordingEventBus();
  final LocalizationCoordinator localization = LocalizationCoordinator();
  late final AlarmPlugin plugin = AlarmPlugin(locator: locator, localization: localization, refreshEvery: null);

  Future<void> start({List<Alarm> alarms = const <Alarm>[]}) async {
    for (final Alarm alarm in alarms) {
      await repository.saveAlarm(alarm);
    }
    locator
      ..registerSingleton<AlarmRepository>(repository)
      ..registerSingleton<AlarmScheduler>(scheduler)
      ..registerSingleton<Clock>(clock)
      ..registerSingleton<IdGenerator>(SequenceIds())
      ..registerSingleton<WallClock>(bogota)
      ..registerSingleton<EventBus>(events);
    await plugin.initialize();
  }

  Future<void> dispose() async {
    await plugin.dispose();
    await locator.reset();
    await repository.close();
    await scheduler.close();
  }

  /// Monta las rutas del plugin a 891 × 411, empezando en [location].
  Future<GoRouter> pump(WidgetTester tester, String location, {AppTone tone = AppTone.surface}) async {
    tester.view
      ..physicalSize = const Size(AppLayout.screenWidth, AppLayout.screenHeight)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final GoRouter router = GoRouter(
      initialLocation: location,
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (BuildContext context, GoRouterState state) => const Scaffold(body: Text('inicio'))),
        ...plugin.routes,
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      AppToneScope(
        tone: tone,
        child: MaterialApp.router(
          theme: tone == AppTone.night ? AppTheme.night : AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }
}

Alarm alarm(String id, int hour, int minute, {String label = '', Set<Weekday> repeat = const <Weekday>{}, bool enabled = true}) =>
    Alarm(id: id, time: AlarmTime(hour, minute), label: label, soundId: 'sunrise', repeat: repeat, enabled: enabled);
