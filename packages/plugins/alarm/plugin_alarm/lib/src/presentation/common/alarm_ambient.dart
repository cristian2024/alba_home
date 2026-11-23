import 'package:alarm_contract/alarm_contract.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:core_contracts/core_contracts.dart';
import 'package:design_system/design_system.dart';

import '../../domain/use_cases/ringing_use_cases.dart';
import '../../i18n/strings.g.dart';
import '../alarm_routes.dart';
import 'alarm_format.dart';

/// Prioridades de la alarma en la tabla de 09.2: menor número, más prioridad.
abstract final class AlarmPriorities {
  /// 1 · Alarma sonando, a pantalla completa.
  static const int ringing = 1;

  /// 4 · Alarmas sin permiso: banner y bloque urgente.
  static const int blocked = 4;

  /// La próxima alarma o la pospuesta, como bloque normal. Va detrás de todos
  /// los avisos de la tabla (que llegan a 9).
  static const int next = 10;
}

/// Ids de los avisos y de sus acciones, para `AmbientAlertSource.onAction`.
abstract final class AlarmAlertIds {
  static const String ringing = 'alarm.ringing';
  static const String blocked = 'alarm.blocked';
  static const String snooze = 'snooze';
  static const String dismiss = 'dismiss';
  static const String activate = 'activate';
}

/// Lo que la alarma publica para el reloj: cápsulas de estado y avisos, como
/// datos ya traducidos.
abstract final class AlarmAmbient {
  static const String sourceId = 'alarm';

  static AlarmTranslations$alarm$es get _strings => alarmStrings.alarm;

  /// La próxima alarma (o la pospuesta) como bloque; urgente si Android la
  /// bloquea.
  static List<AmbientStatus> statuses({required NextAlarm? next, required bool canRing, required WallClock wallClock}) {
    if (next == null) {
      return const <AmbientStatus>[];
    }
    final String time = AlarmFormat.localTime(next.ringsAt, wallClock);
    if (!canRing) {
      return <AmbientStatus>[
        AmbientStatus(
          id: 'alarm.next',
          sourceId: sourceId,
          icon: AppIcons.alarmOff.iconData,
          label: time,
          detail: _strings.permission.capsule,
          semanticLabel: _strings.permission.clockTitle(time: time),
          priority: AlarmPriorities.blocked,
          urgency: AmbientUrgency.urgent,
          route: AlarmRoutes.base,
        ),
      ];
    }
    return <AmbientStatus>[
      AmbientStatus(
        id: 'alarm.next',
        sourceId: sourceId,
        icon: next.isSnoozed ? AppIcons.timer.iconData : AppIcons.alarm.iconData,
        label: time,
        detail: next.isSnoozed ? _strings.snoozed.status : _strings.status.block,
        semanticLabel: next.isSnoozed ? _strings.snoozed.title(time: time) : _strings.status.blockSemantic(time: time),
        priority: AlarmPriorities.next,
        route: next.isSnoozed ? AlarmRoutes.snoozed : AlarmRoutes.base,
      ),
    ];
  }

  /// La alarma sonando a pantalla completa y, si Android bloquea las alarmas
  /// y hay alguna activa, el banner de 03.8.
  static List<AmbientAlert> alerts({
    required RingingAlarm? ringing,
    required NextAlarm? next,
    required bool canRing,
    required WallClock wallClock,
  }) {
    final List<AmbientAlert> alerts = <AmbientAlert>[];
    if (ringing != null && !ringing.session.isSnoozed) {
      final Alarm alarm = ringing.alarm;
      alerts.add(
        AmbientAlert(
          id: AlarmAlertIds.ringing,
          sourceId: sourceId,
          priority: AlarmPriorities.ringing,
          presentation: AmbientAlertPresentation.fullScreen,
          urgency: AmbientUrgency.urgent,
          icon: AppIcons.bellRing.iconData,
          title: AlarmFormat.label(alarm),
          message: AlarmFormat.paddedOf(alarm.time),
          actions: <AmbientAlertAction>[
            if (ringing.session.canSnooze(alarm))
              AmbientAlertAction(
                id: AlarmAlertIds.snooze,
                label: _strings.ringing.snooze(minutes: alarm.snooze.inMinutes),
                isPrimary: true,
              ),
            AmbientAlertAction(id: AlarmAlertIds.dismiss, label: _strings.ringing.holdToDismiss),
          ],
          route: AlarmRoutes.ringing,
        ),
      );
    }
    if (!canRing && next != null) {
      alerts.add(
        AmbientAlert(
          id: AlarmAlertIds.blocked,
          sourceId: sourceId,
          priority: AlarmPriorities.blocked,
          presentation: AmbientAlertPresentation.banner,
          urgency: AmbientUrgency.urgent,
          icon: AppIcons.alarmOff.iconData,
          title: _strings.permission.clockTitle(time: AlarmFormat.localTime(next.ringsAt, wallClock)),
          message: _strings.permission.bannerBody,
          actions: <AmbientAlertAction>[
            AmbientAlertAction(id: AlarmAlertIds.activate, label: _strings.permission.activate, isPrimary: true),
          ],
          route: AlarmRoutes.base,
        ),
      );
    }
    return alerts;
  }
}
