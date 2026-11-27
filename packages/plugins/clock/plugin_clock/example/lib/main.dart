import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:clock_domain/clock_domain.dart';
import 'package:clock_domain/testing.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:core_di/core_di.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_frame_contract/photo_frame_contract.dart';
import 'package:photo_frame_contract/testing.dart';
import 'package:plugin_clock/plugin_clock.dart';

/// Ejemplo del plugin del reloj: horario, fotos y bloques en memoria. Los
/// botones del inicio llevan el reloj a la hora de cada pantalla de Penpot.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDesignSystemLicenses();
  final ExampleWorld world = ExampleWorld(photoPath: await _writeDuskPhoto());
  await world.start();
  runApp(ClockExampleApp(world: world));
}

/// Un atardecer generado (azul arriba, marrón abajo) para no depender de
/// archivos: se escribe en la carpeta temporal.
Future<String> _writeDuskPhoto() async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  const Rect area = Rect.fromLTWH(0, 0, 891, 411);
  ui.Canvas(recorder).drawRect(
    area,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF4A5E8C), Color(0xFF6B5A4E), Color(0xFF1E1B19)],
      ).createShader(area),
  );
  final ui.Image image = await recorder.endRecording().toImage(891, 411);
  final ByteData data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  final File file = File('${Directory.systemTemp.path}/alba_clock_example.png');
  await file.writeAsBytes(data.buffer.asUint8List());
  return file.path;
}

/// Reloj ajustable para saltar a cualquier hora.
class ExampleClock implements Clock {
  ExampleClock(this._now);

  DateTime _now;

  set now(DateTime value) => _now = value.toUtc();

  @override
  DateTime nowUtc() => _now;
}

/// [AmbientFeed] del ejemplo: la próxima alarma y, si se pide, un banner.
class ExampleAmbientFeed implements AmbientFeed {
  final StreamController<AmbientResolution> _changes = StreamController<AmbientResolution>.broadcast();
  AmbientResolution _current = AmbientResolution(statuses: <AmbientStatus>[_alarm]);

  static final AmbientStatus _alarm = AmbientStatus(
    id: 'alarm.next',
    sourceId: 'alarm',
    icon: AppIcons.alarm.iconData,
    label: '6:30',
    detail: 'Alarma',
    semanticLabel: 'Próxima alarma a las 6:30',
    priority: 10,
  );

  /// Pone o quita el banner de batería baja (02.6).
  set showBanner(bool show) {
    _current = AmbientResolution(
      statuses: <AmbientStatus>[_alarm],
      banner: show
          ? AmbientAlert(
              id: 'battery.low',
              sourceId: 'battery',
              priority: 7,
              presentation: AmbientAlertPresentation.banner,
              urgency: AmbientUrgency.warning,
              icon: AppIcons.battery.iconData,
              title: 'Batería baja · 18 %',
              message: 'Conecta el cargador para que suene la alarma de las 6:30.',
              actions: const <AmbientAlertAction>[AmbientAlertAction(id: 'ok', label: 'Entendido', isPrimary: true)],
            )
          : null,
    );
    _changes.add(_current);
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
  Future<void> onAction(AmbientAlert alert, String actionId) async => showBanner = false;
}

/// Todo lo que el ejemplo pone en memoria.
class ExampleWorld {
  ExampleWorld({required this.photoPath, Duration? refreshEvery = const Duration(seconds: 1)})
      : _refreshEvery = refreshEvery;

  final String photoPath;
  final Duration? _refreshEvery;
  final ServiceLocator locator = ServiceLocator.instance;
  final ExampleClock clock = ExampleClock(DateTime.now().toUtc());
  final InMemoryCurrentPhotoQuery photos = InMemoryCurrentPhotoQuery();
  final ExampleAmbientFeed ambient = ExampleAmbientFeed();
  late final ClockPlugin plugin = ClockPlugin(locator: locator, settingsRoute: '/', refreshEvery: _refreshEvery);

  Future<void> start() async {
    photos.photo = CurrentPhoto(id: 'atardecer', filePath: photoPath);
    locator
      ..registerSingleton<NightScheduleRepository>(InMemoryNightScheduleRepository())
      ..registerSingleton<Clock>(clock)
      ..registerSingleton<CurrentPhotoQuery>(photos)
      ..registerSingleton<AmbientFeed>(ambient);
    await plugin.initialize();
  }
}

class ClockExampleApp extends StatefulWidget {
  const ClockExampleApp({super.key, required this.world});

  final ExampleWorld world;

  @override
  State<ClockExampleApp> createState() => _ClockExampleAppState();
}

class _ClockExampleAppState extends State<ClockExampleApp> {
  late final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (BuildContext context, GoRouterState state) => _Controls(world: widget.world)),
      ...widget.world.plugin.routes,
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Reloj',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: LocalizationCoordinator.localizationsDelegates,
        supportedLocales: LocalizationCoordinator.supportedLocales,
        routerConfig: _router,
      );
}

/// Inicio del ejemplo: saltar a la hora de cada pantalla, con o sin foto y
/// con o sin banner.
class _Controls extends StatefulWidget {
  const _Controls({required this.world});

  final ExampleWorld world;

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  bool _photo = true;
  bool _banner = false;

  static const WallClock _wallClock = SystemWallClock();

  void _open(int hour, int minute) {
    final DateTime today = DateTime.now();
    widget.world.clock.now = _wallClock.localToUtc(today.year, today.month, today.day, hour, minute);
    context.push(ClockRoutes.base);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Wrap(
          spacing: AppSpacing.s400,
          runSpacing: AppSpacing.s400,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (final (String label, int hour, int minute) in <(String, int, int)>[
              ('7:41', 7, 41),
              ('22:00', 22, 0),
              ('22:15', 22, 15),
              ('23:17', 23, 17),
            ])
              AppButton(label: label, icon: AppIcons.sun, onPressed: () => _open(hour, minute)),
            AppButton(
              label: 'Horario de noche',
              icon: AppIcons.moon,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push(ClockRoutes.nightSchedule),
            ),
            AppSwitch(
              value: _photo,
              semanticLabel: 'Foto',
              onChanged: (bool value) {
                setState(() => _photo = value);
                widget.world.photos.photo = value ? CurrentPhoto(id: 'atardecer', filePath: widget.world.photoPath) : null;
              },
            ),
            AppSwitch(
              value: _banner,
              semanticLabel: 'Banner',
              onChanged: (bool value) {
                setState(() => _banner = value);
                widget.world.ambient.showBanner = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
