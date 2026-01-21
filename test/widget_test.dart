import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/app.dart';

void main() {
  testWidgets('Landing screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the landing screen elements are present.
    expect(find.text('We believe in the'), findsOneWidget);
    expect(find.text('Power of Backed Goods'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}