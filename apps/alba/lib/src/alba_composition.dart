import 'package:alarm_isar/alarm_isar.dart';
import 'package:alarm_scheduler_alarm/alarm_scheduler_alarm.dart';
import 'package:clock_isar/clock_isar.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:core_di/core_di.dart';
import 'package:core_ui/core_ui.dart';
import 'package:plugin_alarm/plugin_alarm.dart';
import 'package:plugin_clock/plugin_clock.dart';
import 'package:storage_isar/storage_isar.dart';

/// Crea un plugin con las dependencias de la app.
typedef AlbaPluginFactory = HomePlugin Function(ServiceLocator locator, LocalizationCoordinator localization);

/// Adaptadores que elige Alba. Es el único sitio que nombra tecnologías:
/// cambiar Isar o el paquete `alarm` es cambiar esta lista.
List<DependencyModule> albaAdapters() => const <DependencyModule>[
      // Isar exige todos los esquemas al abrir la base: van los de todos los
      // plugins, también los desactivados.
      IsarStorage(features: <IsarFeature>[ClockIsar(), AlarmIsar()]),
      AlarmSchedulerModule(),
    ];

/// Plugins de Alba, en el orden en que se registran. El primero con pantalla
/// propia es el inicio: el reloj.
const List<AlbaPluginFactory> albaPlugins = <AlbaPluginFactory>[_clock, _alarm];

/// Mantener la hora abre ajustes; mientras no existan (fase 5), la lista de
/// alarmas.
HomePlugin _clock(ServiceLocator locator, LocalizationCoordinator localization) =>
    ClockPlugin(locator: locator, localization: localization, settingsRoute: AlarmRoutes.base);

HomePlugin _alarm(ServiceLocator locator, LocalizationCoordinator localization) =>
    AlarmPlugin(locator: locator, localization: localization);
