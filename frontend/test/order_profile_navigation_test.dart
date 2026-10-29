import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/screens/orders_screen.dart';

void main() {
  for (final systemBack in [false, true]) {
    testWidgets(
      'order history returns to Profile using ${systemBack ? 'system back' : 'the back arrow'}',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/profile',
            routes: {
              '/': (_) => const Scaffold(body: Text('Home marker')),
              '/profile': (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/orders'),
                  child: const Text('Profile marker'),
                ),
              ),
              '/orders': (_) => OrdersScreen(loadOrders: () async => []),
            },
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Profile marker'));
        await tester.pumpAndSettle();
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byTooltip('Back'));
        }
        await tester.pumpAndSettle();
        expect(find.text('Profile marker'), findsOneWidget);
        expect(find.text('Order Details'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('direct order history entry also returns to Profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OrdersScreen(loadOrders: () async => []),
        routes: {
          '/profile': (_) => const Scaffold(body: Text('Profile marker')),
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Profile marker'), findsOneWidget);
    expect(find.text('Order Details'), findsNothing);
  });
}
