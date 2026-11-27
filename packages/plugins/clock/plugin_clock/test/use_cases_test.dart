import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:async/async.dart';
import 'package:clock_contract/clock_contract.dart';
import 'package:clock_contract/testing.dart';
import 'package:clock_domain/clock_domain.dart';
import 'package:clock_domain/testing.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_clock/src/domain/night_mode_service.dart';
import 'package:plugin_clock/src/domain/night_schedule_use_cases.dart';
import 'package:plugin_clock/src/presentation/clock/photo_luminance.dart';
import 'package:plugin_clock/src/presentation/clock_routes.dart';
import 'package:plugin_clock/src/presentation/common/clock_ambient.dart';
import 'package:plugin_clock/src/presentation/common/clock_format.dart';
import 'package:core_contracts/core_contracts.dart';

import 'helpers/harness.dart';

void main() {
  group('NightModeService', () {
    late InMemoryNightScheduleRepository repository;
    late FixedClock clock;

    setUp(() {
      repository = InMemoryNightScheduleRepository();
      clock = FixedClock(local(21, 50));
    });
    tearDown(() => repository.close());

    NightModeService create() => NightModeService(repository: repository, clock: clock, wallClock: bogota);

    nightModeQueryContract(
      'NightModeService',
      create: () async {
        final FixedClock contractClock = FixedClock(local(12, 0));
        final NightModeService service =
            NightModeService(repository: InMemoryNightScheduleRepository(), clock: contractClock, wallClock: bogota);
        await service.start();
        _clocks[service] = contractClock;
        return service;
      },
      setPhase: (NightModeQuery query, NightPhase phase) async {
        final NightModeService service = query as NightModeService;
        final FixedClock contractClock = _clocks[service]!;
        final DateTime target = switch (phase.stage) {
          NightStage.day => local(12, 0),
          NightStage.dusk => phase.nightStartsAt!.subtract(NightSchedule.duskLength * (1 - phase.darkness)),
          NightStage.night => local(23, 0),
          NightStage.dawn => local(6, 45, day: 19).add(NightSchedule.dawnLength * (1 - phase.darkness)),
        };
        contractClock.advance(target.difference(contractClock.nowUtc()));
        service.refresh();
      },
      dispose: (NightModeQuery query) async => (query as NightModeService).dispose(),
    );

    test('empieza con la fase del horario guardado y la sigue con la hora', () async {
      final NightModeService service = create();
      await service.start();
      expect(service.current, NightPhase.day);
      expect(service.schedule, NightSchedule.standard());

      final StreamQueue<NightPhase> phases = StreamQueue<NightPhase>(service.watchPhase());
      expect(await phases.next, NightPhase.day);
      clock.advance(const Duration(minutes: 25));
      service.refresh();
      expect((await phases.next).stage, NightStage.dusk);
      service.refresh();
      clock.advance(const Duration(minutes: 30));
      service.refresh();
      expect(await phases.next, NightPhase.night);
      await phases.cancel();
      service.dispose();
      service.refresh();
    });

    test('un horario nuevo cambia la fase al momento', () async {
      final NightModeService service = create();
      await service.start();
      final StreamQueue<NightPhase> phases = StreamQueue<NightPhase>(service.watchPhase());
      expect(await phases.next, NightPhase.day);

      await repository.save(NightSchedule(start: LocalTime(21, 0), end: LocalTime(6, 0)));
      expect(await phases.next, NightPhase.night);
      expect(service.schedule.start, LocalTime(21, 0));
      await phases.cancel();
      service.dispose();
    });
  });

  group('SaveNightSchedule', () {
    test('guarda el horario y rechaza empezar y terminar a la vez', () async {
      final InMemoryNightScheduleRepository repository = InMemoryNightScheduleRepository();
      final SaveNightSchedule save = SaveNightSchedule(repository);

      expect(await save(start: LocalTime(23, 0), end: LocalTime(7, 0)), isTrue);
      expect(await repository.get(), NightSchedule(start: LocalTime(23, 0), end: LocalTime(7, 0)));
      expect(await save(start: LocalTime(5, 0), end: LocalTime(5, 0)), isFalse);
      expect((await repository.get()).start, LocalTime(23, 0));
      await repository.close();
    });
  });

  group('ClockFormat', () {
    test('hora del reloj, de bloque, fecha y horas sueltas', () {
      final DateTime morning = bogota.toLocal(local(7, 41));

      expect(ClockFormat.clock(morning), '07:41');
      expect(ClockFormat.short(morning), '7:41');
      expect(ClockFormat.date(morning), 'miércoles, 18 de noviembre');
      expect(ClockFormat.two(6), '06');
      expect(ClockFormat.localTime(LocalTime(22, 5)), '22:05');
    });
  });

  group('ClockAmbient', () {
    test('solo al atardecer publica «22:30 · Modo noche», detrás de la alarma', () {
      expect(ClockAmbient.statuses(phase: NightPhase.day, wallClock: bogota), isEmpty);
      expect(ClockAmbient.statuses(phase: NightPhase.night, wallClock: bogota), isEmpty);
      expect(
        ClockAmbient.statuses(phase: const NightPhase(stage: NightStage.dusk, darkness: 0.5), wallClock: bogota),
        isEmpty,
      );

      final List<AmbientStatus> statuses = ClockAmbient.statuses(
        phase: NightPhase(stage: NightStage.dusk, darkness: 0, nightStartsAt: local(22, 30)),
        wallClock: bogota,
      );
      final AmbientStatus status = statuses.single;
      expect(status.label, '22:30');
      expect(status.detail, 'Modo noche');
      expect(status.semanticLabel, 'El modo noche empieza a las 22:30');
      expect(status.priority, greaterThan(10));
      expect(status.route, ClockRoutes.nightSchedule);
    });
  });

  group('DecodedPhotoLuminance', () {
    Future<Uint8List> png(ui.Color top, ui.Color bottom) async {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
        ..drawRect(const ui.Rect.fromLTWH(0, 0, 64, 32), ui.Paint()..color = top)
        ..drawRect(const ui.Rect.fromLTWH(0, 32, 64, 32), ui.Paint()..color = bottom);
      final ui.Image image = await recorder.endRecording().toImage(64, 64);
      final ByteData data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      return data.buffer.asUint8List();
    }

    test('promedia la mitad inferior de la foto', () async {
      final double dark = await DecodedPhotoLuminance.fromBytes(await png(const ui.Color(0xFFFFFFFF), const ui.Color(0xFF000000)));
      final double light = await DecodedPhotoLuminance.fromBytes(await png(const ui.Color(0xFF000000), const ui.Color(0xFFFFFFFF)));

      expect(dark, closeTo(0, 0.01));
      expect(light, closeTo(1, 0.01));
    });

    test('sin archivo devuelve null', () async {
      expect(await const DecodedPhotoLuminance().of('/no/existe.jpg'), isNull);
    });
  });
}

final Map<NightModeService, FixedClock> _clocks = <NightModeService, FixedClock>{};
