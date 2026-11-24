import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Deja el sonido de una alarma en un archivo que el paquete `alarm` pueda
/// abrir cuando suene, con la app cerrada o tras reiniciar.
abstract interface class AlarmSoundFiles {
  /// Ruta del archivo para [asset], o `null` si no se pudo preparar. Con
  /// `null` el paquete `alarm` usa el tono de alarma del sistema: mejor otro
  /// sonido que una alarma muda.
  Future<String?> prepare(String asset);
}

/// [AlarmSoundFiles] que copia el asset a la carpeta de documentos de la app.
///
/// El paquete `alarm` solo abre como asset las rutas que empiezan por
/// `assets/`; la de un asset de otro paquete (`packages/<paquete>/…`) la busca
/// como archivo y, al no encontrarlo, suena en silencio. La copia evita ese
/// caso y sigue ahí tras reiniciar. Se reescribe solo si el asset cambió (p. ej.
/// con una versión nueva de la app).
class AppDocumentsSoundFiles implements AlarmSoundFiles {
  AppDocumentsSoundFiles({AssetBundle? bundle, Future<Directory> Function()? directory})
      : _bundle = bundle ?? rootBundle,
        _directory = directory ?? getApplicationDocumentsDirectory;

  /// Subcarpeta de los documentos de la app donde quedan las copias.
  static const String folder = 'alarm_sounds';

  final AssetBundle _bundle;
  final Future<Directory> Function() _directory;

  @override
  Future<String?> prepare(String asset) async {
    if (asset.isEmpty) {
      return null;
    }
    try {
      final ByteData data = await _bundle.load(asset);
      final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final Directory base = await _directory();
      final File file = File('${base.path}/$folder/${_fileName(asset)}');
      if (!await _sameContent(file, bytes)) {
        await file.parent.create(recursive: true);
        // Escribir aparte y renombrar: una alarma que esté sonando con la copia
        // anterior no lee un archivo a medias.
        final File temp = File('${file.path}.tmp');
        await temp.writeAsBytes(bytes, flush: true);
        await temp.rename(file.path);
      }
      return file.path;
    } on Object {
      return null;
    }
  }

  static Future<bool> _sameContent(File file, Uint8List bytes) async =>
      await file.exists() && await file.length() == bytes.length && listEquals(await file.readAsBytes(), bytes);

  /// `packages/plugin_alarm/assets/sounds/bell.wav` →
  /// `packages_plugin_alarm_assets_sounds_bell.wav`.
  static String _fileName(String asset) => asset.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}
