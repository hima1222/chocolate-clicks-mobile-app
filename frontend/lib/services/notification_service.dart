import 'package:chocolate_clicks/services/api_client.dart';
import 'package:chocolate_clicks/services/auth_service.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: (json['id'] ?? json['_id']) as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  void clear() {}

  Future<List<Notification>> fetchNotifications() async {
    final token = AuthService().authToken;
    if (token == null) throw Exception('Authentication required');

    final response = await ApiClient().get(
      '/notifications',
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response['success'] != true || response['data'] is! List) {
      throw Exception(response['message'] ?? 'Failed to fetch notifications');
    }

    return (response['data'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Notification.fromJson)
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    final token = AuthService().authToken;
    if (token == null) throw Exception('Authentication required');
    await ApiClient().patch(
      '/notifications/$notificationId/read',
      headers: {'Authorization': 'Bearer $token'},
      body: {},
    );
  }

  Future<void> markAllAsRead() async {
    final token = AuthService().authToken;
    if (token == null) throw Exception('Authentication required');
    await ApiClient().patch(
      '/notifications/read-all',
      headers: {'Authorization': 'Bearer $token'},
      body: {},
    );
  }
}
