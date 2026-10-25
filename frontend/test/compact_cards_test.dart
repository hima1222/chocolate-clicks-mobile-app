import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/screens/categories_screen.dart';
import 'package:chocolate_clicks/screens/events_screen.dart';
import 'package:chocolate_clicks/widgets/compact_shop_grid.dart';

void main() {
  for (final page in [const CategoriesScreen(), const EventsScreen()]) {
    testWidgets('${page.runtimeType} displays two columns on a small phone', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 800),
              textScaler: TextScaler.linear(1.3),
            ),
            child: page,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final cards = find.byType(CompactShopCard);
      final first = tester.getTopLeft(cards.at(0));
      final second = tester.getTopLeft(cards.at(1));
      expect(first.dy, second.dy);
      expect(second.dx, greaterThan(first.dx));
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final systemBack in [false, true]) {
    testWidgets(
      'Categories ${systemBack ? 'system' : 'button'} back opens welcome profile',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const CategoriesScreen(),
            routes: {
              '/welcome_profile': (_) =>
                  const Scaffold(body: Text('Welcome profile destination')),
              '/home': (_) => const Scaffold(body: Text('Home destination')),
            },
          ),
        );
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byTooltip('Back'));
        }
        await tester.pumpAndSettle();
        expect(find.text('Welcome profile destination'), findsOneWidget);
        expect(find.text('Home destination'), findsNothing);
      },
    );
  }
}
