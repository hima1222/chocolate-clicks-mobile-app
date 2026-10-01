import 'package:chocolate_clicks/screens/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'expiry keeps its slash while typing and accepts a complete date',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddCardScreen()));
      final expiry = find.widgetWithText(TextFormField, 'Expiry Date');
      String text() => tester.widget<TextFormField>(expiry).controller!.text;

      await tester.enterText(expiry, '12');
      expect(text(), '12/');
      await tester.enterText(expiry, '12/2');
      expect(text(), '12/2');
      await tester.enterText(expiry, '12/29');
      expect(text(), '12/29');

      await tester.enterText(expiry, '');
      await tester.enterText(expiry, '1229');
      expect(text(), '12/29');
      await tester.enterText(expiry, '12/2');
      expect(text(), '12/2');
      await tester.enterText(expiry, '12/');
      await tester.enterText(expiry, '12');
      expect(text(), '12');
      await tester.enterText(expiry, '12/29');
      final field = tester.widget<TextFormField>(expiry);
      expect(field.validator!(text()), isNull);
      expect(field.validator!('13/29'), isNotNull);
    },
  );
  testWidgets('card and CVV limits and save-card toggle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCardScreen()));
    final number = find.widgetWithText(TextFormField, 'Card Number');
    await tester.enterText(number, '12345678901234567890');
    expect(
      tester.widget<TextFormField>(number).controller!.text,
      '1234 5678 9012 3456',
    );
    await tester.enterText(number, '1234 5678 9012 3456 7890');
    expect(
      tester.widget<TextFormField>(number).controller!.text,
      '1234 5678 9012 3456',
    );

    final cvv = find.widgetWithText(TextFormField, 'CVV');
    await tester.enterText(cvv, '12345');
    final field = tester.widget<TextFormField>(cvv);
    expect(field.controller!.text, '123');
    expect(field.validator!('12'), isNotNull);
    expect(field.validator!('123'), isNull);
    expect(field.validator!('1234'), isNotNull);

    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
  });
}
