import 'dart:io';

import 'src/token_generator.dart';

/// Regenera `lib/src/tokens/` desde `design/referencia_penpot/`.
///
/// ```sh
/// cd packages/design_system && dart run tool/generate_tokens.dart
/// ```
void main() {
  const String source = '../../design/referencia_penpot';
  final Map<String, String> files = generateTokens(
    tokensJson: File('$source/tokens.json').readAsStringSync(),
    specJson: File('$source/spec.json').readAsStringSync(),
  );
  for (final MapEntry<String, String> file in files.entries) {
    File('lib/src/tokens/${file.key}').writeAsStringSync(file.value);
    stdout.writeln('lib/src/tokens/${file.key}');
  }
}
