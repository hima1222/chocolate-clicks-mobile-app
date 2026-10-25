import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/screens/categories_screen.dart';
import 'package:chocolate_clicks/screens/edit_profile_screen.dart';
import 'package:chocolate_clicks/screens/favourites_screen.dart';

void main() {
  testWidgets(
    'Category search hides unrelated cards and shows an empty result',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CategoriesScreen()));
      await tester.enterText(find.byType(TextField), 'cookies');
      await tester.pumpAndSettle();
      expect(find.text('Cookies'), findsOneWidget);
      expect(find.text('Cakes'), findsNothing);
      await tester.enterText(find.byType(TextField), 'nothing');
      await tester.pumpAndSettle();
      expect(find.text('No categories found'), findsOneWidget);
    },
  );

  for (final page in <Widget>[
    const CategoriesScreen(),
    const EditProfileScreen(),
    const FavouritesScreen(),
  ]) {
    testWidgets('${page.runtimeType} fits a narrow screen with larger text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.3),
            ),
            child: page,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -650));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Profile save validates fields before submitting', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditProfileScreen()));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Name required'), findsOneWidget);
    expect(find.text('Enter a valid phone number'), findsOneWidget);
  });
}
