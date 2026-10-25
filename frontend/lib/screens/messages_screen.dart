import 'package:flutter/material.dart' hide Notification;
import 'package:chocolate_clicks/services/notification_service.dart';
import 'package:chocolate_clicks/widgets/app_image.dart';
import 'package:chocolate_clicks/services/auth_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final NotificationService _service = NotificationService();
  List<Notification> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final messages = await _service.fetchNotifications();
      if (!mounted) return;
      setState(() => _messages = messages);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      if (!mounted) return;
      setState(() => _messages = _messages.map(_asRead).toList());
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _markAsRead(Notification message) async {
    if (message.isRead) return;
    try {
      await _service.markAsRead(message.id);
      if (!mounted) return;
      setState(() {
        final index = _messages.indexWhere((item) => item.id == message.id);
        if (index != -1) _messages[index] = _asRead(message);
      });
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Notification _asRead(Notification message) {
    return Notification(
      id: message.id,
      title: message.title,
      message: message.message,
      type: message.type,
      createdAt: message.createdAt,
      isRead: true,
      actionUrl: message.actionUrl,
    );
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }

  String _relativeTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt.toLocal());
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'event':
        return Icons.event_available_outlined;
      case 'product':
        return Icons.cake_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'order':
        return Icons.receipt_long_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _messages.where((message) => !message.isRead).length;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AppImage.asset(
              'assets/images/cafe_background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xD914100D), Color(0xF0291C14)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFF6E6D7),
                          ),
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/welcome_profile',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Messages',
                          style: TextStyle(
                            color: Color(0xFFF6E6D7),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: _markAllAsRead,
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(color: Color(0xFFF8B84E)),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF8B84E),
                          ),
                        )
                      : _error != null
                          ? _buildErrorState()
                          : RefreshIndicator(
                              color: const Color(0xFFF8B84E),
                              onRefresh: _loadMessages,
                              child: _messages.isEmpty
                                  ? ListView(
                                      children: const [
                                        SizedBox(height: 220),
                                        Center(
                                          child: Text(
                                            'No messages yet',
                                            style: TextStyle(
                                              color: Color(0xFFF6E6D7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        6,
                                        12,
                                        6,
                                        20,
                                      ),
                                      itemCount: _messages.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) =>
                                          _buildMessageCard(_messages[index]),
                                    ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Could not load messages',
              style: TextStyle(
                color: Color(0xFFF6E6D7),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _loadMessages,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(Notification message) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _markAsRead(message),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isRead
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: message.isRead
                ? Colors.white.withValues(alpha: 0.14)
                : const Color(0xFFF8B84E).withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF6E6D7),
              child: Icon(
                _iconForType(message.type),
                color: Colors.brown.shade900,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          message.title,
                          style: TextStyle(
                            color: const Color(0xFFF6E6D7),
                            fontSize: 15,
                            fontWeight: message.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _relativeTime(message.createdAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

