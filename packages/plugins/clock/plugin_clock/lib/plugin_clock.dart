/// Plugin del reloj de Alba. Quien compone la app registra [ClockPlugin],
/// añade sus rutas y, si quiere bloques y banners, un [AmbientFeed].
library;

export 'src/ambient_feed.dart';
export 'src/clock_plugin.dart';
export 'src/presentation/clock/photo_luminance.dart' show DecodedPhotoLuminance, PhotoLuminance;
export 'src/presentation/clock_routes.dart';
