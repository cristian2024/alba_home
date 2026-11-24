import 'dart:async';

import 'package:alba/src/ambient/ambient_host.dart';
import 'package:async/async.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:core_contracts/testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Plugin que publica los avisos de un [InMemoryAmbientAlertSource].
class _AlertPlugin extends HomePlugin implements AmbientAlertSource {
  _AlertPlugin(this.id, [List<AmbientAlert> initial = const <AmbientAlert>[]]) : source = InMemoryAmbientAlertSource(initial);

  @override
  final String id;
  final InMemoryAmbientAlertSource source;

  @override
  String get nameKey => id;
  @override
  String get descriptionKey => id;
  @override
  IconData get icon => const IconData(0xE000);
  @override
  String get version => '0.0.0';
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<void> initialize() async {}
  @override
  List<RouteBase> get routes => const <RouteBase>[];
  @override
  Future<void> dispose() => source.close();
  @override
  Stream<List<AmbientAlert>> watchAlerts() => source.watchAlerts();
  @override
  Future<void> onAction(String alertId, String actionId) => source.onAction(alertId, actionId);
}

/// Plugin sin avisos.
class _QuietPlugin extends _AlertPlugin {
  _QuietPlugin() : super('quiet');
}

AmbientAlert _alert(String source, String id, int priority, {String? route}) => AmbientAlert(
      id: id,
      sourceId: source,
      priority: priority,
      presentation: AmbientAlertPresentation.fullScreen,
      icon: const IconData(0xE000),
      title: id,
      route: route,
    );

void main() {
  test('junta los avisos de todos los plugins y gana el de menor prioridad', () async {
    final _AlertPlugin battery = _AlertPlugin('battery', <AmbientAlert>[_alert('battery', 'critical', 3)]);
    final _AlertPlugin alarm = _AlertPlugin('alarm');
    final StreamQueue<AmbientResolution> resolutions = StreamQueue<AmbientResolution>(
      AmbientHost(<HomePlugin>[battery, alarm]).watch(),
    );

    expect((await resolutions.next).fullScreen?.id, 'critical');
    expect((await resolutions.next).fullScreen?.id, 'critical');

    alarm.source.set(<AmbientAlert>[_alert('alarm', 'ringing', 1, route: '/alarm/ringing')]);
    final AmbientResolution both = await resolutions.next;
    expect(both.fullScreen?.id, 'ringing');
    expect(both.queuedFullScreen.single.id, 'critical');

    alarm.source.set(const <AmbientAlert>[]);
    expect((await resolutions.next).fullScreen?.id, 'critical');
    await resolutions.cancel();
  });

  test('pasa cada acción al plugin que publicó el aviso', () async {
    final _AlertPlugin alarm = _AlertPlugin('alarm');
    final AmbientHost host = AmbientHost(<HomePlugin>[_QuietPlugin(), alarm]);

    await host.onAction(_alert('alarm', 'ringing', 1), 'snooze');
    await host.onAction(_alert('nadie', 'x', 1), 'y');

    expect(alarm.source.actions, <(String, String)>[('ringing', 'snooze')]);
  });
}
