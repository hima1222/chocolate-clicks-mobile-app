import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/widgets/welcome_highlights.dart';
import 'package:chocolate_clicks/widgets/app_image.dart';
import 'package:chocolate_clicks/screens/profile_screen.dart';
import 'package:chocolate_clicks/screens/about_us_screen.dart';

void main() {
  testWidgets(
    'Event photos fill the compact frame before and after switching',
    (tester) async {
      Widget banner(String image, String title) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: WelcomeEventBanner(
              image: image,
              title: title,
              index: 0,
              count: 2,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        banner('assets/images/workshop_1.jpeg', 'Mask Painting Workshop'),
      );
      await tester.pumpAndSettle();
      final frame = find.byKey(const ValueKey('welcome-event-frame'));
      expect(tester.getSize(frame), const Size(320, 180));
      expect(tester.getSize(find.byType(AppImage)), tester.getSize(frame));
      await tester.pumpWidget(
        banner('assets/images/bih1.jpg', 'Bake It Happen'),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AppImage)), tester.getSize(frame));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Category pills fit side by side and remain tappable', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                WelcomeCategoryPill(label: 'Cake', onTap: () => tapped = true),
                WelcomeCategoryPill(label: 'Brownies', onTap: () {}),
                WelcomeCategoryPill(label: 'Cookies', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    final pills = find.byType(WelcomeCategoryPill);
    expect(tester.getSize(pills.first).width, lessThan(120));
    expect(
      tester.getTopLeft(pills.at(0)).dy,
      tester.getTopLeft(pills.at(1)).dy,
    );
    await tester.tap(find.text('Cake'));
    expect(tapped, isTrue);
  });

  testWidgets(
    'Profile preserves account links and opens About Us on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 740),
              textScaler: TextScaler.linear(1.3),
            ),
            child: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Update profile photo'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('About us'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('About us'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutUsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Gothenburg branch'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Gothenburg, Sweden'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('About Us contains the supplied branch and studio information', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutUsScreen()));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'No. 8, Stratford Avenue, Havelock Town, Colombo 06, Sri Lanka',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('+94 71 996 9798'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Art Studio by Chocolate Clicks'), findsOneWidget);
    expect(find.text('Open daily · 10:30 AM – 6:00 PM'), findsOneWidget);
  });
}
