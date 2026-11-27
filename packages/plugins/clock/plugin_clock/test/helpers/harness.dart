import 'dart:async';

import 'package:clock_domain/clock_domain.dart';
import 'package:clock_domain/testing.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:core_di/core_di.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_frame_contract/photo_frame_contract.dart';
import 'package:photo_frame_contract/testing.dart';
import 'package:plugin_clock/plugin_clock.dart';

const WallClock bogota = FixedOffsetWallClock(Duration(hours: -5));

/// Hora local de Bogotá del 18 de noviembre de 2026 (o del día [day]).
DateTime local(int hour, int minute, {int day = 18}) => bogota.localToUtc(2026, 11, day, hour, minute);

/// [AmbientFeed] en memoria: el test fija lo que se ve y anota las acciones.
class FakeAmbientFeed implements AmbientFeed {
  final StreamController<AmbientResolution> _changes = StreamController<AmbientResolution>.broadcast();
  AmbientResolution _current = const AmbientResolution();
  final List<(String, String)> actions = <(String, String)>[];

  set resolution(AmbientResolution value) {
    _current = value;
    _changes.add(value);
  }

  @override
  Stream<AmbientResolution> watch() {
    late final StreamController<AmbientResolution> controller;
    StreamSubscription<AmbientResolution>? subscription;
    controller = StreamController<AmbientResolution>(
      onListen: () {
        controller.add(_current);
        subscription = _changes.stream.listen(controller.add);
      },
      onCancel: () {
        unawaited(subscription?.cancel());
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }

  @override
  Future<void> onAction(AmbientAlert alert, String actionId) async => actions.add((alert.id, actionId));

  Future<void> close() => _changes.close();
}

/// [PhotoLuminance] fija.
class FixedPhotoLuminance implements PhotoLuminance {
  FixedPhotoLuminance(this.value);

  double? value;

  @override
  Future<double?> of(String filePath) async => value;
}

/// El plugin con dobles en memoria, como lo compondría una app.
class Harness {
  Harness({DateTime? now}) : clock = FixedClock(now ?? local(7, 41));

  final ServiceLocator locator = ServiceLocator();
  final InMemoryNightScheduleRepository repository = InMemoryNightScheduleRepository();
  final FixedClock clock;
  final InMemoryCurrentPhotoQuery photos = InMemoryCurrentPhotoQuery();
  final FakeAmbientFeed ambient = FakeAmbientFeed();
  final FixedPhotoLuminance luminance = FixedPhotoLuminance(0.1);
  final LocalizationCoordinator localization = LocalizationCoordinator();
  late final ClockPlugin plugin = ClockPlugin(
    locator: locator,
    settingsRoute: '/settings',
    localization: localization,
    photoLuminance: luminance,
    refreshEvery: null,
    tick: null,
  );

  Future<void> start({bool withPhotos = true, bool withAmbient = true}) async {
    locator
      ..registerSingleton<NightScheduleRepository>(repository)
      ..registerSingleton<Clock>(clock)
      ..registerSingleton<WallClock>(bogota);
    if (withPhotos) {
      locator.registerSingleton<CurrentPhotoQuery>(photos);
    }
    if (withAmbient) {
      locator.registerSingleton<AmbientFeed>(ambient);
    }
    await plugin.initialize();
  }

  Future<void> dispose() async {
    await plugin.dispose();
    await locator.reset();
    await repository.close();
    await photos.close();
    await ambient.close();
  }

  /// Monta las rutas del plugin a 891 × 411, empezando en [location].
  Future<GoRouter> pump(WidgetTester tester, String location, {ThemeData? theme}) async {
    tester.view
      ..physicalSize = const Size(AppLayout.screenWidth, AppLayout.screenHeight)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final GoRouter router = GoRouter(
      initialLocation: location,
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (BuildContext context, GoRouterState state) => const Scaffold(body: Text('inicio'))),
        GoRoute(path: '/settings', builder: (BuildContext context, GoRouterState state) => const Scaffold(body: Text('ajustes'))),
        GoRoute(path: '/alarm', builder: (BuildContext context, GoRouterState state) => const Scaffold(body: Text('alarmas'))),
        ...plugin.routes,
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(debugShowCheckedModeBanner: false, theme: theme ?? AppTheme.light, routerConfig: router),
    );
    await tester.pump();
    await tester.pump();
    return router;
  }
}

/// El bloque de la próxima alarma, como lo publica la alarma.
AmbientStatus alarmStatus() => AmbientStatus(
      id: 'alarm.next',
      sourceId: 'alarm',
      icon: AppIcons.alarm.iconData,
      label: '6:30',
      detail: 'Alarma',
      semanticLabel: 'Próxima alarma a las 6:30',
      priority: 10,
      route: '/alarm',
    );
