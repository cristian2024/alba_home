import 'package:alarm_domain/alarm_domain.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/alarm_use_cases.dart';
import '../../i18n/strings.g.dart';
import '../common/alarm_format.dart';
import '../common/alarm_header.dart';
import 'alarm_list_cubit.dart';

/// Lista de alarmas (03.1), vacía (03.2) o con las alarmas bloqueadas por
/// Android (03.7).
class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({
    super.key,
    required this.wallClock,
    required this.onCreate,
    required this.onEdit,
    this.onBack,
  });

  final WallClock wallClock;
  final VoidCallback onCreate;
  final ValueChanged<String> onEdit;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AlarmListCubit, AlarmListState>(
          builder: (BuildContext context, AlarmListState state) {
            final AlarmListCubit cubit = context.read<AlarmListCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AlarmHeader(
                  title: strings.list.title,
                  subtitle: _nextSummary(state),
                  leading: onBack == null ? null : AppIcons.chevronLeft,
                  leadingLabel: strings.edit.back,
                  onLeading: onBack,
                  // Vacía, la única acción es la del centro (03.2).
                  action: state.loaded && state.entries.isEmpty
                      ? null
                      : AppButton(
                          label: strings.list.newButton,
                          icon: AppIcons.alarmPlus,
                          size: AppButtonSize.standard,
                          onPressed: onCreate,
                        ),
                ),
                if (!state.loaded)
                  const SizedBox.shrink()
                else if (state.entries.isEmpty)
                  Expanded(
                    child: Center(
                      child: AppEmptyState(
                        icon: AppIcons.alarm,
                        title: strings.empty.title,
                        message: strings.empty.body,
                        action: AppAlertAction(
                          label: strings.empty.action,
                          icon: AppIcons.alarmPlus,
                          onPressed: onCreate,
                        ),
                        actionSize: AppButtonSize.large,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.s800, 0, AppSpacing.s800, AppSpacing.s600),
                      children: <Widget>[
                        if (!state.canRing)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s400),
                            child: AppAlertBanner(
                              icon: AppIcons.alarmOff,
                              title: strings.permission.bannerTitle,
                              message: strings.permission.bannerBody,
                              actionLabel: strings.permission.activate,
                              variant: AppBannerVariant.critical,
                              onAction: cubit.requestPermission,
                            ),
                          ),
                        for (final AlarmListEntry entry in state.entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s200),
                            child: _AlarmRow(
                              entry: entry,
                              now: state.now,
                              wallClock: wallClock,
                              canRing: state.canRing,
                              onTap: () => onEdit(entry.alarm.id),
                              onEnabledChanged: (bool enabled) => cubit.setEnabled(entry.alarm.id, enabled: enabled),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _nextSummary(AlarmListState state) {
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    final DateTime? next = state.next?.ringsAt;
    // Bloqueadas por Android no suenan: el banner lo dice (03.7).
    if (!state.canRing) {
      return '';
    }
    if (next == null) {
      return state.loaded && state.entries.isNotEmpty ? strings.list.noNext : '';
    }
    return strings.list.next(
      time: AlarmFormat.localTime(next, wallClock),
      remaining: AlarmFormat.remaining(next.difference(state.now)),
    );
  }
}

class _AlarmRow extends StatelessWidget {
  const _AlarmRow({
    required this.entry,
    required this.now,
    required this.wallClock,
    required this.canRing,
    required this.onTap,
    required this.onEnabledChanged,
  });

  final AlarmListEntry entry;
  final DateTime now;
  final WallClock wallClock;
  final bool canRing;
  final VoidCallback onTap;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    final Alarm alarm = entry.alarm;
    final DateTime? next = entry.nextRing;
    final String repeat = AlarmFormat.repeatShort(
      alarm.repeat,
      ringsToday: next != null && AlarmFormat.isToday(next, now, wallClock),
    );
    final String status = !alarm.enabled
        ? strings.list.disabled
        : !canRing
        ? strings.list.blocked
        : alarm.isRepeating && next != null
        ? strings.list.ringsIn(remaining: AlarmFormat.remaining(next.difference(now)))
        : '';
    final String detail = status.isEmpty ? repeat : '$repeat · $status';
    final String time = AlarmFormat.paddedOf(alarm.time);
    return AppAlarmRow(
      time: time,
      label: AlarmFormat.label(alarm),
      detail: detail,
      enabled: alarm.enabled,
      blocked: alarm.enabled && !canRing,
      semanticLabel: strings.list.rowSemantic(
        time: AlarmFormat.timeOf(alarm.time),
        label: AlarmFormat.label(alarm),
        detail: detail,
      ),
      onTap: onTap,
      onEnabledChanged: onEnabledChanged,
    );
  }
}
