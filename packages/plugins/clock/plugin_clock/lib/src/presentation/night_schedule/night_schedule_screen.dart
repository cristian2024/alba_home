import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../i18n/strings.g.dart';
import '../common/clock_format.dart';
import 'night_schedule_cubit.dart';

/// Horario de noche (08.2): cuándo empieza y cuándo termina, con ruedas. Se
/// guarda al girar.
class NightScheduleScreen extends StatelessWidget {
  const NightScheduleScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  static final List<String> _hours = <String>[for (int h = 0; h < 24; h++) ClockFormat.two(h)];
  static final List<String> _minutes = <String>[for (int m = 0; m < 60; m++) ClockFormat.two(m)];

  @override
  Widget build(BuildContext context) {
    final ClockTranslations$clock$nightSchedule$es scheduleStrings = clockStrings.clock.nightSchedule;
    final AppThemeColors theme = AppThemeColors.of(context);
    final TextStyle labelStyle = AppTypography.label.copyWith(color: theme.textSecondary);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<NightScheduleCubit, NightScheduleState>(
          builder: (BuildContext context, NightScheduleState state) {
            final NightScheduleCubit cubit = context.read<NightScheduleCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: AppSizes.controlLarge,
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: AppSpacing.s200),
                      AppIconButton(
                        icon: AppIcons.chevronLeft,
                        semanticLabel: scheduleStrings.back,
                        variant: AppButtonVariant.ghost,
                        onPressed: onBack,
                      ),
                      const SizedBox(width: AppSpacing.s200),
                      Semantics(
                        header: true,
                        child: Text(
                          scheduleStrings.title,
                          style: AppTypography.title.copyWith(color: theme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    // Como en Penpot: «Termina» acaba a 72 del borde derecho.
                    padding: const EdgeInsets.only(left: AppSpacing.s1000, right: AppSpacing.s1600 + AppSpacing.s200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _TimeWheels(
                          label: scheduleStrings.starts,
                          labelStyle: labelStyle,
                          hours: _hours,
                          minutes: _minutes,
                          hour: state.start.hour,
                          minute: state.start.minute,
                          hoursLabel: scheduleStrings.startHours,
                          minutesLabel: scheduleStrings.startMinutes,
                          onHour: cubit.setStartHour,
                          onMinute: cubit.setStartMinute,
                        ),
                        _TimeWheels(
                          label: scheduleStrings.ends,
                          labelStyle: labelStyle,
                          hours: _hours,
                          minutes: _minutes,
                          hour: state.end.hour,
                          minute: state.end.minute,
                          hoursLabel: scheduleStrings.endHours,
                          minutesLabel: scheduleStrings.endMinutes,
                          onHour: cubit.setEndHour,
                          onMinute: cubit.setEndMinute,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s800, 0, AppSpacing.s800, AppSpacing.s500),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      state.sameTime ? scheduleStrings.sameTime : scheduleStrings.note,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(color: state.sameTime ? theme.textDanger : theme.textSecondary),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// «Empieza» o «Termina» con sus ruedas de horas y minutos.
class _TimeWheels extends StatelessWidget {
  const _TimeWheels({
    required this.label,
    required this.labelStyle,
    required this.hours,
    required this.minutes,
    required this.hour,
    required this.minute,
    required this.hoursLabel,
    required this.minutesLabel,
    required this.onHour,
    required this.onMinute,
  });

  final String label;
  final TextStyle labelStyle;
  final List<String> hours;
  final List<String> minutes;
  final int hour;
  final int minute;
  final String hoursLabel;
  final String minutesLabel;
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinute;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: labelStyle),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppWheelPicker(values: hours, selectedIndex: hour, semanticLabel: hoursLabel, loop: true, onChanged: onHour),
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
              values: minutes,
              selectedIndex: minute,
              semanticLabel: minutesLabel,
              loop: true,
              onChanged: onMinute,
            ),
          ],
        ),
      ],
    );
  }
}
