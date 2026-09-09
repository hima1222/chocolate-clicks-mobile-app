import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/payment_service.dart';
import 'package:chocolate_clicks/models/payment_info.dart';

class PaymentInfoScreen extends StatefulWidget {
  const PaymentInfoScreen({super.key});

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
  final PaymentService _service = PaymentService();
  List<PaymentInfo> _methods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final methods = await _service.fetchPaymentMethods();
    setState(() {
      _methods = methods;
      _loading = false;
    });
  }

  Future<void> _remove(String id) async {
    await _service.removeMethod(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Info'),
        backgroundColor: Colors.brown[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _methods.isEmpty
            ? const Center(child: Text('No saved payment methods'))
            : ListView.separated(
                itemCount: _methods.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final pm = _methods[index];
                  return ListTile(
                    title: Text(pm.type.capitalize()),
                    subtitle: Text(pm.details),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _remove(pm.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// helper extension
extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return substring(0, 1).toUpperCase() + substring(1);
  }
}
