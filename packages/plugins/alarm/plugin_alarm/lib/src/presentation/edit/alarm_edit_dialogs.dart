import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/alarm_sound.dart';
import '../../i18n/strings.g.dart';
import '../common/alarm_format.dart';

/// Diálogos de los campos de 03.3. Penpot no los dibuja: están hechos con los
/// componentes del sistema de diseño, en una tarjeta centrada.
class _AlarmDialog extends StatelessWidget {
  const _AlarmDialog({required this.title, required this.child, required this.onDone});

  final String title;
  final Widget child;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    return Dialog(
      backgroundColor: theme.bgSurfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.extraLarge),
        side: BorderSide(color: theme.borderDefault),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s400,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Text(title, style: AppTypography.title.copyWith(color: theme.textPrimary))),
                  AppButton(label: strings.repeatScreen.done, icon: AppIcons.check, size: AppButtonSize.standard, onPressed: onDone),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Nombre de la alarma con el teclado del sistema. Devuelve el texto o
/// `null` si se cierra sin aceptar.
Future<String?> showAlarmNameDialog(BuildContext context, String current) => showDialog<String>(
      context: context,
      builder: (BuildContext context) => _NameDialog(initial: current),
    );

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.large),
      borderSide: BorderSide(color: theme.borderDefault),
    );
    return _AlarmDialog(
      title: strings.edit.name,
      onDone: _done,
      child: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (String value) => _done(),
        style: AppTypography.bodyLarge.copyWith(color: theme.textPrimary),
        decoration: InputDecoration(
          hintText: strings.edit.nameHint,
          hintStyle: AppTypography.bodyLarge.copyWith(color: theme.textTertiary),
          filled: true,
          fillColor: theme.bgSurface,
          counterText: '',
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(borderSide: BorderSide(color: theme.borderFocus, width: AppSizes.strokeThick)),
        ),
      ),
    );
  }
}

/// Sonido de la alarma, entre los del catálogo. Devuelve el elegido o `null`.
Future<AlarmSound?> showAlarmSoundDialog(BuildContext context, String currentId) => showDialog<AlarmSound>(
      context: context,
      builder: (BuildContext context) => _SoundDialog(initialId: currentId),
    );

class _SoundDialog extends StatefulWidget {
  const _SoundDialog({required this.initialId});

  final String initialId;

  @override
  State<_SoundDialog> createState() => _SoundDialogState();
}

class _SoundDialogState extends State<_SoundDialog> {
  late AlarmSound _selected = AlarmSounds.byId(widget.initialId);

  @override
  Widget build(BuildContext context) {
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    return _AlarmDialog(
      title: strings.edit.sound,
      onDone: () => Navigator.of(context).pop(_selected),
      child: Wrap(
        spacing: AppSpacing.s300,
        runSpacing: AppSpacing.s300,
        children: <Widget>[
          for (final AlarmSound sound in AlarmSounds.all)
            AppSavedChip(
              label: AlarmFormat.soundName(sound.id),
              duration: '',
              selected: sound == _selected,
              semanticLabel: AlarmFormat.soundName(sound.id),
              onTap: () => setState(() => _selected = sound),
            ),
        ],
      ),
    );
  }
}

/// Minutos de cada posposición y cuántas veces seguidas.
class SnoozeChoice {
  const SnoozeChoice({required this.minutes, required this.times});

  final int minutes;
  final int times;
}

/// Posponer: minutos (de 5 en 5, de 5 a 30) y veces (de 1 a 5). Devuelve la
/// elección o `null`.
Future<SnoozeChoice?> showAlarmSnoozeDialog(BuildContext context, SnoozeChoice current) => showDialog<SnoozeChoice>(
      context: context,
      builder: (BuildContext context) => _SnoozeDialog(initial: current),
    );

class _SnoozeDialog extends StatefulWidget {
  const _SnoozeDialog({required this.initial});

  final SnoozeChoice initial;

  @override
  State<_SnoozeDialog> createState() => _SnoozeDialogState();
}

class _SnoozeDialogState extends State<_SnoozeDialog> {
  static const int _minMinutes = 5;
  static const int _maxMinutes = 30;
  static const int _step = 5;
  static const int _minTimes = 1;
  static const int _maxTimes = 5;

  late int _minutes = widget.initial.minutes.clamp(_minMinutes, _maxMinutes);
  late int _times = widget.initial.times.clamp(_minTimes, _maxTimes);

  @override
  Widget build(BuildContext context) {
    final AlarmTranslations$alarm$es strings = alarmStrings.alarm;
    return _AlarmDialog(
      title: strings.edit.snooze,
      onDone: () => Navigator.of(context).pop(SnoozeChoice(minutes: _minutes, times: _times)),
      child: Column(
        spacing: AppSpacing.s400,
        children: <Widget>[
          AppStepper(
            value: strings.edit.snoozeValue(minutes: _minutes),
            decrementLabel: '${strings.edit.snooze} −',
            incrementLabel: '${strings.edit.snooze} +',
            onDecrement: _minutes > _minMinutes ? () => setState(() => _minutes -= _step) : null,
            onIncrement: _minutes < _maxMinutes ? () => setState(() => _minutes += _step) : null,
          ),
          AppStepper(
            value: strings.edit.snoozeDetail(count: _times),
            decrementLabel: '${strings.edit.snoozeDetail(count: _times)} −',
            incrementLabel: '${strings.edit.snoozeDetail(count: _times)} +',
            onDecrement: _times > _minTimes ? () => setState(() => _times--) : null,
            onIncrement: _times < _maxTimes ? () => setState(() => _times++) : null,
          ),
        ],
      ),
    );
  }
}
