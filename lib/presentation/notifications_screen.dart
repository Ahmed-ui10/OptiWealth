import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../locale_provider.dart';
import '../../models/notification_model.dart';
import 'widgets/custom_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  final int userId;
  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

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
      title: isArabic ? 'الإشعارات' : 'Notifications',
      showBackButton: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFF5B042),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (ctx, i) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFF2A3A4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _notifications[i].isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: _notifications[i].isRead
                          ? Colors.grey
                          : const Color(0xFFF5B042),
                    ),
                    title: Text(
                      _notifications[i].message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _notifications[i].timestamp.toLocal().toString(),
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
