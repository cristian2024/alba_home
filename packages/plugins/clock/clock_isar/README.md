# clock_isar

Adaptador Isar del reloj. La app lo elige dentro de `IsarStorage(features: <IsarFeature>[ClockIsar()])` y el plugin pide `NightScheduleRepository` sin saber que hay Isar.

Guarda el horario de noche en una sola fila; sin fila, da el de por defecto (22:30 a 6:45). Pasa `nightScheduleRepositoryContract` con Isar real (`setUpAll(initializeIsarForTests)`). El esquema se genera con `melos run gen`.
