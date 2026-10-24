import 'dart:io';
import 'package:chocolate_clicks/screens/payment_summary_screen.dart';
import 'package:chocolate_clicks/services/payment_manager.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/models/cart_item.dart';
import 'package:chocolate_clicks/models/order_model.dart';
import 'package:chocolate_clicks/models/order_pricing.dart';
import 'package:chocolate_clicks/screens/orders_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Optional local screenshots use installed fonts; normal tests need no system fonts.
    if (const bool.fromEnvironment('CAPTURE_ORDER_UI') && Platform.isWindows) {
      for (final entry in {
        'Roboto': 'segoeui.ttf',
        'serif': 'georgia.ttf',
      }.entries) {
        final file = File('C:/Windows/Fonts/${entry.value}');
        if (await file.exists()) {
          final font = FontLoader(entry.key)
            ..addFont(
              Future.value(ByteData.sublistView(await file.readAsBytes())),
            );
          await font.load();
        }
      }
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    }
  });
  final order = Order(
    id: 'abc1234567890order',
    userId: 'user',
    items: [
      CartItem(
        id: 'cake',
        name: 'Chocolate Truffle Celebration Cake',
        price: 2500,
        quantity: 1,
        imageUrl: '',
      ),
    ],
    totalAmount: 3050,
    status: OrderStatus.preparing,
    createdAt: DateTime(2026, 10, 24),
    deliveryAddress: 'Sam Perera\n0771234567\n12 Flower Road\nColombo 06',
    pricing: const OrderPricing(
      subtotal: 2500,
      deliveryFee: 300,
      taxAmount: 250,
      taxRate: 10,
      totalAmount: 3050,
    ),
  );
  testWidgets('summary shows delivery and tax on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    PaymentManager.checkoutItems = order.items;
    addTearDown(() => PaymentManager.checkoutItems = null);
    const boundaryKey = ValueKey('summary-preview');
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        home: RepaintBoundary(
          key: boundaryKey,
          child: PaymentSummaryScreen(
            resolveItems: (items) async => items,
            quoteItems: (items, city) async => order.pricing!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Delivery fee'), findsOneWidget);
    expect(find.text('Tax (10%)'), findsOneWidget);
    expect(find.text('Rs. 3050.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_ORDER_UI')) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'build/order-summary-preview.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  for (final details in [false, true]) {
    testWidgets(
      'themed ${details ? 'progress' : 'history'} fits a narrow screen',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const boundaryKey = ValueKey('order-preview');
        await tester.pumpWidget(
          MaterialApp(
            home: RepaintBoundary(
              key: boundaryKey,
              child: details
                  ? OrderDetailsScreen(
                      order: order,
                      loadOrder: (_) async => order,
                    )
                  : OrdersScreen(loadOrders: () async => [order]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text(details ? 'Follow your order' : 'Made for you'),
          findsOneWidget,
        );
        if (const bool.fromEnvironment('CAPTURE_ORDER_UI')) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(boundaryKey),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'build/order-${details ? 'progress' : 'history'}-preview.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.drag(find.byType(ListView).first, const Offset(0, -650));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (!details) {
          await tester.drag(find.byType(ListView).first, const Offset(0, 650));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Completed'));
          await tester.pumpAndSettle();
          expect(find.text('No orders in this category yet.'), findsOneWidget);
        }
      },
    );
  }
}
