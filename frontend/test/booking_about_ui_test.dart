import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/models/event_model.dart';
import 'package:chocolate_clicks/screens/event_participants_screen.dart';
import 'package:chocolate_clicks/screens/about_us_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('CAPTURE_PAGES')) {
      for (final entry in {
        'Roboto': 'segoeui.ttf',
        'serif': 'georgia.ttf',
      }.entries) {
        final file = File('C:/Windows/Fonts/${entry.value}');
        final loader = FontLoader(entry.key)
          ..addFont(
            Future.value(ByteData.sublistView(await file.readAsBytes())),
          );
        await loader.load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });
  final event = EventModel(
    id: 'event',
    title: 'Wes Mask Painting Workshop',
    description: '',
    date: DateTime(2026, 11, 19, 10),
    location: 'Art Studio, No. 17, Stratford Avenue, Colombo 06',
    price: 5000,
    imageUrl: 'assets/images/c1.jpeg',
    remainingSeats: 2,
  );
  testWidgets('participant total updates and respects seat availability', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: const ValueKey('capture'),
          child: EventParticipantsScreen(event: event),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add person'));
    await tester.pumpAndSettle();
    expect(find.text('Rs. 10000.00'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Add person',
            ),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_PAGES')) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('capture')),
        );
        final image = await boundary.toImage();
        File('booking-preview.png').writeAsBytesSync(
          (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List(),
        );
      });
    }
  });
  testWidgets('about locations show photos and scroll on small screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: RepaintBoundary(key: ValueKey('capture'), child: AboutUsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Colombo cafe'), findsOneWidget);
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_PAGES')) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('capture')),
        );
        final image = await boundary.toImage();
        File('about-preview.png').writeAsBytesSync(
          (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List(),
        );
      });
    }
    await tester.drag(find.byType(ListView), const Offset(0, -1300));
    await tester.pumpAndSettle();
    expect(find.text('Gothenburg branch').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
