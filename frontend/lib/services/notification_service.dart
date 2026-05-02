/// Notification model
class Notification {
  final String id;
  final String title;
  final String message;
  final String type; // 'order', 'promo', 'system', etc.
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
    );
  }
}

/// Service for managing notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<Notification> _notifications = [];

  /// Fetch all notifications for user
  Future<List<Notification>> fetchNotifications() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // TODO: Replace with API call
      return _notifications.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO: Replace with API call
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        final n = _notifications[idx];
        _notifications[idx] = Notification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
          actionUrl: n.actionUrl,
        );
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO: Replace with API call
      for (int i = 0; i < _notifications.length; i++) {
        final n = _notifications[i];
        _notifications[i] = Notification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
          actionUrl: n.actionUrl,
        );
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Get unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Clear all notifications (on logout)
  void clear() {
    _notifications.clear();
  }
}
