import 'package:alarm_domain/alarm_domain.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/ringing_use_cases.dart';
import '../../i18n/strings.g.dart';
import '../common/alarm_format.dart';
import 'hold_to_dismiss_button.dart';
import 'ringing_cubit.dart';

/// La alarma sonando (03.5): nombre, la hora en grande, «Mantén para apagar»
/// y «Posponer». Tocar en cualquier otro sitio pospone. De noche (03.5n) va
/// en negro y ámbar, según el [AppToneScope] que pone la app.
class AlarmRingingScreen extends StatelessWidget {
  const AlarmRingingScreen({super.key, required this.onFinished});

  /// Al posponer, apagar o si ya no suena nada.
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    final bool night = AppToneScope.of(context) == AppTone.night;
    return BlocConsumer<RingingCubit, RingingState>(
      listenWhen: (RingingState previous, RingingState current) =>
          current.loaded && (current.ringing == null || current.ringing!.session.isSnoozed),
      listener: (BuildContext context, RingingState state) => onFinished(),
      builder: (BuildContext context, RingingState state) {
        final RingingAlarm? ringing = state.ringing;
        final AppThemeColors theme = AppThemeColors.of(context);
        return Scaffold(
          backgroundColor: night ? AppNightColors.bg : theme.bgCanvas,
          body: ringing == null || ringing.session.isSnoozed
              ? const SizedBox.shrink()
              : _RingingBody(ringing: ringing, night: night),
        );
      },
    );
  }
}

class _RingingBody extends StatefulWidget {
  const _RingingBody({required this.ringing, required this.night});

  final RingingAlarm ringing;
  final bool night;

  @override
  State<_RingingBody> createState() => _RingingBodyState();
}

class _RingingBodyState extends State<_RingingBody> {
  /// Manteniendo para apagar: la pista de abajo deja sitio a la barra (03.5b).
  bool _holding = false;

  RingingAlarm get ringing => widget.ringing;
  bool get night => widget.night;

  @override
  Widget build(BuildContext context) {
    final AlarmTranslations$alarm$ringing$es ringingStrings = alarmStrings.alarm.ringing;
    final AppThemeColors theme = AppThemeColors.of(context);
    final RingingCubit cubit = context.read<RingingCubit>();
    final Alarm alarm = ringing.alarm;
    final AlarmSession session = ringing.session;
    final bool canSnooze = session.canSnooze(alarm);
    final int minutes = alarm.snooze.inMinutes;
    final String label = AlarmFormat.label(alarm);
    final Color secondaryText = night ? AppNightColors.textSecondary : theme.textSecondary;
    final String hint = canSnooze
        ? '${ringingStrings.tapAnywhere} · ${ringingStrings.snoozesLeft(n: session.snoozesLeft(alarm))}'
        : ringingStrings.noSnoozesLeft;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canSnooze ? cubit.snooze : null,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppSpacing.s300,
              children: <Widget>[
                AppIcon(AppIcons.bellRing, size: 28, color: night ? AppNightColors.textPrimary : theme.textBrand),
                Text(label, style: AppTypography.subtitle.copyWith(color: secondaryText)),
              ],
            ),
            Expanded(
              child: Center(
                child: AppClockTime(AlarmFormat.paddedOf(alarm.time), tone: night ? AppTone.night : AppTone.surface),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s600,
              children: <Widget>[
                HoldToDismissButton(
                  label: ringingStrings.holdToDismiss,
                  holdingLabel: ringingStrings.holding,
                  semanticLabel: ringingStrings.dismissSemantic(label: label),
                  variant: night ? AppButtonVariant.night : AppButtonVariant.secondary,
                  onDismiss: cubit.dismiss,
                  onHoldingChanged: (bool holding) => setState(() => _holding = holding),
                ),
                if (canSnooze)
                  AppButton(
                    label: ringingStrings.snooze(minutes: minutes),
                    icon: AppIcons.timer,
                    variant: night ? AppButtonVariant.nightPrimary : AppButtonVariant.primary,
                    semanticLabel: ringingStrings.snoozeSemantic(minutes: minutes),
                    onPressed: cubit.snooze,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s400),
              child: Visibility(
                visible: !_holding,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text(hint, style: AppTypography.label.copyWith(color: secondaryText)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
