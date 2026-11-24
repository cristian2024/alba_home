import 'package:alarm_domain/alarm_domain.dart';
import 'package:alarm_domain/testing.dart';
import 'package:alarm_example/main.dart';
import 'package:core_alarm_scheduler/core_alarm_scheduler.dart';
import 'package:core_alarm_scheduler/testing.dart';
import 'package:core_di/core_di.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_alarm/plugin_alarm.dart';

void main() {
  testWidgets('arranca en la lista de alarmas vacía', (WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(AppLayout.screenWidth, AppLayout.screenHeight)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ServiceLocator locator = ServiceLocator();
    final InMemoryAlarmScheduler scheduler = InMemoryAlarmScheduler();
    locator
      ..registerSingleton<AlarmRepository>(InMemoryAlarmRepository())
      ..registerSingleton<AlarmScheduler>(scheduler);
    final AlarmPlugin plugin = AlarmPlugin(locator: locator, refreshEvery: null);
    await plugin.initialize();

    await tester.pumpWidget(AlarmExampleApp(plugin: plugin, scheduler: scheduler));
    await tester.pumpAndSettle();

    expect(find.text('No hay alarmas'), findsOneWidget);
    await plugin.dispose();
  });
}
