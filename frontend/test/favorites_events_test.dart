import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/widgets/favorite_button.dart';
import 'package:chocolate_clicks/screens/favourites_screen.dart';
import 'package:chocolate_clicks/services/favorites_service.dart';
import 'package:chocolate_clicks/screens/backing_goods.dart';
import 'package:chocolate_clicks/screens/bake_it_happen_screen.dart';
import 'package:chocolate_clicks/screens/cake_dates_screen.dart';
import 'package:chocolate_clicks/screens/mask_painting_workshop_screen.dart';
import 'package:chocolate_clicks/screens/tasting_luxe_screen.dart';
import 'package:chocolate_clicks/screens/summer_cake_picnics_screen.dart';

void main() {
  setUp(() => FavoritesService().clear());

  testWidgets(
    'Saving an item updates other hearts and displays its asset in favourites',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FavoriteButton(name: 'Cake', image: 'assets/images/cake1.jpg'),
                FavoriteButton(name: 'Cake', image: 'assets/images/cake1.jpg'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Add to favourites').first);
      await tester.pumpAndSettle();
      expect(FavoritesService().count, 1);
      expect(find.byTooltip('Remove from favourites'), findsNWidgets(2));

      await tester.pumpWidget(const MaterialApp(home: FavouritesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Cake'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(FavoritesService().count, 0);
      expect(find.text('No favourites yet'), findsOneWidget);
    },
  );

  for (final page in <Widget>[
    const BakingGoodsScreen(),
    const BakeItHappenScreen(),
    const CakeDatesScreen(),
    const MaskPaintingWorkshopScreen(),
    const TastingLuxeScreen(),
    const SummerCakePicnicsScreen(),
  ]) {
    testWidgets(
      '${page.runtimeType} scrolls on a small screen without an intro slide',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pumpAndSettle();
        expect(find.text('Next'), findsNothing);
        expect(find.text('Plan this experience'), findsOneWidget);
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1000),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
