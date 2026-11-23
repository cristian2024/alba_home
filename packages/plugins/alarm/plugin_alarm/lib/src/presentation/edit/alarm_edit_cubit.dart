import 'package:alarm_domain/alarm_domain.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../alarm_dependencies.dart';
import '../../domain/use_cases/alarm_use_cases.dart';
import '../common/alarm_format.dart';

/// Estado de la edición de una alarma (03.3).
class AlarmEditState extends Equatable {
  const AlarmEditState({required this.draft, required this.original, required this.isNew, this.loaded = true});

  /// Lo que se está editando.
  final AlarmDraft draft;

  /// Cómo estaba al abrir (para «¿Descartar los cambios?»).
  final AlarmDraft original;
  final bool isNew;
  final bool loaded;

  bool get isDirty => isNew || !_sameDraft(draft, original);

  AlarmEditState copyWith({AlarmDraft? draft}) =>
      AlarmEditState(draft: draft ?? this.draft, original: original, isNew: isNew, loaded: loaded);

  static bool _sameDraft(AlarmDraft a, AlarmDraft b) =>
      a.time == b.time &&
      a.label == b.label &&
      a.repeat.length == b.repeat.length &&
      a.repeat.containsAll(b.repeat) &&
      a.soundId == b.soundId &&
      a.rise == b.rise &&
      a.snooze == b.snooze &&
      a.maxSnoozes == b.maxSnoozes &&
      a.vibrate == b.vibrate;

  @override
  List<Object?> get props => <Object?>[
        draft.time,
        draft.label,
        draft.repeat.toList()..sort((Weekday a, Weekday b) => a.index.compareTo(b.index)),
        draft.soundId,
        draft.snooze,
        draft.maxSnoozes,
        isNew,
        loaded,
      ];
}

/// Edita una alarma existente ([alarmId]) o una nueva, que empieza a la hora
/// en punto siguiente.
class AlarmEditCubit extends Cubit<AlarmEditState> {
  AlarmEditCubit(this._dependencies, {String? alarmId})
      : _alarmId = alarmId,
        super(_initial(_dependencies, isNew: alarmId == null));

  final AlarmDependencies _dependencies;
  final String? _alarmId;

  static AlarmEditState _initial(AlarmDependencies dependencies, {required bool isNew}) {
    final DateTime local = dependencies.wallClock.toLocal(dependencies.clock.nowUtc());
    final AlarmDraft draft = AlarmDraft(time: AlarmTime((local.hour + 1) % 24, 0));
    return AlarmEditState(draft: draft, original: draft, isNew: isNew, loaded: isNew);
  }

  /// Carga la alarma a editar. Devuelve `false` si ya no existe.
  Future<bool> load() async {
    final String? id = _alarmId;
    if (id == null) {
      return true;
    }
    final Alarm? alarm = await _dependencies.repository.getAlarm(id);
    if (alarm == null) {
      return false;
    }
    final AlarmDraft draft = AlarmDraft.of(alarm);
    emit(AlarmEditState(draft: draft, original: draft, isNew: false));
    return true;
  }

  void setHour(int hour) => _update(time: AlarmTime(hour, state.draft.time.minute));

  void setMinute(int minute) => _update(time: AlarmTime(state.draft.time.hour, minute));

  void setLabel(String label) => _update(label: label);

  void setRepeat(Set<Weekday> repeat) => _update(repeat: repeat);

  void setSound(String soundId) => _update(soundId: soundId);

  void setSnooze({required Duration snooze, required int maxSnoozes}) =>
      _update(snooze: snooze, maxSnoozes: maxSnoozes);

  void _update({AlarmTime? time, String? label, Set<Weekday>? repeat, String? soundId, Duration? snooze, int? maxSnoozes}) {
    final AlarmDraft draft = state.draft;
    emit(
      state.copyWith(
        draft: AlarmDraft(
          time: time ?? draft.time,
          label: label ?? draft.label,
          repeat: repeat ?? draft.repeat,
          soundId: soundId ?? draft.soundId,
          rise: draft.rise,
          snooze: snooze ?? draft.snooze,
          maxSnoozes: maxSnoozes ?? draft.maxSnoozes,
          vibrate: draft.vibrate,
        ),
      ),
    );
  }

  /// Cuándo sonaría con lo editado, en UTC.
  DateTime nextRing() {
    final AlarmDraft draft = state.draft;
    final Alarm preview = Alarm(id: 'preview', time: draft.time, label: draft.label, soundId: draft.soundId, repeat: draft.repeat);
    return NextRing.after(preview, _dependencies.clock.nowUtc(), _dependencies.wallClock)!;
  }

  /// Cuánto falta para que suene con lo editado.
  Duration untilNextRing() => nextRing().difference(_dependencies.clock.nowUtc());

  /// Si con lo editado suena hoy (para «Solo hoy» o «Solo mañana»).
  bool ringsToday() => AlarmFormat.isToday(nextRing(), _dependencies.clock.nowUtc(), _dependencies.wallClock);

  Future<void> save() async {
    final String? id = _alarmId;
    if (id == null) {
      await _dependencies.createAlarm(state.draft);
    } else {
      await _dependencies.updateAlarm(id, state.draft);
    }
  }

  Future<void> delete() async {
    final String? id = _alarmId;
    if (id != null) {
      await _dependencies.deleteAlarm(id);
    }
  }
}
