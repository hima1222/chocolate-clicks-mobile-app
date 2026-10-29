import 'dart:js_interop';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:chocolate_clicks/services/payhere_web.dart';

@JS('eval')
external JSAny? evaluate(JSString source);

void main() {
  test(
    'hosted checkout posts signed fields and returns to orders without exposing secrets',
    () async {
      evaluate(
        'window.originalSubmit = HTMLFormElement.prototype.submit; HTMLFormElement.prototype.submit = function() { this.dataset.submitted = "true"; };'
            .toJS,
      );
      addTearDown(() {
        evaluate(
          'HTMLFormElement.prototype.submit = window.originalSubmit;'.toJS,
        );
      });
      var completed = false;
      startWebPayment({
        'sandbox': true,
        'merchant_id': '12345',
        'order_id': 'test',
        'hash': 'signed-test-hash',
        'amount': '4150.00',
        'currency': 'LKR',
        'items': 'Cake',
        'notify_url': 'https://api.example.com/api/payments/payhere/notify',
        'payment_method': 'VISA',
      }).then((_) => completed = true);
      final form = web.document.querySelector('form')! as web.HTMLFormElement;
      expect(form.action, 'https://sandbox.payhere.lk/pay/checkout');
      expect(form.method.toLowerCase(), 'post');
      expect(form.dataset['submitted'], 'true');
      String value(String name) =>
          (form.querySelector('input[name="$name"]')! as web.HTMLInputElement)
              .value;
      expect(value('hash'), 'signed-test-hash');
      expect(value('payment_method'), 'VISA');
      expect(Uri.parse(value('return_url')).fragment, '/orders');
      expect(value('cancel_url'), value('return_url'));
      expect(form.querySelector('input[name="merchant_secret"]'), isNull);
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);
      form.remove();
    },
  );
}
