import 'package:alarm_domain/alarm_domain.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../common/alarm_format.dart';
import '../common/alarm_header.dart';

/// Días de repetición (03.4): siete días, tres atajos y la frase de cuándo
/// sonará. Al volver devuelve los días elegidos.
class RepeatScreen extends StatefulWidget {
  const RepeatScreen({super.key, required this.initial, required this.time});

  final Set<Weekday> initial;
  final AlarmTime time;

  @override
  State<RepeatScreen> createState() => _RepeatScreenState();
}

class _RepeatScreenState extends State<RepeatScreen> {
  late Set<Weekday> _days = <Weekday>{...widget.initial};

  bool _is(Set<Weekday> preset) => _days.length == preset.length && _days.containsAll(preset);

  void _toggle(Weekday day, bool selected) => setState(() {
        _days = <Weekday>{..._days};
        selected ? _days.add(day) : _days.remove(day);
      });

  void _done() => Navigator.of(context).pop(_days);

  @override
  Widget build(BuildContext context) {
    final AlarmTranslations$alarm$repeatScreen$es repeatScreenStrings = alarmStrings.alarm.repeatScreen;
    final AppThemeColors theme = AppThemeColors.of(context);
    return PopScope<Set<Weekday>>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Set<Weekday>? result) {
        if (!didPop) {
          _done();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              AlarmHeader(
                title: repeatScreenStrings.title,
                leading: AppIcons.chevronLeft,
                leadingLabel: repeatScreenStrings.done,
                onLeading: _done,
              ),
              const SizedBox(height: AppSpacing.s400),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.s600,
                children: <Widget>[
                  for (final Weekday day in Weekday.values)
                    AppDayToggle(
                      label: AlarmFormat.dayShort(day),
                      semanticLabel: AlarmFormat.dayLong(day),
                      selected: _days.contains(day),
                      onChanged: (bool selected) => _toggle(day, selected),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s1000),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.s400,
                children: <Widget>[
                  for (final (String label, Set<Weekday> preset) in <(String, Set<Weekday>)>[
                    (repeatScreenStrings.presetEveryDay, Weekday.everyDay),
                    (repeatScreenStrings.presetWeekdays, Weekday.weekdays),
                    (repeatScreenStrings.presetWeekend, Weekday.weekend),
                  ])
                    _PresetChip(label: label, selected: _is(preset), onTap: () => setState(() => _days = <Weekday>{...preset})),
                ],
              ),
              const SizedBox(height: AppSpacing.s1000),
              Text(
                _days.isEmpty
                    ? repeatScreenStrings.noDays
                    : '${repeatScreenStrings.summary(days: AlarmFormat.repeatLong(_days), time: AlarmFormat.timeOf(widget.time))}\n${repeatScreenStrings.noDays}',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Atajo de días: una ficha de 72 sin duración.
class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return AppPressable(
      onTap: onTap,
      color: selected ? theme.bgBrandSubtle : theme.bgSurfaceRaised,
      pressedColor: selected ? theme.bgBrandMuted : theme.bgSurfacePressed,
      borderColor: selected ? theme.borderBrand : theme.borderDefault,
      borderRadius: BorderRadius.circular(AppRadii.full),
      semanticLabel: label,
      selected: selected,
      child: SizedBox(
        height: AppSizes.controlLarge,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s600),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(color: selected ? theme.textOnBrandSubtle : theme.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
