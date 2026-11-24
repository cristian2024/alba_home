import 'package:alarm_domain/alarm_domain.dart';
import 'package:alarm_domain/testing.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_alarm_scheduler/testing.dart';
import 'package:core_di/core_di.dart';
import 'package:core_ui/core_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plugin_alarm/plugin_alarm.dart';

/// Ejemplo del plugin de alarma: alarmas y almacenamiento en memoria, sin
/// Android. «Hacer sonar» dispara la próxima alarma programada para probar
/// las pantallas de alarma sonando y pospuesta.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDesignSystemLicenses();
  final ServiceLocator locator = ServiceLocator.instance;
  final InMemoryAlarmScheduler scheduler = InMemoryAlarmScheduler();
  locator
    ..registerSingleton<AlarmRepository>(InMemoryAlarmRepository())
    ..registerSingleton<AlarmScheduler>(scheduler);
  final AlarmPlugin plugin = AlarmPlugin(locator: locator);
  await plugin.initialize();
  runApp(AlarmExampleApp(plugin: plugin, scheduler: scheduler));
}

class AlarmExampleApp extends StatefulWidget {
  const AlarmExampleApp({super.key, required this.plugin, required this.scheduler});

  final AlarmPlugin plugin;
  final InMemoryAlarmScheduler scheduler;

  @override
  State<AlarmExampleApp> createState() => _AlarmExampleAppState();
}

class _AlarmExampleAppState extends State<AlarmExampleApp> {
  bool _night = false;

  late final GoRouter _router = GoRouter(
    initialLocation: AlarmRoutes.base,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => _Controls(
          night: _night,
          onNightChanged: (bool night) => setState(() => _night = night),
          onRing: _ring,
        ),
      ),
      ...widget.plugin.routes,
    ],
  );

  Future<void> _ring() async {
    final List<ScheduledAlarm> scheduled = await widget.scheduler.scheduled();
    if (scheduled.isEmpty) {
      return;
    }
    widget.scheduler.fire(scheduled.first.id);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _router.push(AlarmRoutes.ringing);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppToneScope(
      tone: _night ? AppTone.night : AppTone.surface,
      child: MaterialApp.router(
        title: 'Alarma',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: LocalizationCoordinator.localizationsDelegates,
        supportedLocales: LocalizationCoordinator.supportedLocales,
        routerConfig: _router,
      ),
    );
  }
}

/// Inicio del ejemplo: ir a la lista, hacer sonar la próxima y modo noche.
class _Controls extends StatelessWidget {
  const _Controls({required this.night, required this.onNightChanged, required this.onRing});

  final bool night;
  final ValueChanged<bool> onNightChanged;
  final VoidCallback onRing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Wrap(
          spacing: AppSpacing.s400,
          runSpacing: AppSpacing.s400,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            AppButton(label: 'Alarmas', icon: AppIcons.alarm, onPressed: () => context.push(AlarmRoutes.base)),
            AppButton(label: 'Hacer sonar', icon: AppIcons.bellRing, variant: AppButtonVariant.secondary, onPressed: onRing),
            AppSwitch(value: night, onChanged: onNightChanged, semanticLabel: 'Modo noche'),
          ],
        ),
      ),
    );
  }
}
