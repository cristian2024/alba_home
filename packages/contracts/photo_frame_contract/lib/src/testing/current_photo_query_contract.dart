import 'package:async/async.dart';
import 'package:test/test.dart';

import '../current_photo.dart';
import '../current_photo_query.dart';

/// Tests de contrato de [CurrentPhotoQuery]. Toda implementación debe
/// pasarlos.
///
/// - [create] devuelve una consulta sin fotos.
/// - [setPhoto] cambia la foto actual (`null`: ninguna).
/// - [dispose], si se da, la libera al terminar.
void currentPhotoQueryContract(
  String implementation, {
  required Future<CurrentPhotoQuery> Function() create,
  required Future<void> Function(CurrentPhotoQuery query, CurrentPhoto? photo) setPhoto,
  Future<void> Function(CurrentPhotoQuery query)? dispose,
}) {
  group('CurrentPhotoQuery ($implementation)', () {
    late CurrentPhotoQuery query;
    const CurrentPhoto snow = CurrentPhoto(id: 'nieve', filePath: '/sdcard/Alba/nieve.jpg');
    const CurrentPhoto sea = CurrentPhoto(id: 'mar', filePath: '/sdcard/Alba/mar.jpg');

    setUp(() async => query = await create());
    tearDown(() async => dispose?.call(query));

    test('sin fotos emite null', () async {
      expect(await query.watchCurrentPhoto().first, isNull);
    });

    test('emite cada foto nueva y null cuando ya no quedan', () async {
      final StreamQueue<CurrentPhoto?> photos = StreamQueue<CurrentPhoto?>(query.watchCurrentPhoto());
      expect(await photos.next, isNull);

      await setPhoto(query, snow);
      await expectLater(photos, emitsThrough(snow));
      await setPhoto(query, sea);
      await expectLater(photos, emitsThrough(sea));
      await setPhoto(query, null);
      await expectLater(photos, emitsThrough(isNull));
      await photos.cancel();
    });

    test('un suscriptor nuevo recibe la foto actual', () async {
      await setPhoto(query, snow);

      expect(await query.watchCurrentPhoto().first, snow);
    });
  });
}
