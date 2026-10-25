import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/widgets/app_image.dart';
import 'package:chocolate_clicks/services/cloudinary_images.dart';

void main() {
  testWidgets(
    'cloud URL falls back to the bundled original on network failure',
    (tester) async {
      const asset = 'assets/images/cake1.jpg';
      expect(cloudinaryImages[asset], startsWith('https://'));
      await tester.pumpWidget(
        MaterialApp(
          home: AppImage.asset(
            cloudinaryImages[asset]!,
            width: 100,
            height: 100,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(
        find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is AssetImage,
        ),
      );
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, asset);
      expect(tester.takeException(), isNull);
    },
  );
}
