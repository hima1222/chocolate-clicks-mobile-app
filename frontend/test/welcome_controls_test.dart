import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/screens/welcome_profile.dart';
import 'package:chocolate_clicks/screens/cake_type1.dart';
import 'package:chocolate_clicks/services/api_client.dart';

void main() {
  test('API errors preserve database validation messages', () {
    expect(
      ApiClient.errorMessage(
        '{"message":"Invalid email or password"}',
        'fallback',
      ),
      'Invalid email or password',
    );
    expect(
      ApiClient.errorMessage(
        '{"message":"User already exists with this email"}',
        'fallback',
      ),
      'User already exists with this email',
    );
    expect(ApiClient.errorMessage('bad response', 'fallback'), 'fallback');
  });

  testWidgets(
    'Welcome search filters products and View Item opens the selected detail',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeProfileScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), 'cake');
      await tester.pump();
      expect(find.text('Search results'), findsOneWidget);
      await tester.ensureVisible(find.text('View Item').first);
      await tester.tap(find.text('View Item').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(CakeType1Screen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Empty search results and profile shortcut work', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomeProfileScreen(),
        routes: {
          '/profile': (_) => const Scaffold(body: Text('Profile destination')),
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField), 'not-a-product');
    await tester.pump();
    expect(
      find.text('No items found. Try a different search.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('Recommended For You...'), findsOneWidget);
    await tester.tap(find.byTooltip('Open profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Profile destination'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
