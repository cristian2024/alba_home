import 'dart:developer' as developer;

import 'package:core_contracts/core_contracts.dart';
import 'package:core_di/core_di.dart';
import 'package:core_events/core_events.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';

import 'alba_composition.dart';

/// Lo que la app necesita tras arrancar.
class AlbaEnvironment {
  AlbaEnvironment({required this.locator, required this.localization, required this.plugins});

  final ServiceLocator locator;
  final LocalizationCoordinator localization;

  /// Plugins activados y listos, en su orden.
  final List<HomePlugin> plugins;

  /// Libera los plugins y lo que abrieron los adaptadores (la base de datos).
  Future<void> dispose() async {
    for (final HomePlugin plugin in plugins) {
      await plugin.dispose();
    }
    await locator.reset();
  }
}

/// Arranque:
/// 1. Idioma ([languageCode]) y servicios base: `EventBus`, `IdGenerator` y
///    `Clock`.
/// 2. Adaptadores ([adapters], por defecto [albaAdapters]): cada uno abre sus
///    recursos y registra sus contratos.
/// 3. Plugins ([plugins], por defecto [albaPlugins]) con su ciclo de vida:
///    se inicializan los activados y disponibles. Un plugin que falla no
///    impide arrancar a los demás.
Future<AlbaEnvironment> bootstrapAlba({
  required String languageCode,
  List<DependencyModule>? adapters,
  List<AlbaPluginFactory> plugins = albaPlugins,
  ServiceLocator? locator,
  LocalizationCoordinator? localization,
}) async {
  final ServiceLocator services = locator ?? ServiceLocator.instance;
  final LocalizationCoordinator l10n = localization ?? LocalizationCoordinator.instance;
  l10n.setLanguage(languageCode);
  services
    ..registerSingleton<EventBus>(EventBus(), dispose: (EventBus bus) => bus.dispose())
    ..registerSingleton<IdGenerator>(const UuidV4Generator())
    ..registerSingleton<Clock>(const SystemClock());
  for (final DependencyModule adapter in adapters ?? albaAdapters()) {
    await adapter.register(services);
  }

  final PluginRegistry registry = PluginRegistry();
  for (final AlbaPluginFactory create in plugins) {
    registry.register(create(services, l10n));
  }
  final List<PluginState> states = await PluginLifecycleManager(
    registry: registry,
    preferences: services.get<PluginPreferenceRepository>(),
    onError: (String pluginId, Object error, StackTrace stackTrace) =>
        developer.log('El plugin $pluginId falló', name: 'alba', error: error, stackTrace: stackTrace),
  ).load();
  return AlbaEnvironment(
    locator: services,
    localization: l10n,
    plugins: <HomePlugin>[
      for (final PluginState state in states)
        if (state.status == PluginStatus.ready) state.plugin,
    ],
  );
}
