import 'package:alba/alba_app.dart';
import 'package:core_di/core_di.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('arranca y muestra el nombre', (WidgetTester tester) async {
    await tester.pumpWidget(AlbaApp(services: ServiceLocator()));

    expect(find.text('Alba'), findsOneWidget);
    expect(find.byType(ColoredBox), findsWidgets);
  });
}
