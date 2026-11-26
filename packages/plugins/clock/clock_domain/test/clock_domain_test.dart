import 'package:clock_domain/clock_domain.dart';
import 'package:clock_domain/testing.dart';
import 'package:test/test.dart';

const WallClock bogota = FixedOffsetWallClock(Duration(hours: -5));

/// Hora local de Bogotá del 18 de noviembre (o del día [day]) como instante UTC.
DateTime local(int hour, int minute, {int day = 18}) => bogota.localToUtc(2026, 11, day, hour, minute);

void main() {
  nightScheduleRepositoryContract(
    'InMemoryNightScheduleRepository',
    create: () async => InMemoryNightScheduleRepository(),
    dispose: (NightScheduleRepository repository) => (repository as InMemoryNightScheduleRepository).close(),
  );

  group('LocalTime', () {
    test('valida, se compara por valor y cuenta minutos del día', () {
      expect(() => LocalTime(24, 0), throwsArgumentError);
      expect(() => LocalTime(-1, 0), throwsArgumentError);
      expect(() => LocalTime(6, 60), throwsArgumentError);
      expect(() => LocalTime(6, -1), throwsArgumentError);
      expect(LocalTime(22, 30), LocalTime(22, 30));
      expect(LocalTime(22, 30).minutesOfDay, 1350);
      expect(LocalTime(6, 45).compareTo(LocalTime(22, 30)), lessThan(0));
      expect(LocalTime(6, 45).toString(), contains('45'));
    });
  });

  group('NightSchedule', () {
    test('por defecto de 22:30 a 6:45, cruzando la medianoche', () {
      final NightSchedule schedule = NightSchedule.standard();

      expect(schedule.start, LocalTime(22, 30));
      expect(schedule.end, LocalTime(6, 45));
      expect(schedule.crossesMidnight, isTrue);
      expect(NightSchedule(start: LocalTime(0, 30), end: LocalTime(6, 0)).crossesMidnight, isFalse);
      expect(schedule.toString(), contains('22'));
    });

    test('no puede empezar y terminar a la vez; copyWith cambia lo pedido', () {
      expect(() => NightSchedule(start: LocalTime(22, 0), end: LocalTime(22, 0)), throwsArgumentError);
      final NightSchedule schedule = NightSchedule.standard();

      expect(schedule.copyWith(), schedule);
      expect(schedule.copyWith(start: LocalTime(23, 0)).start, LocalTime(23, 0));
      expect(schedule.copyWith(end: LocalTime(7, 0)).end, LocalTime(7, 0));
    });
  });

  group('NightPhases.at', () {
    final NightSchedule schedule = NightSchedule.standard();

    NightPhase at(DateTime utc, [NightSchedule? other]) => NightPhases.at(utc, other ?? schedule, bogota);

    test('de día es día', () {
      expect(at(local(7, 41)), NightPhase.day);
      expect(at(local(21, 59)), NightPhase.day);
    });

    test('en los 30 min anteriores se funde: 22:00 empieza, 22:15 a mitad (02.4a, 02.4b)', () {
      expect(at(local(22, 0)), NightPhase(stage: NightStage.dusk, darkness: 0, nightStartsAt: local(22, 30)));
      final NightPhase half = at(local(22, 15));
      expect(half.stage, NightStage.dusk);
      expect(half.darkness, 0.5);
      expect(half.nightStartsAt, local(22, 30));
    });

    test('de 22:30 a 6:45 es de noche, también tras la medianoche (02.3)', () {
      expect(at(local(22, 30)), NightPhase.night);
      expect(at(local(23, 17)), NightPhase.night);
      expect(at(local(3, 0, day: 19)), NightPhase.night);
      expect(at(local(6, 44, day: 19)), NightPhase.night);
    });

    test('en los 15 min posteriores vuelve al día', () {
      expect(at(local(6, 45, day: 19)), const NightPhase(stage: NightStage.dawn, darkness: 1));
      expect(at(local(6, 54, day: 19)).darkness, closeTo(0.4, 1e-9));
      expect(at(local(7, 0, day: 19)), NightPhase.day);
    });

    test('una noche que no cruza la medianoche, con su atardecer el día antes', () {
      final NightSchedule early = NightSchedule(start: LocalTime(0, 15), end: LocalTime(5, 0));

      final NightPhase dusk = at(local(23, 50), early);
      expect(dusk.stage, NightStage.dusk);
      expect(dusk.nightStartsAt, local(0, 15, day: 19));
      expect(at(local(1, 0, day: 19), early), NightPhase.night);
      expect(at(local(5, 5, day: 19), early).stage, NightStage.dawn);
      expect(at(local(12, 0, day: 19), early), NightPhase.day);
    });

    test('acepta instantes en hora local', () {
      expect(at(local(23, 17).toLocal()), NightPhase.night);
    });
  });

  group('PhotoScrim', () {
    final double text = PhotoScrim.luminance(0xFC, 0xF9, 0xF4);
    final double scrim = PhotoScrim.luminance(0x1C, 0x19, 0x17);

    test('con una foto oscura o como la de nieve se queda en el 72 %', () {
      expect(PhotoScrim.opacityFor(photoLuminance: 0.05, scrimLuminance: scrim, textLuminance: text), 0.72);
      expect(PhotoScrim.opacityFor(photoLuminance: scrim, scrimLuminance: scrim, textLuminance: text), 0.72);
      expect(PhotoScrim.opacityFor(photoLuminance: 0.6, scrimLuminance: scrim, textLuminance: text), 0.72);
    });

    test('con una foto blanca sube lo justo para llegar a 7:1', () {
      final double opacity = PhotoScrim.opacityFor(photoLuminance: 1, scrimLuminance: scrim, textLuminance: text);
      final double background = PhotoScrim.fromSrgb(1 * (1 - opacity) + PhotoScrim.toSrgb(scrim) * opacity);

      expect(opacity, greaterThan(0.72));
      expect(opacity, lessThanOrEqualTo(1));
      expect(PhotoScrim.contrast(text, background), closeTo(7, 1e-9));
    });

    test('nunca pasa del 100 %', () {
      expect(PhotoScrim.opacityFor(photoLuminance: 1, scrimLuminance: 0.9, textLuminance: 1), 1);
    });

    test('luminancia de colores y media de píxeles', () {
      expect(PhotoScrim.luminance(0, 0, 0), 0);
      expect(PhotoScrim.luminance(255, 255, 255), closeTo(1, 1e-9));
      expect(PhotoScrim.luminance(5, 5, 5), closeTo(5 / 255 / 12.92, 1e-9));
      expect(PhotoScrim.averageLuminance(<int>[]), 0);
      expect(PhotoScrim.averageLuminance(<int>[0, 0, 0, 255, 255, 255, 255, 255]), closeTo(0.5, 1e-9));
      expect(PhotoScrim.contrast(1, 0), 21);
      expect(PhotoScrim.toSrgb(0.001), closeTo(0.01292, 1e-9));
      expect(PhotoScrim.fromSrgb(PhotoScrim.toSrgb(0.2)), closeTo(0.2, 1e-9));
    });
  });

  test('InMemoryNightScheduleRepository empieza con el horario que se le pasa', () async {
    final NightSchedule late = NightSchedule(start: LocalTime(23, 0), end: LocalTime(7, 0));
    final InMemoryNightScheduleRepository repository = InMemoryNightScheduleRepository(schedule: late);

    expect(await repository.get(), late);
    await repository.close();
  });
}
