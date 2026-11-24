# alarm_isar

Adaptador Isar de la alarma. La app lo elige dentro de `IsarStorage(features: <IsarFeature>[AlarmIsar()])` y el plugin pide `AlarmRepository` sin saber que hay Isar.

Guarda las alarmas y la sesión (una sola fila) en transacciones. Pasa `alarmRepositoryContract` con Isar real (`setUpAll(initializeIsarForTests)`). Los esquemas se generan con `melos run gen`.
