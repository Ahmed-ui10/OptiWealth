import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../locale_provider.dart';
import '../../models/notification_model.dart';
import 'widgets/custom_scaffold.dart';

// Screen for displaying user notifications
class NotificationsScreen extends StatefulWidget {
  final int userId;
  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = []; // List of user notifications
  bool _loading = true; // Loading state for data fetch

  @override
  void initState() {
    super.initState();
    _load(); // Load notifications when screen initializes
  }

  // Load notifications from service
  Future<void> _load() async {
    setState(() => _loading = true);
    final notifs = await _service.getUserNotifications(widget.userId);
    setState(() {
      _notifications = notifs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'الإشعارات' : 'Notifications', // Dynamic title based on language
      showBackButton: false,
      hideMenu: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load, // Pull-to-refresh functionality
              color: const Color(0xFFF5B042), // Orange refresh indicator
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (ctx, i) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFF2A3A4A), // Dark card background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  child: ListTile(
                    leading: Icon(
                      // Different icon based on read/unread status
                      _notifications[i].isRead
                          ? Icons.notifications_none // Outline icon for read
                          : Icons.notifications_active, // Filled icon for unread
                      color: _notifications[i].isRead
                          ? Colors.grey // Grey for read notifications
                          : const Color(0xFFF5B042), // Orange for unread
                    ),
                    title: Text(
                      _notifications[i].message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _notifications[i].timestamp.toLocal().toString(), // Format timestamp to local time
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}