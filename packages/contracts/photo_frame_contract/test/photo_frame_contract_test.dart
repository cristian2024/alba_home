import 'package:photo_frame_contract/photo_frame_contract.dart';
import 'package:photo_frame_contract/testing.dart';
import 'package:test/test.dart';

void main() {
  currentPhotoQueryContract(
    'InMemoryCurrentPhotoQuery',
    create: () async => InMemoryCurrentPhotoQuery(),
    setPhoto: (CurrentPhotoQuery query, CurrentPhoto? photo) async =>
        (query as InMemoryCurrentPhotoQuery).photo = photo,
    dispose: (CurrentPhotoQuery query) => (query as InMemoryCurrentPhotoQuery).close(),
  );

  test('InMemoryCurrentPhotoQuery empieza con lo que se le pasa', () async {
    const CurrentPhoto snow = CurrentPhoto(id: 'nieve', filePath: '/sdcard/Alba/nieve.jpg');
    final InMemoryCurrentPhotoQuery query = InMemoryCurrentPhotoQuery(photo: snow);

    expect(query.photo, snow);
    await query.close();
  });

  test('CurrentPhoto se compara por valor', () {
    const CurrentPhoto snow = CurrentPhoto(id: 'nieve', filePath: '/sdcard/Alba/nieve.jpg');

    expect(snow, const CurrentPhoto(id: 'nieve', filePath: '/sdcard/Alba/nieve.jpg'));
    expect(snow, isNot(const CurrentPhoto(id: 'mar', filePath: '/sdcard/Alba/nieve.jpg')));
    expect(snow.toString(), contains('nieve'));
  });
}
