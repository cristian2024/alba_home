import 'package:alarm_domain/alarm_domain.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/ringing_use_cases.dart';
import '../../i18n/strings.g.dart';
import '../common/alarm_format.dart';
import 'ringing_cubit.dart';

/// Alarma pospuesta, tras tocar su bloque en el reloj (03.6b): cuándo vuelve
/// a sonar, cuántas veces se pospuso, «Seguir durmiendo» y «Apagar alarma».
class AlarmSnoozedScreen extends StatelessWidget {
  const AlarmSnoozedScreen({super.key, required this.wallClock, required this.onClose});

  final WallClock wallClock;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    final bool night = AppToneScope.of(context) == AppTone.night;
    return BlocConsumer<RingingCubit, RingingState>(
      listenWhen: (RingingState previous, RingingState current) =>
          current.loaded && (current.ringing == null || !current.ringing!.session.isSnoozed),
      listener: (BuildContext context, RingingState state) => onClose(),
      builder: (BuildContext context, RingingState state) {
        final RingingAlarm? ringing = state.ringing;
        final DateTime? until = ringing?.session.snoozedUntil;
        if (ringing == null || until == null) {
          return const Scaffold(body: SizedBox.shrink());
        }
        return Scaffold(
          body: AppFullScreenAlert(
            icon: AppIcons.timer,
            title: strings.snoozed.title(time: AlarmFormat.localTime(until, wallClock)),
            subtitle: strings.snoozed.detail(
              label: AlarmFormat.label(ringing.alarm),
              used: ringing.session.snoozesUsed,
              max: ringing.alarm.maxSnoozes,
            ),
            variant: night ? AppFullScreenVariant.night : AppFullScreenVariant.normal,
            secondary: AppAlertAction(label: strings.snoozed.keepSleeping, icon: AppIcons.moon, onPressed: onClose),
            primary: AppAlertAction(
              label: strings.snoozed.turnOff,
              icon: AppIcons.alarmOff,
              onPressed: () => context.read<RingingCubit>().dismiss(),
            ),
          ),
        );
      },
    );
  }
}
