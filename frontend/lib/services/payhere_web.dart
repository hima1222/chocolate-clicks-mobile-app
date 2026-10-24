import 'dart:async';
import 'dart:js_interop';

@JS('payhere')
external JSObject? get _payhere;
@JS('payhere.onCompleted')
external set _onCompleted(JSFunction callback);
@JS('payhere.onDismissed')
external set _onDismissed(JSFunction callback);
@JS('payhere.onError')
external set _onError(JSFunction callback);
@JS('payhere.startPayment')
external void _startPayment(JSObject payment);

Future<String?> startWebPayment(Map<String, dynamic> payment) async {
  if (_payhere == null) {
    throw Exception(
      'Unable to load PayHere. Check your connection and reload the page.',
    );
  }
  final done = Completer<String?>();
  void finish(String? message) {
    if (!done.isCompleted) done.complete(message);
  }

  _onCompleted = ((JSAny? _) => finish(null)).toJS;
  _onDismissed = (() => finish('Checkout dismissed.')).toJS;
  _onError = ((JSAny? error) => finish(
    'Checkout error: ${error.dartify()}',
  )).toJS;
  _startPayment(payment.jsify() as JSObject);
  return done.future;
}
