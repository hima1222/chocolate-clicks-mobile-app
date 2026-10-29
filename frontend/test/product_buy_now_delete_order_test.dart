import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/screens/cake_type1.dart';
import 'package:chocolate_clicks/screens/brownies_type1.dart';
import 'package:chocolate_clicks/screens/cookies_type1.dart';
import 'package:chocolate_clicks/screens/orders_screen.dart';
import 'package:chocolate_clicks/models/order_model.dart';
import 'package:chocolate_clicks/services/payment_manager.dart';
import 'package:chocolate_clicks/services/payment_service.dart';

void main() {
  final product = <String, dynamic>{
    'id': 'catalog-product',
    'title': 'Chocolate delight',
    'price': 3500,
    'image': 'assets/images/cake_type1.jpg',
    'quantity': 5,
  };
  final pages = <String, Widget Function(Map<String, dynamic>)>{
    'cake': (p) => CakeType1Screen(product: p),
    'brownie': (p) => BrowniesType1Screen(product: p),
    'cookie': (p) => CookiesType1Screen(product: p),
  };
  for (final entry in pages.entries) {
    testWidgets(
      '${entry.key} Buy Now checks out the displayed product without the cart',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: entry.value(product),
            routes: {
              '/payment_summary': (_) =>
                  const Scaffold(body: Text('Checkout destination')),
            },
          ),
        );
        await tester.tap(find.text('Buy Now'));
        await tester.pumpAndSettle();
        expect(find.text('Checkout destination'), findsOneWidget);
        expect(PaymentManager.checkoutItems!.single.id, 'catalog-product');
        expect(PaymentManager.checkoutItems!.single.price, 3500);
        expect(PaymentManager.checkoutItems!.single.quantity, 1);
        expect(PaymentManager.checkoutFromCart, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('${entry.key} cannot buy an out-of-stock product', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: entry.value({...product, 'quantity': 0})),
      );
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Buy Now'),
      );
      expect(button.onPressed, isNull);
    });
  }
  Order order(OrderStatus status) => Order(
    id: 'order-id',
    userId: 'user',
    items: [],
    totalAmount: 4150,
    status: status,
    createdAt: DateTime(2026, 10, 29),
    paymentStatus: 'pending',
  );
  testWidgets(
    'delete incomplete order requires confirmation and returns to history',
    (tester) async {
      var removed = false;
      final pending = order(OrderStatus.pending);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('History'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(
                      order: pending,
                      loadOrder: (_) async => pending,
                      deleteOrder: (_) async {
                        removed = true;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Delete incomplete order'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Delete incomplete order'));
      await tester.pumpAndSettle();
      expect(removed, isFalse);
      await tester.tap(find.text('Delete order'));
      await tester.pumpAndSettle();
      expect(removed, isTrue);
      expect(find.text('History'), findsOneWidget);
    },
  );
  testWidgets('completed order has no delete action', (tester) async {
    final completed = order(OrderStatus.completed);
    await tester.pumpWidget(
      MaterialApp(
        home: OrderDetailsScreen(
          order: completed,
          loadOrder: (_) async => completed,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Delete incomplete order'), findsNothing);
  });
  test('native authorization failure has useful customer-facing guidance', () {
    expect(
      PaymentService.nativePaymentError('Unauthorized domain'),
      contains('could not authorize this mobile app'),
    );
    expect(
      PaymentService.nativePaymentError('Network unavailable'),
      contains('Network unavailable'),
    );
  });
}
