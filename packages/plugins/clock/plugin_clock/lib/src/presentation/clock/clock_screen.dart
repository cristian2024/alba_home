import 'dart:async';
import 'dart:io';

import 'package:clock_domain/clock_domain.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_frame_contract/photo_frame_contract.dart';

import '../../i18n/strings.g.dart';
import '../common/clock_format.dart';
import 'clock_cubit.dart';

/// Medidas de la distribución B de Penpot (02.x), en el lienzo de 891 × 411.
abstract final class ClockLayout {
  static const double bannerTop = 24;
  static const double capsuleTop = 88;
  static const double progressTop = 164;
  static const double progressWidth = 280;
  static const double progressHeight = 8;
  static const double dateTop = 170;
  static const double clockTop = 194;
  static const double clockWidth = 572;
  static const double clockHeight = 205;
  static const double haloTop = 198;
  static const double haloWidth = 612;
  static const double haloHeight = 189;
  static const double blockTop = 267;
  static const double blockSide = 10;
  static const double blockWidth = 140;

  /// Mantener la hora abre ajustes (09.1).
  static const Duration settingsHold = Duration(seconds: 2);

  /// Un toque más corto que esto muestra la pista (02.9).
  static const Duration shortTap = Duration(milliseconds: 400);

  /// Cuánto se ve la pista.
  static const Duration hintVisible = Duration(seconds: 3);
}

/// El reloj (02.1 a 02.9): la foto del día con su degradado, la fecha, la
/// hora, hasta dos bloques de estado y el banner que gane. De noche, negro y
/// ámbar (02.3). Mantener la hora 2 s abre ajustes; un toque corto muestra
/// la pista.
class ClockScreen extends StatefulWidget {
  const ClockScreen({
    super.key,
    required this.wallClock,
    required this.onOpenSettings,
    required this.onOpenRoute,
  });

  final WallClock wallClock;
  final VoidCallback onOpenSettings;

  /// Al tocar un bloque con su propia pantalla.
  final ValueChanged<String> onOpenRoute;

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(vsync: this, duration: ClockLayout.settingsHold)
    ..addStatusListener(_onHoldStatus);
  Timer? _hintTimer;
  bool _hint = false;
  bool _pressing = false;

  void _onHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _pressing = false;
      _hold.value = 0;
      widget.onOpenSettings();
    }
  }

  void _onPressStart() {
    _pressing = true;
    _hintTimer?.cancel();
    setState(() => _hint = false);
    unawaited(_hold.forward(from: 0));
  }

  void _onPressEnd() {
    if (!_pressing) {
      return;
    }
    _pressing = false;
    final bool short = _hold.value * ClockLayout.settingsHold.inMilliseconds < ClockLayout.shortTap.inMilliseconds;
    _hold.value = 0;
    if (short) {
      setState(() => _hint = true);
      _hintTimer = Timer(ClockLayout.hintVisible, () {
        if (mounted) {
          setState(() => _hint = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ClockCubit, ClockState>(
        builder: (BuildContext context, ClockState state) => AnimatedBuilder(
          animation: _hold,
          builder: (BuildContext context, Widget? child) => _ClockFace(
            state: state,
            wallClock: widget.wallClock,
            holdProgress: _hold.value,
            showHint: _hint,
            onPressStart: _onPressStart,
            onPressEnd: _onPressEnd,
            onOpenSettings: widget.onOpenSettings,
            onOpenRoute: widget.onOpenRoute,
            onBannerAction: (String actionId) => unawaited(context.read<ClockCubit>().onBannerAction(actionId)),
          ),
        ),
      ),
    );
  }
}

class _ClockFace extends StatelessWidget {
  const _ClockFace({
    required this.state,
    required this.wallClock,
    required this.holdProgress,
    required this.showHint,
    required this.onPressStart,
    required this.onPressEnd,
    required this.onOpenSettings,
    required this.onOpenRoute,
    required this.onBannerAction,
  });

  final ClockState state;
  final WallClock wallClock;
  final double holdProgress;
  final bool showHint;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onOpenRoute;
  final ValueChanged<String> onBannerAction;

  @override
  Widget build(BuildContext context) {
    final ClockTranslations$clock$es clockTexts = clockStrings.clock;
    final AppThemeColors theme = AppThemeColors.of(context);
    final NightPhase phase = state.phase;
    final CurrentPhoto? photo = state.visiblePhoto;
    final AppTone tone = phase.isNight ? AppTone.night : (photo == null ? AppTone.surface : AppTone.photo);
    final DateTime local = wallClock.toLocal(state.now);
    final String time = ClockFormat.clock(local);
    final String date = ClockFormat.date(local);
    final bool holding = holdProgress > 0;
    final Color dateColor = switch (tone) {
      AppTone.surface => theme.textSecondary,
      AppTone.photo => theme.textOnPhoto,
      AppTone.night => AppNightColors.textSecondary,
    };
    final AmbientAlert? banner = state.banner;
    final List<AmbientStatus> statuses = state.statuses;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        return Stack(
          children: <Widget>[
            Positioned.fill(child: _Background(photo: photo, phase: phase, scrimOpacity: state.scrimOpacity)),
            if (!holding)
              Positioned(
                left: 0,
                right: 0,
                top: ClockLayout.dateTop,
                child: ExcludeSemantics(
                  child: Text(
                    date,
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitle.copyWith(color: dateColor),
                  ),
                ),
              ),
            if (holding)
              Positioned(
                left: (width - ClockLayout.haloWidth) / 2,
                top: ClockLayout.haloTop,
                width: ClockLayout.haloWidth,
                height: ClockLayout.haloHeight,
                child: _Halo(tone: tone),
              ),
            Positioned(
              left: (width - ClockLayout.clockWidth) / 2,
              top: ClockLayout.clockTop,
              width: ClockLayout.clockWidth,
              height: ClockLayout.clockHeight,
              child: Semantics(
                button: true,
                label: clockTexts.timeSemantic(time: time, date: date),
                onLongPress: onOpenSettings,
                excludeSemantics: true,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (PointerDownEvent event) => onPressStart(),
                  onPointerUp: (PointerUpEvent event) => onPressEnd(),
                  onPointerCancel: (PointerCancelEvent event) => onPressEnd(),
                  child: OverflowBox(
                    maxHeight: double.infinity,
                    alignment: Alignment.topCenter,
                    child: AppClockTime(time, tone: tone),
                  ),
                ),
              ),
            ),
            for (int i = 0; i < statuses.length; i++)
              Positioned(
                left: i == 0 ? ClockLayout.blockSide : null,
                right: i == 0 ? null : ClockLayout.blockSide,
                top: ClockLayout.blockTop,
                width: ClockLayout.blockWidth,
                child: _StatusBlock(status: statuses[i], tone: tone, onOpenRoute: onOpenRoute),
              ),
            if (holding || showHint)
              Positioned(
                left: 0,
                right: 0,
                top: ClockLayout.capsuleTop,
                child: Center(
                  child: AppStatusCapsule(
                    icon: holding ? AppIcons.settings : AppIcons.hand,
                    label: holding ? clockTexts.settings.holding : clockTexts.settings.hint,
                    tone: tone,
                  ),
                ),
              ),
            if (holding)
              Positioned(
                left: (width - ClockLayout.progressWidth) / 2,
                top: ClockLayout.progressTop,
                width: ClockLayout.progressWidth,
                height: ClockLayout.progressHeight,
                child: _Progress(value: holdProgress, tone: tone),
              ),
            if (banner != null && !holding && !showHint)
              Positioned(
                left: AppLayout.margin,
                right: AppLayout.margin,
                top: ClockLayout.bannerTop,
                child: _Banner(alert: banner, tone: tone, onAction: onBannerAction),
              ),
          ],
        );
      },
    );
  }
}

/// La foto con su degradado, el fondo liso sin fotos o el negro de noche. Al
/// acercarse la noche se va fundiendo a negro.
class _Background extends StatelessWidget {
  const _Background({required this.photo, required this.phase, required this.scrimOpacity});

  final CurrentPhoto? photo;
  final NightPhase phase;
  final double scrimOpacity;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final CurrentPhoto? current = photo;
    if (phase.isNight) {
      return const ColoredBox(color: AppNightColors.bg);
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColoredBox(color: theme.bgCanvas),
        if (current != null) ...<Widget>[
          Image.file(
            File(current.filePath),
            key: ValueKey<String>(current.id),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
                ColoredBox(color: theme.bgCanvas),
          ),
          AppPhotoScrim(opacity: scrimOpacity),
        ],
        if (phase.darkness > 0) ColoredBox(color: AppNightColors.bg.withValues(alpha: phase.darkness)),
      ],
    );
  }
}

/// El halo detrás de la hora mientras se mantiene (02.7).
class _Halo extends StatelessWidget {
  const _Halo({required this.tone});

  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final Color fill = switch (tone) {
      AppTone.photo => theme.bgOnPhoto,
      AppTone.surface => theme.bgSurfaceRaised,
      AppTone.night => AppNightColors.action,
    };
    final Color border = switch (tone) {
      AppTone.photo => theme.borderOnPhoto,
      AppTone.surface => theme.borderDefault,
      AppTone.night => AppNightColors.border,
    };
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(color: border, width: AppSizes.strokeThin),
        ),
      ),
    );
  }
}

/// La barra que se llena mientras se mantiene la hora (02.7).
class _Progress extends StatelessWidget {
  const _Progress({required this.value, required this.tone});

  final double value;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final AppThemeColors theme = AppThemeColors.of(context);
    final bool night = tone == AppTone.night;
    final Color track = switch (tone) {
      AppTone.photo => theme.borderOnPhoto,
      AppTone.surface => theme.borderDefault,
      AppTone.night => AppNightColors.border,
    };
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.full),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(color: track),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: ColoredBox(color: night ? AppNightColors.textPrimary : theme.actionPrimaryDefault),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un bloque de estado; si tiene pantalla propia, se puede tocar.
class _StatusBlock extends StatelessWidget {
  const _StatusBlock({required this.status, required this.tone, required this.onOpenRoute});

  final AmbientStatus status;
  final AppTone tone;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final String? route = status.route;
    final Widget block = AppStatusBlock(
      icon: AppIcons.byCodepoint(status.icon.codePoint) ?? AppIcons.info,
      value: status.label,
      label: status.detail ?? '',
      tone: tone,
      urgency: switch (status.urgency) {
        AmbientUrgency.normal => AppUrgency.normal,
        AmbientUrgency.warning => AppUrgency.warning,
        AmbientUrgency.urgent => AppUrgency.urgent,
      },
      semanticLabel: status.semanticLabel,
    );
    if (route == null) {
      return block;
    }
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onOpenRoute(route),
        child: block,
      ),
    );
  }
}

/// El banner que gana, con su primera acción.
class _Banner extends StatelessWidget {
  const _Banner({required this.alert, required this.tone, required this.onAction});

  final AmbientAlert alert;
  final AppTone tone;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final AmbientAlertAction? action = alert.actions.firstOrNull;
    return AppAlertBanner(
      icon: AppIcons.byCodepoint(alert.icon.codePoint) ?? AppIcons.info,
      title: alert.title,
      message: alert.message ?? '',
      actionLabel: action?.label ?? '',
      onAction: action == null ? null : () => onAction(action.id),
      variant: switch (tone) {
        AppTone.photo => AppBannerVariant.photo,
        AppTone.night => AppBannerVariant.night,
        AppTone.surface => switch (alert.urgency) {
            AmbientUrgency.normal => AppBannerVariant.info,
            AmbientUrgency.warning => AppBannerVariant.warning,
            AmbientUrgency.urgent => AppBannerVariant.critical,
          },
      },
    );
  }
}
