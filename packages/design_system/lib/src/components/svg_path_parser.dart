import 'dart:ui';

/// Convierte en [Path] los trazados de los iconos de Penpot: comandos
/// absolutos M, L, H, V, Q y Z, que es lo único que exporta. No es un parser
/// SVG general.
abstract final class SvgPathParser {
  static final Map<String, Path> _cache = <String, Path>{};
  static final RegExp _token = RegExp(r'[MLHVQZ]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');

  /// [parse] con caché: cada icono se convierte una sola vez.
  static Path parseCached(String data) => _cache.putIfAbsent(data, () => parse(data));

  /// Lanza [FormatException] con un comando que no conoce.
  static Path parse(String data) {
    final Path path = Path();
    final List<String> tokens = <String>[for (final RegExpMatch match in _token.allMatches(data)) match.group(0)!];
    final Set<String> known = <String>{'M', 'L', 'H', 'V', 'Q', 'Z'};
    final RegExp unknown = RegExp(r'[A-DF-Za-df-z]');
    final Match? unknownCommand = unknown.allMatches(data).where((Match m) => !known.contains(m.group(0))).firstOrNull;
    if (unknownCommand != null) {
      throw FormatException('Comando de trazado no admitido: ${unknownCommand.group(0)}', data);
    }
    int index = 0;
    String command = 'M';
    double x = 0;
    double y = 0;
    double next() => double.parse(tokens[index++]);
    while (index < tokens.length) {
      final String token = tokens[index];
      if (known.contains(token)) {
        command = token;
        index++;
        if (command == 'Z') {
          path.close();
          continue;
        }
      }
      switch (command) {
        case 'M':
          x = next();
          y = next();
          path.moveTo(x, y);
          command = 'L';
        case 'L':
          x = next();
          y = next();
          path.lineTo(x, y);
        case 'H':
          x = next();
          path.lineTo(x, y);
        case 'V':
          y = next();
          path.lineTo(x, y);
        case 'Q':
          final double controlX = next();
          final double controlY = next();
          x = next();
          y = next();
          path.quadraticBezierTo(controlX, controlY, x, y);
        default:
          index++;
      }
    }
    return path;
  }
}
