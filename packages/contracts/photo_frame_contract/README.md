# photo_frame_contract

API pública de las fotos, en Dart puro.

- `CurrentPhotoQuery.watchCurrentPhoto()`: la foto que toca mostrar (`CurrentPhoto`, un archivo local), o `null` si no hay fotos. El reloj la pone de fondo durante el día.

`package:photo_frame_contract/testing.dart`: `currentPhotoQueryContract` e `InMemoryCurrentPhotoQuery`.
