import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chocolate_clicks/services/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'persisted login is ready before a gateway return loads orders',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'stored-test-token',
        'user_data': jsonEncode({
          '_id': 'customer',
          'firstName': 'Test',
          'lastName': 'Customer',
          'email': 'test@example.com',
          'phone': '0771234567',
          'createdAt': '2026-01-01T00:00:00Z',
        }),
      });
      final session = SessionManager();
      await session.ready;
      expect(session.token, 'stored-test-token');
      expect(session.user?.id, 'customer');
      expect(session.isLoggedIn, isTrue);
    },
  );
}
