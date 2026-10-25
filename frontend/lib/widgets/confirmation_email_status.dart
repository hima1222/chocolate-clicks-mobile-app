import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/api_client.dart';
import 'package:chocolate_clicks/services/auth_service.dart';

class ConfirmationEmailStatus extends StatefulWidget {
  const ConfirmationEmailStatus({super.key, required this.orderId});
  final String orderId;
  @override
  State<ConfirmationEmailStatus> createState() => _ConfirmationEmailStatusState();
}

class _ConfirmationEmailStatusState extends State<ConfirmationEmailStatus> {
  String _status = 'loading';
  bool _busy = false;
  String? _message;
  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${AuthService().authToken ?? ''}',
  };

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final response = await ApiClient().get(
        '/orders/${widget.orderId}/confirmation', headers: _headers);
      if (mounted) setState(() {
        _status = response['data']['emailStatus'] as String;
        _message = null;
      });
    } catch (_) {
      if (mounted) setState(() => _status = 'unknown');
    }
  }

  Future<void> _resend() async {
    setState(() { _busy = true; _message = null; });
    try {
      await ApiClient().post('/orders/${widget.orderId}/resend-confirmation',
        body: {}, headers: _headers);
      if (mounted) setState(() => _status = 'queued');
    } catch (error) {
      if (mounted) setState(() => _message = error is ApiException
        ? error.message : 'Unable to request email. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = {
      'loading': 'Checking confirmation email...',
      'queued': 'Confirmation email: queued',
      'sending': 'Confirmation email: sending',
      'sent': 'Confirmation email: sent',
      'failed': 'Confirmation email: failed. Your booking remains confirmed.',
      'unavailable': 'Confirmation email unavailable',
      'unknown': 'Unable to check confirmation email',
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(labels[_status] ?? 'Confirmation email: unknown',
        style: const TextStyle(color: Color(0xFF795548))),
      if (_message != null) Text(_message!, style: const TextStyle(color: Colors.red)),
      Wrap(children: [
        if (_status == 'sent' || _status == 'failed')
          TextButton(onPressed: _busy ? null : _resend,
            child: Text(_busy ? 'Requesting...' : 'Resend confirmation')),
        TextButton(onPressed: _busy ? null : _refresh, child: const Text('Refresh email status')),
      ]),
    ]);
  }
}
