/// Dobles de prueba y tests de contrato de `photo_frame_contract`.
library;

import 'dart:async';

import 'photo_frame_contract.dart';

export 'src/testing/current_photo_query_contract.dart';

/// [CurrentPhotoQuery] en memoria: el test fija la foto. Cumple
/// `currentPhotoQueryContract`.
class InMemoryCurrentPhotoQuery implements CurrentPhotoQuery {
  InMemoryCurrentPhotoQuery({CurrentPhoto? photo}) : _photo = photo;

  final StreamController<CurrentPhoto?> _changes = StreamController<CurrentPhoto?>.broadcast();
  CurrentPhoto? _photo;

  CurrentPhoto? get photo => _photo;

  set photo(CurrentPhoto? value) {
    _photo = value;
    _changes.add(value);
  }

  @override
  Stream<CurrentPhoto?> watchCurrentPhoto() {
    StreamSubscription<CurrentPhoto?>? subscription;
    late final StreamController<CurrentPhoto?> controller;
    controller = StreamController<CurrentPhoto?>(
      onListen: () {
        controller.add(_photo);
        subscription = _changes.stream.listen(controller.add, onDone: controller.close);
      },
      // No devuelve el futuro de cancel(): `first` lo esperaría y, con el
      // reloj simulado de testWidgets, no se completa.
      onCancel: () {
        unawaited(subscription?.cancel());
      },
    );
    return controller.stream;
  }

  /// Cierra el stream.
  Future<void> close() => _changes.close();
}
