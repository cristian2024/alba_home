import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Orden de los paneles en las hojas de Penpot.
const List<AppTone> _sheetTones = <AppTone>[AppTone.photo, AppTone.surface, AppTone.night];

/// Hoja de componentes, en el mismo orden que `01_componentes_<tema>.png` de
/// Penpot. Los textos son los de ejemplo de las hojas.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key, required this.dark, required this.onDarkChanged});

  final bool dark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(child: _Heading('design_system · Alba')),
                AppSwitch(value: dark, onChanged: onDarkChanged, semanticLabel: 'Tema oscuro'),
              ],
            ),
            const _IconsSection(),
            const _ButtonsSection(),
            const _CapsulesSection(),
            const _BannersSection(),
            const _FullScreenSection(),
            const _BlocksSection(),
            const _ClockSection(),
            const _KitchenSection(),
            const _AlarmSection(),
            const _SettingsSection(),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.title.copyWith(color: AppThemeColors.of(context).textPrimary));
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.subtitle});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final String? sub = subtitle;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s1600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s400,
        children: <Widget>[
          _Heading(title),
          if (sub != null) Text(sub, style: AppTypography.body.copyWith(color: theme.textSecondary)),
          // Las filas de la hoja de Penpot son más anchas que la pantalla:
          // cada una se desplaza en horizontal.
          for (final Widget child in children) _HorizontalScroll(child: child),
        ],
      ),
    );
  }
}

class _HorizontalScroll extends StatelessWidget {
  const _HorizontalScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: child);
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.caption.copyWith(color: AppThemeColors.of(context).textSecondary));
}

/// Panel que simula la foto del reloj (con su degradado) o el negro de noche.
class _Panel extends StatelessWidget {
  const _Panel({required this.tone, required this.child});

  final AppTone tone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (tone == AppTone.surface) {
      return Padding(padding: const EdgeInsets.all(AppSpacing.s200), child: child);
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s200),
      decoration: BoxDecoration(
        color: tone == AppTone.night ? AppNightColors.bg : AppColors.warm700,
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: child,
    );
  }
}

class _IconsSection extends StatelessWidget {
  const _IconsSection();

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return _Section(
      title: 'Iconos · Lucide (ISC)',
      children: <Widget>[
        SizedBox(
          width: 1000,
          child: Wrap(
            runSpacing: AppSpacing.s300,
            children: <Widget>[
              for (final AppIconData icon in AppIcons.all)
                SizedBox(
                  width: 80,
                  child: Column(
                    children: <Widget>[
                      AppIcon(icon, color: theme.textPrimary),
                      Text(
                        icon.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: AppTypography.caption.copyWith(color: theme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  static const List<AppButtonVariant> _variants = <AppButtonVariant>[
    AppButtonVariant.primary,
    AppButtonVariant.secondary,
    AppButtonVariant.ghost,
    AppButtonVariant.danger,
    AppButtonVariant.night,
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Botones · grande 72, estándar 48, icono',
      children: <Widget>[
        const _Caption('Grande · 72'),
        Wrap(
          spacing: AppSpacing.s400,
          children: <Widget>[
            for (final AppButtonVariant variant in _variants)
              AppButton(label: 'Posponer', icon: AppIcons.alarmPlus, variant: variant, onPressed: () {}),
          ],
        ),
        const _Caption('Estándar · 48'),
        Wrap(
          spacing: AppSpacing.s400,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final AppButtonVariant variant in _variants)
              AppButton(
                label: 'Añadir',
                icon: AppIcons.plus,
                variant: variant,
                size: AppButtonSize.standard,
                onPressed: () {},
              ),
            const SizedBox(width: AppSpacing.s1200),
            AppButton(
              label: 'Posponer',
              icon: AppIcons.alarmPlus,
              variant: AppButtonVariant.nightPrimary,
              onPressed: () {},
            ),
          ],
        ),
        const _Caption('Icono · 48 y 72'),
        Wrap(
          spacing: AppSpacing.s400,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final AppButtonVariant variant in <AppButtonVariant>[
              AppButtonVariant.primary,
              AppButtonVariant.secondary,
              AppButtonVariant.ghost,
              AppButtonVariant.night,
            ])
              AppIconButton(
                icon: AppIcons.plus,
                semanticLabel: 'Añadir',
                variant: variant,
                size: AppButtonSize.standard,
                onPressed: () {},
              ),
            for (final AppButtonVariant variant in _variants)
              AppIconButton(icon: AppIcons.pause, semanticLabel: 'Pausar', variant: variant, onPressed: () {}),
          ],
        ),
      ],
    );
  }
}

class _CapsulesSection extends StatelessWidget {
  const _CapsulesSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Cápsulas de estado · icono, texto, urgencia',
      subtitle: 'Las publica cada funcionalidad como datos (AmbientStatusSource). La urgencia decide el estilo.',
      children: <Widget>[
        for (final AppTone tone in _sheetTones)
          _Panel(
            tone: tone,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s400,
              children: <Widget>[
                SizedBox(width: 60, child: _ToneLabel(tone)),
                AppStatusCapsule(icon: AppIcons.alarm, label: 'Alarma 6:30', tone: tone),
                AppStatusCapsule(icon: AppIcons.batteryLow, label: 'Batería 18 %', tone: tone, urgency: AppUrgency.warning),
                AppStatusCapsule(icon: AppIcons.timer, label: 'Pasta · lista', tone: tone, urgency: AppUrgency.urgent),
              ],
            ),
          ),
      ],
    );
  }
}

class _ToneLabel extends StatelessWidget {
  const _ToneLabel(this.tone);

  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final Color color = switch (tone) {
      AppTone.surface => theme.textSecondary,
      AppTone.photo => theme.textOnPhoto,
      AppTone.night => AppNightColors.textSecondary,
    };
    return Text(
      switch (tone) {
        AppTone.surface => 'Surface',
        AppTone.photo => 'Photo',
        AppTone.night => 'Night',
      },
      style: AppTypography.caption.copyWith(color: color),
    );
  }
}

class _BannersSection extends StatelessWidget {
  const _BannersSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Banner de aviso · icono, título, texto, acción',
      children: <Widget>[
        for (final (AppBannerVariant variant, AppIconData icon, String title, String message, String action)
            in const <(AppBannerVariant, AppIconData, String, String, String)>[
          (AppBannerVariant.info, AppIcons.info, 'Fotos actualizadas', '24 fotos nuevas en la carpeta Alba.', 'Ver'),
          (
            AppBannerVariant.warning,
            AppIcons.batteryLow,
            'Batería baja · 18 %',
            'Conecta el cargador para que suene la alarma de las 6:30.',
            'Entendido',
          ),
          (
            AppBannerVariant.critical,
            AppIcons.batteryAlert,
            'Batería crítica · 5 %',
            'El teléfono se apagará pronto y la alarma no sonará.',
            'Entendido',
          ),
          (
            AppBannerVariant.photo,
            AppIcons.batteryLow,
            'Batería baja · 18 %',
            'Conecta el cargador para que suene la alarma de las 6:30.',
            'Entendido',
          ),
          (
            AppBannerVariant.night,
            AppIcons.batteryLow,
            'No llega a la alarma',
            'Con 9 % no aguanta hasta las 6:30. Conecta el cargador.',
            'Entendido',
          ),
        ])
          _Panel(
            tone: switch (variant) {
              AppBannerVariant.photo => AppTone.photo,
              AppBannerVariant.night => AppTone.night,
              _ => AppTone.surface,
            },
            child: SizedBox(
              width: 827,
              child: AppAlertBanner(
                icon: icon,
                title: title,
                message: message,
                actionLabel: action,
                variant: variant,
                onAction: () {},
              ),
            ),
          ),
      ],
    );
  }
}

class _FullScreenSection extends StatelessWidget {
  const _FullScreenSection();

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    return _Section(
      title: 'Aviso a pantalla completa · 891 × 411 · botones de 72',
      children: <Widget>[
        Row(
          spacing: AppSpacing.s800,
          children: <Widget>[
            for (final AppFullScreenVariant variant in AppFullScreenVariant.values)
              Container(
                width: AppLayout.screenWidth,
                height: AppLayout.screenHeight,
                decoration: BoxDecoration(border: Border.all(color: theme.borderDefault)),
                child: switch (variant) {
                  AppFullScreenVariant.danger => AppFullScreenAlert(
                      icon: AppIcons.batteryAlert,
                      title: 'Batería crítica · 5 %',
                      subtitle: 'Conecta el cargador: sin él, la alarma de las 6:30 no sonará.',
                      variant: variant,
                      secondary: AppAlertAction(label: 'Ver ajustes', icon: AppIcons.settings, onPressed: () {}),
                      primary: AppAlertAction(label: 'Entendido', icon: AppIcons.check, onPressed: () {}),
                    ),
                  _ => AppFullScreenAlert(
                      icon: AppIcons.timer,
                      title: 'Pasta lista',
                      subtitle: variant == AppFullScreenVariant.night
                          ? 'Temporizador de 12 min · terminó a las 23:42'
                          : 'Temporizador de 12 min · terminó a las 13:42',
                      variant: variant,
                      secondary: AppAlertAction(label: 'Añadir 1 min', icon: AppIcons.plus, onPressed: () {}),
                      primary: AppAlertAction(label: 'Detener', icon: AppIcons.x, onPressed: () {}),
                    ),
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _BlocksSection extends StatelessWidget {
  const _BlocksSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Bloques de estado · banda inferior del reloj, uno a cada lado de la hora (máx. 2)',
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final AppTone tone in _sheetTones)
              _Panel(
                tone: tone,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppStatusBlock(icon: AppIcons.alarm, value: '6:30', label: 'Alarma', tone: tone),
                    AppStatusBlock(
                      icon: AppIcons.batteryLow,
                      value: '18 %',
                      label: 'Batería',
                      tone: tone,
                      urgency: AppUrgency.warning,
                    ),
                    AppStatusBlock(
                      icon: AppIcons.timer,
                      value: '0:00',
                      label: 'Pasta lista',
                      tone: tone,
                      urgency: AppUrgency.urgent,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ClockSection extends StatelessWidget {
  const _ClockSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Reloj · cifras tabulares',
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s800,
          children: <Widget>[
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s400,
              children: <Widget>[
                _Panel(tone: AppTone.photo, child: AppClockTime('07:41', tone: AppTone.photo)),
                _Panel(tone: AppTone.surface, child: AppClockTime('07:41')),
                _Panel(tone: AppTone.night, child: AppClockTime('07:41', tone: AppTone.night)),
                AppClockTime('07:41', size: AppClockSize.medium),
                _Panel(tone: AppTone.night, child: AppClockTime('07:41', size: AppClockSize.medium, tone: AppTone.night)),
                AppClockTime('07:41', size: AppClockSize.small),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s400,
              children: <Widget>[
                const _Caption('Mode/Dots · Reloj, Sonidos, Cocina'),
                for (final AppTone tone in _sheetTones)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.s400,
                    children: <Widget>[
                      for (int index = 0; index < 3; index++)
                        _Panel(tone: tone, child: AppModeDots(count: 3, index: index, tone: tone)),
                    ],
                  ),
                const AppClockTime('07:41', size: AppClockSize.large),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _KitchenSection extends StatelessWidget {
  const _KitchenSection();

  static const AppTimerCardLabels _labels = AppTimerCardLabels(
    addMinute: '1 min',
    addMinuteSemantic: 'Añadir 1 minuto',
    pauseSemantic: 'Pausar',
    resumeSemantic: 'Reanudar',
    dismissSemantic: 'Listo',
    stopSemantic: 'Detener',
    undo: 'Deshacer',
    undoSemantic: 'Deshacer',
  );

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Cocina · tarjeta de temporizador de 264 y tiempos guardados (botones de 72)',
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s400,
          children: <Widget>[
            AppTimerCard(
              name: 'Pasta',
              statusLabel: 'Quedan 8 min',
              remaining: '08:24',
              progress: 0.7,
              status: AppTimerStatus.running,
              labels: _labels,
              onAddMinute: () {},
              onToggle: () {},
              onStop: () {},
            ),
            AppTimerCard(
              name: 'Huevos',
              statusLabel: 'En pausa',
              remaining: '03:10',
              progress: 0.45,
              status: AppTimerStatus.paused,
              labels: _labels,
              onAddMinute: () {},
              onToggle: () {},
              onStop: () {},
            ),
            AppTimerCard(
              name: 'Arroz',
              statusLabel: 'Listo',
              remaining: '00:00',
              progress: 1,
              status: AppTimerStatus.finished,
              labels: _labels,
              onAddMinute: () {},
              onToggle: () {},
            ),
            AppTimerCard(
              name: 'Pasta',
              statusLabel: 'Detenido',
              remaining: '06:12',
              progress: 0.3,
              status: AppTimerStatus.stopped,
              labels: _labels,
              undoCountdown: '5 s',
              onUndo: () {},
            ),
          ],
        ),
        const _Caption('Saved/Chip · tiempos guardados'),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s400,
          children: <Widget>[
            AppSavedChip(label: 'Huevo pasado', duration: '7 min', onTap: () {}),
            AppSavedChip(label: 'Huevo pasado', duration: '7 min', selected: true, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _AlarmSection extends StatelessWidget {
  const _AlarmSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Alarma · fila, interruptor y días',
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s1600,
          children: <Widget>[
            SizedBox(
              width: 827,
              child: Column(
                spacing: AppSpacing.s400,
                children: <Widget>[
                  AppAlarmRow(
                    time: '06:30',
                    label: 'Trabajo',
                    detail: 'Lun a vie · suena en 7 h 13 min',
                    enabled: true,
                    onTap: () {},
                    onEnabledChanged: (bool value) {},
                  ),
                  AppAlarmRow(
                    time: '09:00',
                    label: 'Fin de semana',
                    detail: 'Sáb y dom · desactivada',
                    enabled: false,
                    onTap: () {},
                    onEnabledChanged: (bool value) {},
                  ),
                ],
              ),
            ),
            Column(
              spacing: AppSpacing.s400,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppSwitch(value: true, semanticLabel: 'Encendido', onChanged: (bool value) {}),
                    AppSwitch(value: false, semanticLabel: 'Apagado', onChanged: (bool value) {}),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.s200,
                  children: <Widget>[
                    AppDayToggle(label: 'Lun', selected: true, onChanged: (bool value) {}),
                    AppDayToggle(label: 'Lun', selected: false, onChanged: (bool value) {}),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Sonidos, ajustes, selectores y estado vacío',
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Panel(
              tone: AppTone.surface,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.s400,
                children: <Widget>[
                  AppSoundTile(icon: AppIcons.rain, name: 'Lluvia', detail: 'Reproduciendo', selected: true, onTap: () {}),
                  AppSoundTile(icon: AppIcons.rain, name: 'Lluvia', detail: 'Bucle sin cortes', onTap: () {}),
                ],
              ),
            ),
            _Panel(
              tone: AppTone.night,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.s400,
                children: <Widget>[
                  AppSoundTile(
                    icon: AppIcons.rain,
                    name: 'Lluvia',
                    detail: 'Reproduciendo',
                    selected: true,
                    tone: AppTone.night,
                    onTap: () {},
                  ),
                  AppSoundTile(
                    icon: AppIcons.rain,
                    name: 'Lluvia',
                    detail: 'Bucle sin cortes',
                    tone: AppTone.night,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s800,
          children: <Widget>[
            SizedBox(
              width: 827,
              child: Column(
                spacing: AppSpacing.s400,
                children: <Widget>[
                  AppSettingsRow(icon: AppIcons.moon, title: 'Horario de noche', subtitle: '22:30 a 6:45', onTap: () {}),
                  AppSettingsRow(icon: AppIcons.languages, title: 'Idioma', value: 'Español', onTap: () {}),
                  AppSettingsRow(
                    icon: AppIcons.images,
                    title: 'Fotos de fondo',
                    subtitle: 'Solo de día',
                    switchValue: true,
                    onSwitchChanged: (bool value) {},
                  ),
                  AppEmptyState(
                    icon: AppIcons.folderOpen,
                    title: 'La carpeta de fotos está vacía',
                    message: 'Copia fotos por USB a la carpeta Alba del teléfono. Aparecerán solas en unos segundos.',
                    action: AppAlertAction(label: 'Cómo copiar fotos', icon: AppIcons.info, onPressed: () {}),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s400,
              children: <Widget>[
                AppStepper(
                  value: '20 %',
                  decrementLabel: 'Bajar',
                  incrementLabel: 'Subir',
                  onDecrement: () {},
                  onIncrement: () {},
                ),
                const _Caption('Settings/Stepper'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.s400,
                  children: <Widget>[
                    const _WheelDemo(tone: AppTone.surface),
                    Container(
                      color: AppNightColors.bg,
                      child: const _WheelDemo(tone: AppTone.night),
                    ),
                  ],
                ),
                const _Caption('Wheel/Picker · Surface / Night'),
                SizedBox(width: 443, child: AppSettingsField(label: 'Nombre', value: 'Trabajo', onTap: () {})),
                const _Caption('Settings/Row/Field · 443'),
                SizedBox(
                  width: 405,
                  child: AppSettingsRow(
                    icon: AppIcons.moon,
                    title: 'Horario de noche',
                    subtitle: 'De 22:30 a 6:45',
                    onTap: () {},
                  ),
                ),
                SizedBox(
                  width: 405,
                  child: AppSettingsRow(
                    icon: AppIcons.shieldAlert,
                    title: 'Que Huawei no cierre Alba',
                    subtitle: 'Pendiente · recomendado',
                    attention: true,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _WheelDemo extends StatefulWidget {
  const _WheelDemo({required this.tone});

  final AppTone tone;

  @override
  State<_WheelDemo> createState() => _WheelDemoState();
}

class _WheelDemoState extends State<_WheelDemo> {
  int _selected = 6;

  @override
  Widget build(BuildContext context) {
    return AppWheelPicker(
      values: <String>[for (int i = 0; i < 60; i++) i.toString().padLeft(2, '0')],
      selectedIndex: _selected,
      semanticLabel: 'Minutos',
      tone: widget.tone,
      onChanged: (int index) => setState(() => _selected = index),
    );
  }
}
