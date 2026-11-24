import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_di/core_di.dart';

import 'alarm_backend.dart';
import 'alarm_package_scheduler.dart';
import 'alarm_sound_files.dart';

/// Inicia el paquete `alarm` y registra [AlarmScheduler]. Quien compone la
/// app solo lo elige; nadie más ve el paquete `alarm`.
///
/// La app necesita en su `AndroidManifest.xml` los permisos de la guía de
/// Android de `alarm` (alarmas exactas, primer plano, pantalla completa,
/// arranque al encender, notificaciones).
class AlarmSchedulerModule implements DependencyModule {
  const AlarmSchedulerModule({AlarmBackend backend = const AlarmPackageBackend(), AlarmSoundFiles? soundFiles})
      : _backend = backend,
        _soundFiles = soundFiles;

  final AlarmBackend _backend;
  final AlarmSoundFiles? _soundFiles;

  @override
  Future<void> register(ServiceLocator services) async {
    await _backend.init();
    services.registerSingleton<AlarmScheduler>(
      AlarmPackageScheduler(backend: _backend, soundFiles: _soundFiles),
      dispose: (AlarmScheduler scheduler) => (scheduler as AlarmPackageScheduler).dispose(),
    );
  }
}
