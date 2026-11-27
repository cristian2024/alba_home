import 'package:clock_example/main.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('arranca en los controles y abre el reloj a la hora pedida', (WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(AppLayout.screenWidth, AppLayout.screenHeight)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ExampleWorld world = ExampleWorld(photoPath: '/no/existe.png', refreshEvery: null);
    await world.start();

    await tester.pumpWidget(ClockExampleApp(world: world));
    await tester.pumpAndSettle();
    expect(find.text('23:17'), findsOneWidget);

    await tester.tap(find.text('23:17'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AppClockTime), findsOneWidget);
    await world.plugin.dispose();
  });
}
