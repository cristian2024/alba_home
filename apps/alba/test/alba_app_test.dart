import 'package:alarm_domain/alarm_domain.dart';
import 'package:alarm_domain/testing.dart';
import 'package:alba/src/alba_app.dart';
import 'package:alba/src/alba_bootstrap.dart';
import 'package:alba/src/alba_composition.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_alarm_scheduler/testing.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:core_contracts/testing.dart';
import 'package:core_di/core_di.dart';
import 'package:core_ui/core_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plugin_alarm/plugin_alarm.dart';

/// Los adaptadores en memoria, en lugar de Isar y del paquete `alarm`.
class _InMemoryAdapters implements DependencyModule {
  final InMemoryAlarmRepository repository = InMemoryAlarmRepository();
  final InMemoryAlarmScheduler scheduler = InMemoryAlarmScheduler();

  @override
  Future<void> register(ServiceLocator services) async => services
    ..registerSingleton<PluginPreferenceRepository>(InMemoryPluginPreferenceRepository())
    ..registerSingleton<AlarmRepository>(repository)
    ..registerSingleton<AlarmScheduler>(scheduler);
}

/// La alarma de verdad, sin el refresco periódico (en testWidgets queda un
/// temporizador pendiente).
HomePlugin _alarm(ServiceLocator locator, LocalizationCoordinator localization) =>
    AlarmPlugin(locator: locator, localization: localization, refreshEvery: null);

/// Un plugin que falla al iniciar no impide arrancar a los demás.
class _BrokenPlugin extends HomePlugin {
  @override
  String get id => 'broken';
  @override
  String get nameKey => id;
  @override
  String get descriptionKey => id;
  @override
  IconData get icon => AppIcons.x.iconData;
  @override
  String get version => '0.0.0';
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<void> initialize() => Future<void>.error(StateError('roto'));
  @override
  List<RouteBase> get routes => const <RouteBase>[];
  @override
  Future<void> dispose() async {}
}

void main() {
  late _InMemoryAdapters adapters;
  late AlbaEnvironment environment;

  Future<void> start(WidgetTester tester, {List<Alarm> alarms = const <Alarm>[]}) async {
    tester.view
      ..physicalSize = const Size(AppLayout.screenWidth, AppLayout.screenHeight)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    adapters = _InMemoryAdapters();
    for (final Alarm alarm in alarms) {
      await adapters.repository.saveAlarm(alarm);
    }
    environment = await bootstrapAlba(
      languageCode: 'es',
      adapters: <DependencyModule>[adapters],
      plugins: <AlbaPluginFactory>[_alarm, (ServiceLocator l, LocalizationCoordinator c) => _BrokenPlugin()],
      locator: ServiceLocator(),
      localization: LocalizationCoordinator(),
    );
    await tester.pumpWidget(AlbaApp(environment: environment));
    await tester.pumpAndSettle();
  }

  tearDown(() async {
    await environment.dispose();
    await adapters.repository.close();
    await adapters.scheduler.close();
  });

  testWidgets('arranca en la alarma, sin el plugin que falló', (WidgetTester tester) async {
    await start(tester);

    expect(environment.plugins.map((HomePlugin plugin) => plugin.id), <String>[AlarmPlugin.pluginId]);
    expect(find.text('No hay alarmas'), findsOneWidget);
  });

  testWidgets('cuando suena una alarma abre su pantalla, esté donde esté la app', (WidgetTester tester) async {
    final Alarm work = Alarm(id: 'work', time: AlarmTime(6, 30), label: 'Trabajo', soundId: 'sunrise');
    await start(tester, alarms: <Alarm>[work]);
    expect(find.text('Trabajo'), findsOneWidget);

    adapters.scheduler.fire(work.id);
    for (int i = 0; i < 5; i++) {
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Mantén para apagar'), findsOneWidget);
  });

  testWidgets('cambia de idioma con el coordinador', (WidgetTester tester) async {
    await start(tester);

    environment.localization.setLanguage('en');
    await tester.pumpAndSettle();

    expect(find.text('No alarms'), findsOneWidget);
  });
}
