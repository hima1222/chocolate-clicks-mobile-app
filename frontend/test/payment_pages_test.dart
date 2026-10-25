import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_clicks/screens/add_card_screen.dart';
import 'package:chocolate_clicks/screens/bank_transfer_screen.dart';
import 'package:chocolate_clicks/screens/digital_wallet_screen.dart';
import 'package:chocolate_clicks/screens/upi_payment_screen.dart';
import 'package:chocolate_clicks/widgets/payment_page.dart';

void main() {
  for (final page in <Widget>[
    const AddCardScreen(),
    const BankTransferScreen(),
    const DigitalWalletScreen(),
    const UPIPaymentScreen(),
  ]) {
    testWidgets(
      '${page.runtimeType} has a readable payment layout on a narrow screen',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 700),
                textScaler: TextScaler.linear(1.3),
              ),
              child: page,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PaymentPage), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView).first, const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Wallet selection and empty-field warning still work', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DigitalWalletScreen()));
    await tester.tap(find.text('Apple Pay'));
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.text('Please enter your email or phone number'),
      findsOneWidget,
    );
  });
}
