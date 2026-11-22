import 'package:flutter/widgets.dart';

import '../theme/app_tone.dart';
import '../tokens/app_night_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_theme_colors.dart';
import '../tokens/app_typography.dart';

/// Rueda para elegir un número sin teclado (`Wheel/Picker/*`), de 160 × 240:
/// el valor elegido en cifras de 96 sobre una banda hundida y los vecinos en
/// Title, atenuados. Se arrastra arriba y abajo; el lector la ajusta con
/// subir y bajar.
class AppWheelPicker extends StatefulWidget {
  const AppWheelPicker({
    super.key,
    required this.values,
    required this.selectedIndex,
    required this.onChanged,
    required this.semanticLabel,
    this.tone = AppTone.surface,
    this.loop = false,
  });

  /// Valores ya formateados («00» a «59»).
  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Qué se elige («Minutos»).
  final String semanticLabel;
  final AppTone tone;

  /// Si después del último vuelve al primero (minutos, horas).
  final bool loop;

  static const double width = 160;
  static const double height = 240;
  static const double itemExtent = 84;

  @override
  State<AppWheelPicker> createState() => _AppWheelPickerState();
}

class _AppWheelPickerState extends State<AppWheelPicker> {
  late final FixedExtentScrollController _controller = FixedExtentScrollController(initialItem: widget.selectedIndex);

  List<String> get _values => widget.values;

  int get _selected => widget.selectedIndex;

  /// Mientras la rueda se pone al día con un valor que llega de fuera, sin
  /// volver a avisar a quien lo cambió.
  bool _syncing = false;

  @override
  void didUpdateWidget(AppWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((Duration timestamp) {
      if (!mounted || !_controller.hasClients || _selected == _controller.selectedItem % _values.length) {
        return;
      }
      _syncing = true;
      _controller.jumpToItem(_selected);
      _syncing = false;
    });
  }

  void _onSelectedItemChanged(int item) {
    if (!_syncing) {
      widget.onChanged(item % _values.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final int count = _values.length;
    final int next = widget.loop ? (_selected + delta) % count : (_selected + delta).clamp(0, count - 1);
    if (next != _selected) {
      widget.onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final bool night = widget.tone == AppTone.night;
    final Color band = night ? AppNightColors.action : theme.bgSurfaceSunken;
    final Color selectedColor = night ? AppNightColors.textPrimary : theme.textPrimary;
    final Color otherColor = night ? AppNightColors.textSecondary : theme.textTertiary;
    final int count = _values.length;
    final bool canDecrease = widget.loop || _selected > 0;
    final bool canIncrease = widget.loop || _selected < count - 1;
    return Semantics(
      label: widget.semanticLabel,
      value: _values[_selected],
      increasedValue: canIncrease ? _values[(_selected + 1) % count] : null,
      decreasedValue: canDecrease ? _values[(_selected - 1 + count) % count] : null,
      onIncrease: canIncrease ? () => _step(1) : null,
      onDecrease: canDecrease ? () => _step(-1) : null,
      child: ExcludeSemantics(
        child: SizedBox(
          width: AppWheelPicker.width,
          height: AppWheelPicker.height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: 96,
                decoration: BoxDecoration(color: band, borderRadius: BorderRadius.circular(AppRadii.large)),
              ),
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: AppWheelPicker.itemExtent,
                diameterRatio: 100,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: _onSelectedItemChanged,
                childDelegate: widget.loop
                    ? ListWheelChildLoopingListDelegate(children: _items(selectedColor, otherColor))
                    : ListWheelChildListDelegate(children: _items(selectedColor, otherColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _items(Color selectedColor, Color otherColor) {
    final List<Widget> items = <Widget>[];
    for (int i = 0; i < _values.length; i++) {
      final bool selected = i == _selected;
      items.add(
        Center(
          child: Text(
            _values[i],
            style: selected
                ? AppTypography.clockMedium.copyWith(color: selectedColor)
                : AppTypography.title.copyWith(color: otherColor),
          ),
        ),
      );
    }
    return items;
  }
}
