import 'package:clock_domain/clock_domain.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:design_system/design_system.dart';

import '../../i18n/strings.g.dart';
import '../clock_routes.dart';
import 'clock_format.dart';

/// Lo que el reloj publica para sí mismo y para la app: el bloque «22:30 ·
/// Modo noche» mientras se acerca la noche (02.4a, 02.4b).
abstract final class ClockAmbient {
  static const String sourceId = 'clock';

  /// Detrás de la alarma (10): a la derecha si las dos se ven.
  static const int nightModePriority = 11;

  static List<AmbientStatus> statuses({required NightPhase phase, required WallClock wallClock}) {
    final DateTime? startsAt = phase.nightStartsAt;
    if (phase.stage != NightStage.dusk || startsAt == null) {
      return const <AmbientStatus>[];
    }
    final ClockTranslations$clock$nightMode$es nightModeStrings = clockStrings.clock.nightMode;
    final String time = ClockFormat.short(wallClock.toLocal(startsAt));
    return <AmbientStatus>[
      AmbientStatus(
        id: 'clock.nightMode',
        sourceId: sourceId,
        icon: AppIcons.moon.iconData,
        label: time,
        detail: nightModeStrings.status,
        semanticLabel: nightModeStrings.statusSemantic(time: time),
        priority: nightModePriority,
        route: ClockRoutes.nightSchedule,
      ),
    ];
  }
}
