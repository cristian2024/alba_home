import 'dart:async';

import 'package:clock_contract/clock_contract.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:plugin_clock/plugin_clock.dart';

/// Junta los bloques de estado ([AmbientStatusSource]) y los avisos
/// ([AmbientAlertSource]) de los plugins y decide con [AmbientAlertResolver]
/// qué se ve. De noche (según [NightModeQuery]) aplica las horas de silencio.
///
/// Es el [AmbientFeed] del reloj. Se crea antes que los plugins (el reloj lo
/// pide al iniciarse) y recibe los plugins listos con [attach].
class AmbientHost implements AmbientFeed {
  AmbientHost([List<HomePlugin> plugins = const <HomePlugin>[]]) {
    attach(plugins);
  }

  Map<String, AmbientAlertSource> _alertSources = <String, AmbientAlertSource>{};
  Map<String, AmbientStatusSource> _statusSources = <String, AmbientStatusSource>{};
  NightModeQuery? _nightMode;

  /// Los plugins listos y, si el reloj está, su fase de noche.
  void attach(List<HomePlugin> plugins, {NightModeQuery? nightMode}) {
    _alertSources = <String, AmbientAlertSource>{
      for (final HomePlugin plugin in plugins)
        if (plugin is AmbientAlertSource) plugin.id: plugin as AmbientAlertSource,
    };
    _statusSources = <String, AmbientStatusSource>{
      for (final HomePlugin plugin in plugins)
        if (plugin is AmbientStatusSource) plugin.id: plugin as AmbientStatusSource,
    };
    _nightMode = nightMode;
  }

  /// Emite lo que se ve cada vez que algún plugin cambia sus bloques o
  /// avisos, o cambia la noche. Los plugins emiten al suscribirse, así que la
  /// primera emisión llega enseguida.
  @override
  Stream<AmbientResolution> watch() {
    final Map<String, List<AmbientAlert>> alerts = <String, List<AmbientAlert>>{};
    final Map<String, List<AmbientStatus>> statuses = <String, List<AmbientStatus>>{};
    final List<StreamSubscription<Object?>> subscriptions = <StreamSubscription<Object?>>[];
    bool quietHours = false;
    late final StreamController<AmbientResolution> controller;
    void emit() => controller.add(
          AmbientAlertResolver.resolve(
            alerts: <AmbientAlert>[for (final List<AmbientAlert> list in alerts.values) ...list],
            statuses: <AmbientStatus>[for (final List<AmbientStatus> list in statuses.values) ...list],
            quietHours: quietHours,
          ),
        );
    controller = StreamController<AmbientResolution>(
      onListen: () {
        final NightModeQuery? nightMode = _nightMode;
        if (nightMode != null) {
          subscriptions.add(nightMode.watchPhase().listen((NightPhase phase) {
            if (phase.isNight != quietHours) {
              quietHours = phase.isNight;
              emit();
            }
          }));
        }
        _alertSources.forEach((String id, AmbientAlertSource source) {
          subscriptions.add(source.watchAlerts().listen((List<AmbientAlert> current) {
            alerts[id] = current;
            emit();
          }));
        });
        _statusSources.forEach((String id, AmbientStatusSource source) {
          subscriptions.add(source.watchStatuses().listen((List<AmbientStatus> current) {
            statuses[id] = current;
            emit();
          }));
        });
      },
      // Sin esperar a las cancelaciones: con el reloj simulado de testWidgets
      // no terminan.
      onCancel: () {
        for (final StreamSubscription<Object?> subscription in subscriptions) {
          unawaited(subscription.cancel());
        }
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }

  /// El usuario pulsó [actionId] en [alert]: se lo pasa al plugin que lo
  /// publicó.
  @override
  Future<void> onAction(AmbientAlert alert, String actionId) async =>
      _alertSources[alert.sourceId]?.onAction(alert.id, actionId);
}
