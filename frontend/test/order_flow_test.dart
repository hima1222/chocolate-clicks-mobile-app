import 'package:flutter/gestures.dart';
import 'package:chocolate_clicks/models/order_pricing.dart';
import 'package:chocolate_clicks/services/payment_service.dart';
import 'package:chocolate_clicks/services/cart_service.dart';
import 'package:chocolate_clicks/models/event_model.dart';
import 'package:chocolate_clicks/screens/upcoming_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/models/order_model.dart';
import 'package:chocolate_clicks/models/cart_item.dart';
import 'package:chocolate_clicks/services/payment_manager.dart';
import 'package:chocolate_clicks/screens/payment_summary_screen.dart';

void main() {
  test('parses populated backend orders and event orders', () {
    final order = Order.fromJson({
      '_id': 'order-1',
      'user': 'user-1',
      'status': 'preparing',
      'totalAmount': 600,
      'createdAt': '2026-10-24T00:00:00Z',
      'items': [
        {
          'product': {'_id': 'product-1', 'imageUrl': 'cake.jpg'},
          'name': 'Cake',
          'price': 300,
          'quantity': 2,
        },
      ],
    });
    expect(order.id, 'order-1');
    expect(order.items.single.id, 'product-1');
    expect(order.items.single.totalPrice, 600);
    expect(order.status, OrderStatus.preparing);
    final event = Order.fromJson({
      '_id': 'event-order',
      'user': 'user-1',
      'items': [],
      'totalAmount': 2500,
      'createdAt': '2026-10-24T00:00:00Z',
      'eventTitle': 'Workshop',
      'payment_status': 'paid',
      'status': 'confirmed',
    });
    expect(event.eventTitle, 'Workshop');
    expect(event.paymentStatus, 'paid');
  });
  test(
    'paid cart removal consumes purchased quantity once and preserves other items',
    () async {
      final cart = CartService();
      cart.clear();
      await cart.addOrUpdateItem(
        CartItem(
          id: 'asset-cookie',
          name: 'Cookies',
          price: 250,
          quantity: 5,
          imageUrl: '',
        ),
      );
      await cart.addOrUpdateItem(
        CartItem(
          id: 'asset-cake',
          name: 'Cake',
          price: 1000,
          quantity: 1,
          imageUrl: '',
        ),
      );
      final purchased = [
        CartItem(
          id: 'database-cookie',
          name: 'Cookies',
          price: 250,
          quantity: 2,
          imageUrl: '',
        ),
      ];
      cart.trackCheckout('order-paid');
      cart.removePaidItems('order-paid', purchased);
      cart.removePaidItems('order-paid', purchased);
      final remaining = await cart.fetchCartItems();
      expect(
        remaining.firstWhere((item) => item.name == 'Cookies').quantity,
        3,
      );
      expect(remaining.firstWhere((item) => item.name == 'Cake').quantity, 1);
      cart.clear();
    },
  );
  test('missing or null checkout responses produce a recoverable message', () {
    expect(
      () => PaymentService.checkoutPayload({'checkout': null}),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => PaymentService.orderData({'data': null}),
      throwsA(isA<FormatException>()),
    );
    expect(
      PaymentService.checkoutPayload({
        'checkout': {'order_id': 'o', 'amount': '1207.50'},
      })['amount'],
      '1207.50',
    );
  });
  testWidgets(
    'upcoming events lays out and accepts mouse movement on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: UpcomingEventsScreen(
            loadEvents: () async => [
              EventModel(
                id: 'e1',
                title: 'Chocolate workshop',
                description: 'Create chocolate treats.',
                date: DateTime(2027),
                location: 'Colombo',
                price: 2500,
                imageUrl: '',
                remainingSeats: 10,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chocolate workshop'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(100, 400));
      await mouse.moveTo(const Offset(150, 500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('My Bookings'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await mouse.removePointer();
    },
  );
  testWidgets(
    'summary uses selected quantities and prices without sample recipient',
    (tester) async {
      PaymentManager.checkoutItems = [
        CartItem(
          id: 'p',
          name: 'Custom cookies',
          price: 275,
          quantity: 3,
          imageUrl: '',
        ),
      ];
      addTearDown(() => PaymentManager.checkoutItems = null);
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentSummaryScreen(
            resolveItems: (items) async => items,
            quoteItems: (items, city) async => OrderPricing(
              subtotal: 825,
              deliveryFee: city == 'Kandy' ? 500 : 300,
              taxAmount: 82.5,
              taxRate: 10,
              totalAmount: city == 'Kandy' ? 1407.5 : 1207.5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Custom cookies'), findsOneWidget);
      expect(find.text('Qty: 3'), findsOneWidget);
      expect(find.text('Rs. 1207.50'), findsOneWidget);
      expect(find.text('Tax (10%)'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(1), 'Kandy');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Rs. 1407.50'), findsOneWidget);
      expect(find.text('Himara Perera'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
