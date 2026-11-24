import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm_scheduler_alarm/alarm_scheduler_alarm.dart';
import 'package:alarm_scheduler_alarm/src/alarm_backend.dart';
import 'package:alarm_scheduler_alarm/src/alarm_package_scheduler.dart';
import 'package:alarm_scheduler_alarm/src/alarm_settings_mapper.dart';
import 'package:alarm_scheduler_alarm/src/permission_gateway.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_alarm_scheduler/testing.dart';
import 'package:core_di/core_di.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// El paquete `alarm` simulado: programar sustituye por id (y deja de sonar),
/// parar quita de programadas y de sonando, y [ring] hace sonar una.
class _FakeBackend implements AlarmBackend {
  final Map<int, AlarmSettings> _alarms = <int, AlarmSettings>{};
  final Set<int> _ringing = <int>{};
  final StreamController<Set<AlarmSettings>> _changes = StreamController<Set<AlarmSettings>>.broadcast();
  bool initialized = false;
  bool accept = true;

  Set<AlarmSettings> get _ringingSet => <AlarmSettings>{for (final int id in _ringing) _alarms[id]!};

  void ring(int id) {
    _ringing.add(id);
    _changes.add(_ringingSet);
  }

  @override
  Future<void> init() async => initialized = true;

  @override
  Future<bool> set(AlarmSettings settings) async {
    if (!accept) {
      return false;
    }
    _alarms[settings.id] = settings;
    if (_ringing.remove(settings.id)) {
      _changes.add(_ringingSet);
    }
    return true;
  }

  @override
  Future<void> stop(int id) async {
    _alarms.remove(id);
    if (_ringing.remove(id)) {
      _changes.add(_ringingSet);
    }
  }

  @override
  Future<List<AlarmSettings>> getAlarms() async => _alarms.values.toList();

  @override
  Stream<Set<AlarmSettings>> watchRinging() {
    late final StreamController<Set<AlarmSettings>> controller;
    StreamSubscription<Set<AlarmSettings>>? subscription;
    controller = StreamController<Set<AlarmSettings>>(
      onListen: () {
        controller.add(_ringingSet);
        subscription = _changes.stream.listen(controller.add);
      },
      onCancel: () {
        unawaited(subscription?.cancel());
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }
}

class _FakePermissions implements PermissionGateway {
  bool exact = true;
  bool notify = true;
  bool grantOnRequest = true;
  int requests = 0;

  @override
  Future<bool> exactAlarms() async => exact;

  @override
  Future<bool> notifications() async => notify;

  @override
  Future<bool> requestExactAlarms() async {
    requests++;
    return exact = grantOnRequest;
  }

  @override
  Future<bool> requestNotifications() async {
    requests++;
    return notify = grantOnRequest;
  }
}

void main() {
  final Map<AlarmScheduler, _FakeBackend> backends = <AlarmScheduler, _FakeBackend>{};
  alarmSchedulerContract(
    'AlarmPackageScheduler',
    create: (Clock clock) {
      final _FakeBackend backend = _FakeBackend();
      final AlarmPackageScheduler scheduler =
          AlarmPackageScheduler(backend: backend, permissions: _FakePermissions(), clock: clock);
      backends[scheduler] = backend;
      return scheduler;
    },
    trigger: (AlarmScheduler scheduler, String id) async => backends[scheduler]!.ring(AlarmSettingsMapper.intId(id)),
    dispose: (AlarmScheduler scheduler) async {
      backends.remove(scheduler);
      await (scheduler as AlarmPackageScheduler).dispose();
    },
  );

  final DateTime at = DateTime.utc(2026, 11, 19, 11, 30);
  final ScheduledAlarm work = ScheduledAlarm(
    id: '6f1c9a52-6d0e-4b8e-9c55-0f8f4a1e2b31',
    at: at,
    title: 'Trabajo',
    body: 'Lun a vie',
    soundAsset: 'assets/sounds/sunrise.ogg',
    volume: 0.8,
    fadeIn: const Duration(minutes: 1),
    vibrate: false,
  );

  group('AlarmSettingsMapper', () {
    test('el id entero es estable, positivo y distinto para ids distintos', () {
      final int id = AlarmSettingsMapper.intId(work.id);

      expect(id, AlarmSettingsMapper.intId(work.id));
      expect(id, isPositive);
      expect(id, lessThanOrEqualTo(0x7FFFFFFF));
      expect(AlarmSettingsMapper.intId('otra'), isNot(id));
    });

    test('ida y vuelta conserva la alarma', () {
      final AlarmSettings settings = AlarmSettingsMapper.toSettings(work);

      expect(AlarmSettingsMapper.fromSettings(settings), work);
      expect(settings.allowAlarmOverlap, isTrue);
      expect(settings.allowSameSecondScheduling, isTrue);
      expect(settings.androidFullScreenIntent, isTrue);
      expect(settings.volumeSettings.fadeDuration, const Duration(minutes: 1));
      expect(settings.volumeSettings.volumeEnforced, isTrue);
    });

    test('sin subida usa volumen fijo; sin cuerpo, texto vacío', () {
      final ScheduledAlarm plain = ScheduledAlarm(id: 'a', at: at, title: 'Pasta', soundAsset: 's.ogg');
      final AlarmSettings settings = AlarmSettingsMapper.toSettings(plain);

      expect(settings.volumeSettings.fadeDuration, isNull);
      expect(settings.notificationSettings.body, '');
      expect(AlarmSettingsMapper.fromSettings(settings), plain);
    });

    test('ignora alarmas que no programó (sin payload o con otro formato)', () {
      final AlarmSettings foreign = AlarmSettingsMapper.toSettings(work);

      expect(AlarmSettingsMapper.fromSettings(_withPayload(foreign, null)), isNull);
      expect(AlarmSettingsMapper.fromSettings(_withPayload(foreign, '[1]')), isNull);
      expect(AlarmSettingsMapper.fromSettings(_withPayload(foreign, '{"x":1}')), isNull);
    });
  });

  group('AlarmPackageScheduler', () {
    test('si Android no acepta la alarma, lanza StateError', () async {
      final _FakeBackend backend = _FakeBackend()..accept = false;
      final AlarmPackageScheduler scheduler = AlarmPackageScheduler(
        backend: backend,
        permissions: _FakePermissions(),
        clock: FixedClock(at.subtract(const Duration(hours: 1))),
      );

      await expectLater(scheduler.schedule(work), throwsStateError);
    });

    test('permissions refleja lo concedido y requestPermissions pide solo lo que falta', () async {
      final _FakePermissions permissions = _FakePermissions()..exact = false;
      final AlarmPackageScheduler scheduler = AlarmPackageScheduler(backend: _FakeBackend(), permissions: permissions);

      expect((await scheduler.permissions()).canRing, isFalse);
      expect(await scheduler.requestPermissions(), AlarmPermissions.granted);
      expect(permissions.requests, 1);

      permissions
        ..exact = false
        ..notify = false
        ..grantOnRequest = false;
      final AlarmPermissions denied = await scheduler.requestPermissions();
      expect(denied.exactAlarms, isFalse);
      expect(denied.notifications, isFalse);
      expect(permissions.requests, 3);
    });
  });

  test('AlarmSchedulerModule inicia alarm y registra el AlarmScheduler', () async {
    final _FakeBackend backend = _FakeBackend();
    final ServiceLocator services = ServiceLocator();

    await AlarmSchedulerModule(backend: backend).register(services);

    expect(backend.initialized, isTrue);
    expect(services.get<AlarmScheduler>(), isA<AlarmPackageScheduler>());
    await services.reset();
  });
}

AlarmSettings _withPayload(AlarmSettings settings, String? payload) => AlarmSettings(
      id: settings.id,
      dateTime: settings.dateTime,
      volumeSettings: settings.volumeSettings,
      notificationSettings: settings.notificationSettings,
      payload: payload,
    );
