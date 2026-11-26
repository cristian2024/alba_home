import 'dart:async';

import 'package:alarm_domain/alarm_domain.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/alarm_sound.dart';
import '../../domain/use_cases/alarm_use_cases.dart';
import '../../i18n/strings.g.dart';
import '../common/alarm_format.dart';
import '../common/alarm_header.dart';
import 'alarm_edit_cubit.dart';
import 'alarm_edit_dialogs.dart';
import 'repeat_screen.dart';

/// Editar o crear una alarma (03.3): ruedas de hora y minutos a la izquierda,
/// campos a la derecha. Salir con cambios pregunta antes (03.3b).
class AlarmEditScreen extends StatelessWidget {
  const AlarmEditScreen({super.key, required this.wallClock, required this.onDone});

  final WallClock wallClock;

  /// Al guardar, borrar o descartar.
  final VoidCallback onDone;

  static final List<String> _hours = <String>[for (int h = 0; h < 24; h++) h.toString().padLeft(2, '0')];
  static final List<String> _minutes = <String>[for (int m = 0; m < 60; m++) m.toString().padLeft(2, '0')];

  Future<void> _close(BuildContext context) async {
    final AlarmEditCubit cubit = context.read<AlarmEditCubit>();
    if (!cubit.state.isDirty || await _confirmDiscard(context, cubit.state)) {
      onDone();
    }
  }

  Future<bool> _confirmDiscard(BuildContext context, AlarmEditState state) async {
    final AlarmTranslations$alarm$discard$es discardStrings = alarmStrings.alarm.discard;
    final AlarmDraft original = state.original;
    final bool? discard = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (BuildContext context) => Scaffold(
          body: AppFullScreenAlert(
            icon: AppIcons.pencil,
            title: discardStrings.title,
            subtitle: state.isNew
                ? discardStrings.bodyNew
                : discardStrings.body(
                    time: AlarmFormat.timeOf(original.time),
                    repeat: AlarmFormat.repeatLong(original.repeat),
                  ),
            secondary: AppAlertAction(
              label: discardStrings.discard,
              icon: AppIcons.x,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            primary: AppAlertAction(
              label: discardStrings.keep,
              icon: AppIcons.pencil,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
      ),
    );
    return discard ?? false;
  }

  Future<void> _save(BuildContext context) async {
    await context.read<AlarmEditCubit>().save();
    onDone();
  }

  Future<void> _delete(BuildContext context) async {
    await context.read<AlarmEditCubit>().delete();
    onDone();
  }

  Future<void> _editRepeat(BuildContext context, AlarmEditState state) async {
    final AlarmEditCubit cubit = context.read<AlarmEditCubit>();
    final Set<Weekday>? days = await Navigator.of(context).push<Set<Weekday>>(
      MaterialPageRoute<Set<Weekday>>(
        builder: (BuildContext context) => RepeatScreen(initial: state.draft.repeat, time: state.draft.time),
      ),
    );
    if (days != null) {
      cubit.setRepeat(days);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    final AlarmTranslations$alarm$edit$es editStrings = strings.edit;
    final AppThemeColors theme = AppThemeColors.of(context);
    return BlocBuilder<AlarmEditCubit, AlarmEditState>(
      builder: (BuildContext context, AlarmEditState state) {
        final AlarmEditCubit cubit = context.read<AlarmEditCubit>();
        final AlarmDraft draft = state.draft;
        return PopScope<Object?>(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) {
              unawaited(_close(context));
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: !state.loaded
                  ? const SizedBox.shrink()
                  : Column(
                      children: <Widget>[
                        AlarmHeader(
                          title: state.isNew ? editStrings.titleNew : editStrings.titleEdit,
                          subtitle: editStrings.ringsIn(remaining: AlarmFormat.remaining(cubit.untilNextRing())),
                          leading: AppIcons.x,
                          leadingLabel: strings.discard.discard,
                          onLeading: () => _close(context),
                          action: AppButton(label: editStrings.save, icon: AppIcons.check, onPressed: () => _save(context)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.s1000, 0, AppSpacing.s800, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        AppWheelPicker(
                                          values: _hours,
                                          selectedIndex: draft.time.hour,
                                          semanticLabel: editStrings.hours,
                                          loop: true,
                                          onChanged: cubit.setHour,
                                        ),
                                        SizedBox(
                                          width: 32,
                                          child: ExcludeSemantics(
                                            child: Text(
                                              ':',
                                              textAlign: TextAlign.center,
                                              style: AppTypography.clockMedium.copyWith(color: theme.textPrimary),
                                            ),
                                          ),
                                        ),
                                        AppWheelPicker(
                                          values: _minutes,
                                          selectedIndex: draft.time.minute,
                                          semanticLabel: editStrings.minutes,
                                          loop: true,
                                          onChanged: cubit.setMinute,
                                        ),
                                      ],
                                    ),
                                    if (!state.isNew) _DeleteButton(onPressed: () => _delete(context)),
                                  ],
                                ),
                                const SizedBox(width: AppSpacing.s600),
                                Expanded(
                                  child: Column(
                                    spacing: AppSpacing.s200,
                                    children: <Widget>[
                                      AppSettingsField(
                                        label: editStrings.name,
                                        value: draft.label.isEmpty ? editStrings.noName : draft.label,
                                        onTap: () async {
                                          final String? label = await showAlarmNameDialog(context, draft.label);
                                          if (label != null) {
                                            cubit.setLabel(label);
                                          }
                                        },
                                      ),
                                      AppSettingsField(
                                        label: editStrings.repeat,
                                        value: AlarmFormat.repeatShort(draft.repeat, ringsToday: cubit.ringsToday()),
                                        onTap: () => _editRepeat(context, state),
                                      ),
                                      AppSettingsField(
                                        label: editStrings.sound,
                                        value:
                                            '${AlarmFormat.soundName(draft.soundId)} · ${editStrings.soundDetail(minutes: draft.rise.inMinutes)}',
                                        onTap: () async {
                                          final AlarmSound? sound = await showAlarmSoundDialog(context, draft.soundId);
                                          if (sound != null) {
                                            cubit.setSound(sound.id);
                                          }
                                        },
                                      ),
                                      AppSettingsField(
                                        label: editStrings.snooze,
                                        value:
                                            '${editStrings.snoozeValue(minutes: draft.snooze.inMinutes)} · ${editStrings.snoozeDetail(count: draft.maxSnoozes)}',
                                        onTap: () async {
                                          final SnoozeChoice? choice = await showAlarmSnoozeDialog(
                                            context,
                                            SnoozeChoice(minutes: draft.snooze.inMinutes, times: draft.maxSnoozes),
                                          );
                                          if (choice != null) {
                                            cubit.setSnooze(
                                              snooze: Duration(minutes: choice.minutes),
                                              maxSnoozes: choice.times,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final AlarmTranslations$alarm$edit$es editStrings = alarmStrings.alarm.edit;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s400),
      child: AppPressable(
        onTap: onPressed,
        pressedColor: theme.bgDangerSubtle,
        borderRadius: BorderRadius.circular(AppRadii.full),
        semanticLabel: editStrings.delete,
        child: SizedBox(
          height: AppSizes.controlMedium,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s600),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s200,
              children: <Widget>[
                AppIcon(AppIcons.trash, size: AppSizes.iconSmall, color: theme.textDanger),
                Text(editStrings.delete, style: AppTypography.label.copyWith(color: theme.textDanger)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
