import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_utils/core_utils.dart';

import 'alarm_backend.dart';
import 'alarm_settings_mapper.dart';
import 'permission_gateway.dart';

/// [AlarmScheduler] sobre el paquete `alarm`: alarmas exactas con
/// `AlarmManager.setAlarmClock`, sonido en un servicio en primer plano,
/// notificación a pantalla completa y reprogramación al encender.
///
/// Pasa `alarmSchedulerContract`. La pantalla completa (Android 14 o
/// posterior) se da por concedida: `permission_handler` no la consulta.
class AlarmPackageScheduler implements AlarmScheduler {
  AlarmPackageScheduler({
    AlarmBackend backend = const AlarmPackageBackend(),
    PermissionGateway permissions = const PermissionHandlerGateway(),
    Clock clock = const SystemClock(),
  })  : _backend = backend,
        _permissions = permissions,
        _clock = clock {
    // Escucha desde el principio para conocer el orden en que empiezan a
    // sonar, aunque nadie más esté escuchando.
    _tracking = _backend.watchRinging().listen(_toRingingList);
  }

  late final StreamSubscription<Set<AlarmSettings>> _tracking;

  final AlarmBackend _backend;
  final PermissionGateway _permissions;
  final Clock _clock;

  /// Ids de `alarm` sonando, en el orden en que empezaron a sonar.
  final List<int> _ringOrder = <int>[];

  @override
  Future<void> schedule(ScheduledAlarm alarm) async {
    AlarmValidation.check(alarm, _clock.nowUtc());
    final bool accepted = await _backend.set(AlarmSettingsMapper.toSettings(alarm));
    if (!accepted) {
      throw StateError('Android no aceptó la alarma ${alarm.id}');
    }
  }

  @override
  Future<void> cancel(String id) => _backend.stop(AlarmSettingsMapper.intId(id));

  @override
  Future<void> stop(String id) async {
    final int intId = AlarmSettingsMapper.intId(id);
    final bool ringing = (await _ringingIds()).contains(intId);
    if (ringing) {
      await _backend.stop(intId);
    }
  }

  @override
  Future<List<ScheduledAlarm>> scheduled() async {
    final Set<int> ringing = await _ringingIds();
    final List<ScheduledAlarm> alarms = <ScheduledAlarm>[
      for (final AlarmSettings settings in await _backend.getAlarms())
        if (!ringing.contains(settings.id)) ?AlarmSettingsMapper.fromSettings(settings),
    ];
    return alarms..sort((ScheduledAlarm a, ScheduledAlarm b) => a.at.compareTo(b.at));
  }

  @override
  Stream<List<ScheduledAlarm>> watchRinging() => _backend.watchRinging().map(_toRingingList);

  @override
  Future<AlarmPermissions> permissions() async => AlarmPermissions(
        exactAlarms: await _permissions.exactAlarms(),
        notifications: await _permissions.notifications(),
        fullScreen: true,
      );

  @override
  Future<AlarmPermissions> requestPermissions() async {
    if (!await _permissions.exactAlarms()) {
      await _permissions.requestExactAlarms();
    }
    if (!await _permissions.notifications()) {
      await _permissions.requestNotifications();
    }
    return permissions();
  }

  /// Deja de seguir las alarmas que suenan.
  Future<void> dispose() => _tracking.cancel();

  Future<Set<int>> _ringingIds() async =>
      (await _backend.watchRinging().first).map((AlarmSettings settings) => settings.id).toSet();

  /// En el orden en que empezaron a sonar. Las que aparecen a la vez van por
  /// su hora programada.
  List<ScheduledAlarm> _toRingingList(Set<AlarmSettings> ringing) {
    final Map<int, AlarmSettings> byId = <int, AlarmSettings>{
      for (final AlarmSettings settings in ringing) settings.id: settings,
    };
    _ringOrder.removeWhere((int id) => !byId.containsKey(id));
    final List<AlarmSettings> started = byId.values.where((AlarmSettings s) => !_ringOrder.contains(s.id)).toList()
      ..sort((AlarmSettings a, AlarmSettings b) => a.dateTime.compareTo(b.dateTime));
    _ringOrder.addAll(started.map((AlarmSettings settings) => settings.id));
    return <ScheduledAlarm>[
      for (final int id in _ringOrder) ?AlarmSettingsMapper.fromSettings(byId[id]!),
    ];
  }
}
