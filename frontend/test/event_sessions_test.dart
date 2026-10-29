import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/models/event_model.dart';
import 'package:chocolate_clicks/screens/events_screen.dart';
import 'package:chocolate_clicks/widgets/scheduled_event_page.dart';

EventModel session(
  String id, {
  int days = 2,
  int seats = 4,
  String title = 'Bake It Happen',
  String slug = '',
}) => EventModel(
  id: id,
  slug: slug,
  title: title,
  description: '',
  date: DateTime.now().add(Duration(days: days)),
  location: 'Cafe',
  price: 3500,
  imageUrl: '',
  capacity: 10,
  remainingSeats: seats,
);

Widget detail(Future<List<EventModel>> Function() load) => MaterialApp(
  home: ScheduledEventPage(
    title: 'Bake It Happen',
    eventSlug: 'bake-it-happen',
    subtitle: 'Create something sweet.',
    image: 'assets/images/bih1.jpg',
    gallery: const ['assets/images/bih2.jpeg'],
    description: 'Our baking experience description.',
    included: const ['Ingredients and guidance'],
    loadSessions: load,
  ),
);

ElevatedButton bookButton(WidgetTester tester) => tester.widget<ElevatedButton>(
  find.widgetWithText(ElevatedButton, 'Book Now'),
);

Future<void> showSessions(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -1600));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Category slug finds website sessions with a different display title',
    (tester) async {
      await tester.pumpWidget(
        detail(
          () async => [
            session(
              'website',
              title: 'Cake Baking Workshop',
              slug: 'bake-it-happen',
            ),
            session(
              'mask',
              title: 'Wes Mask Painting Workshop',
              slug: 'mask-painting-workshop',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(bookButton(tester).onPressed, isNotNull);
      await showSessions(tester);
      expect(find.text('4 seats available'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    },
  );
  testWidgets(
    'Catalog always shows the two supported experiences without dated sessions',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EventsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Bake It Happen'), findsOneWidget);
      expect(find.text('Mask Painting Workshop'), findsOneWidget);
      expect(find.text('No upcoming events yet.'), findsNothing);
      expect(find.text('Tasting LUXE'), findsNothing);
    },
  );

  testWidgets(
    'No future session preserves content and disables booking; refresh enables a new session',
    (tester) async {
      var events = <EventModel>[
        session('past', days: -1),
        session('other', title: 'Another Event'),
      ];
      await tester.pumpWidget(detail(() async => events));
      await tester.pumpAndSettle();
      expect(bookButton(tester).onPressed, isNull);
      expect(find.byType(Image), findsWidgets);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('Our baking experience description.'), findsOneWidget);
      await showSessions(tester);
      expect(
        find.text(
          'No sessions are currently scheduled for this event. We will update you soon.',
        ),
        findsOneWidget,
      );
      events = [session('new')];
      await tester.tap(find.text('Refresh sessions'));
      await tester.pumpAndSettle();
      expect(bookButton(tester).onPressed, isNotNull);
      expect(find.text('4 seats available'), findsOneWidget);
    },
  );

  testWidgets(
    'Future sessions can be selected; sold out session disables booking',
    (tester) async {
      await tester.pumpWidget(
        detail(
          () async => [
            session('full', seats: 0),
            session('available', days: 3),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(bookButton(tester).onPressed, isNotNull);
      await showSessions(tester);
      final field = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(field.initialValue, 'available');
      field.onChanged!('full');
      await tester.pumpAndSettle();
      expect(bookButton(tester).onPressed, isNull);
      expect(find.text('This session is fully booked.'), findsOneWidget);
    },
  );

  testWidgets('Failed schedule checks show retry and keep booking disabled', (
    tester,
  ) async {
    await tester.pumpWidget(detail(() async => throw Exception('offline')));
    await tester.pumpAndSettle();
    expect(bookButton(tester).onPressed, isNull);
    await showSessions(tester);
    expect(
      find.text('Unable to check sessions. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(
      find.text(
        'No sessions are currently scheduled for this event. We will update you soon.',
      ),
      findsNothing,
    );
  });
}
