import 'dart:async';

import 'package:core_contracts/core_contracts.dart';

/// Junta los avisos de los plugins que los publican ([AmbientAlertSource]) y
/// decide con [AmbientAlertResolver] cuál se ve.
class AmbientHost {
  AmbientHost(List<HomePlugin> plugins)
      : _sources = <String, AmbientAlertSource>{
          for (final HomePlugin plugin in plugins)
            if (plugin is AmbientAlertSource) plugin.id: plugin as AmbientAlertSource,
        };

  final Map<String, AmbientAlertSource> _sources;

  /// Emite lo que se ve cada vez que algún plugin cambia sus avisos. Los
  /// plugins emiten al suscribirse, así que la primera emisión llega enseguida.
  Stream<AmbientResolution> watch() {
    final Map<String, List<AmbientAlert>> alerts = <String, List<AmbientAlert>>{};
    final List<StreamSubscription<List<AmbientAlert>>> subscriptions = <StreamSubscription<List<AmbientAlert>>>[];
    late final StreamController<AmbientResolution> controller;
    controller = StreamController<AmbientResolution>(
      onListen: () {
        _sources.forEach((String id, AmbientAlertSource source) {
          subscriptions.add(source.watchAlerts().listen((List<AmbientAlert> current) {
            alerts[id] = current;
            controller.add(
              AmbientAlertResolver.resolve(
                alerts: <AmbientAlert>[for (final List<AmbientAlert> list in alerts.values) ...list],
              ),
            );
          }));
        });
      },
      // Sin esperar a las cancelaciones: con el reloj simulado de testWidgets
      // no terminan.
      onCancel: () {
        for (final StreamSubscription<List<AmbientAlert>> subscription in subscriptions) {
          unawaited(subscription.cancel());
        }
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }

  /// El usuario pulsó [actionId] en [alert]: se lo pasa al plugin que lo
  /// publicó.
  Future<void> onAction(AmbientAlert alert, String actionId) async =>
      _sources[alert.sourceId]?.onAction(alert.id, actionId);
}
