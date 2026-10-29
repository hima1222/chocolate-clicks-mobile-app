import 'dart:async';
import 'package:web/web.dart' as web;

/// Use PayHere's documented form checkout. Unlike the popup SDK this does not
/// depend on a synchronous cross-origin XMLHttpRequest to initialize payment.
Future<String?> startWebPayment(Map<String, dynamic> payment) {
  final returnUrl = Uri.base.replace(fragment: '/orders').toString();
  final fields = <String, dynamic>{
    ...payment,
    'return_url': returnUrl,
    'cancel_url': returnUrl,
  }..remove('sandbox');
  if (fields.containsKey('merchant_secret')) {
    throw StateError(
      'The server must sign web checkout without exposing a secret.',
    );
  }
  final form = web.HTMLFormElement()
    ..method = 'POST'
    ..action = payment['sandbox'] == true
        ? 'https://sandbox.payhere.lk/pay/checkout'
        : 'https://www.payhere.lk/pay/checkout';
  form.style.display = 'none';
  for (final field in fields.entries) {
    if (field.value == null) continue;
    form.appendChild(
      web.HTMLInputElement()
        ..type = 'hidden'
        ..name = field.key
        ..value = field.value.toString(),
    );
  }
  web.document.body!.appendChild(form);
  form.submit();
  // The browser leaves this page. Returning here would incorrectly advance the
  // order flow before the shopper has selected a method and entered card data.
  return Completer<String?>().future;
}
