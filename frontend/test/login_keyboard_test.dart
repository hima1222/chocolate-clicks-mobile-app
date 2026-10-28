import 'package:chocolate_clicks/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login scrolls with keyboard and validation errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('LOGIN'));
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 360);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign up here').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.style!.backgroundColor!.resolve({}), Colors.white);
  });
}
