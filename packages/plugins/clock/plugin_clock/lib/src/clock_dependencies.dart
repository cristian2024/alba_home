import 'package:clock_domain/clock_domain.dart';
import 'package:core_utils/core_utils.dart';
import 'package:photo_frame_contract/photo_frame_contract.dart';

import 'ambient_feed.dart';
import 'domain/night_mode_service.dart';
import 'domain/night_schedule_use_cases.dart';
import 'presentation/clock/photo_luminance.dart';

/// Todo lo que necesitan las pantallas del reloj. El plugin lo registra en su
/// scope de `core_di` durante `initialize()`.
class ClockDependencies {
  const ClockDependencies({
    required this.clock,
    required this.wallClock,
    required this.nightMode,
    required this.saveSchedule,
    required this.photoLuminance,
    this.photos,
    this.ambient,
  });

  final Clock clock;
  final WallClock wallClock;
  final NightModeService nightMode;
  final SaveNightSchedule saveSchedule;
  final PhotoLuminance photoLuminance;

  /// Las fotos, si la app compuso su plugin.
  final CurrentPhotoQuery? photos;

  /// Los bloques y avisos de los demás, si la app los da.
  final AmbientFeed? ambient;
}
