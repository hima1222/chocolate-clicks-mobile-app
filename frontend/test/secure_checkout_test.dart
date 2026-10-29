import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/screens/secure_checkout_screen.dart';

void main() {
  const payment = {
    'items': 'Cake x 1',
    'amount': '4150.00',
    'currency': 'LKR',
    'order_id': 'test-order',
  };
  testWidgets(
    'payment step stays open on gateway errors and lets shoppers retry',
    (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: SecureCheckoutScreen(
            payment: payment,
            launch: (_) async {
              attempts++;
              return 'Checkout dismissed.';
            },
          ),
        ),
      );
      expect(find.text('Complete your payment'), findsOneWidget);
      expect(find.text('LKR 4150.00'), findsOneWidget);
      await tester.tap(find.text('Continue to PayHere'));
      await tester.pumpAndSettle();
      expect(attempts, 1);
      expect(find.text('Checkout dismissed.'), findsOneWidget);
      expect(find.text('Complete your payment'), findsOneWidget);
      await tester.tap(find.text('Continue to PayHere'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'gateway completion returns submitted and does not claim verified payment',
    (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SecureCheckoutScreen(
                        payment: payment,
                        launch: (_) async => null,
                      ),
                    ),
                  );
                },
                child: const Text('Open payment'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open payment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue to PayHere'));
      await tester.pumpAndSettle();
      expect(result, 'submitted');
      expect(find.text('Open payment'), findsOneWidget);
    },
  );
}
