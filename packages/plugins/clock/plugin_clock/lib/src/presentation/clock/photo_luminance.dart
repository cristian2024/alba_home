import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:clock_domain/clock_domain.dart';

/// La luminancia relativa (0 a 1) de la banda de la foto que queda detrás de
/// la hora, para calcular el degradado.
abstract interface class PhotoLuminance {
  /// `null` si no se pudo leer la foto.
  Future<double?> of(String filePath);
}

/// [PhotoLuminance] que decodifica la foto a 64 de ancho y promedia la mitad
/// inferior, que es donde van la hora y los bloques.
class DecodedPhotoLuminance implements PhotoLuminance {
  const DecodedPhotoLuminance();

  static const int sampleWidth = 64;

  @override
  Future<double?> of(String filePath) async {
    try {
      final Uint8List bytes = await File(filePath).readAsBytes();
      return await fromBytes(bytes);
    } on Object {
      return null;
    }
  }

  /// La luminancia de la mitad inferior de una imagen codificada (PNG, JPEG…).
  static Future<double> fromBytes(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: sampleWidth);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;
    final ByteData? data = await image.toByteData();
    final int width = image.width;
    final int height = image.height;
    image.dispose();
    codec.dispose();
    final Uint8List rgba = data!.buffer.asUint8List();
    final int from = (height ~/ 2) * width * 4;
    return PhotoScrim.averageLuminance(rgba.sublist(from));
  }
}
