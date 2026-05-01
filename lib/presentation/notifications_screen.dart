import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../locale_provider.dart';
import '../../models/notification_model.dart';

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
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'الإشعارات' : 'Notifications')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: Icon(_notifications[i].isRead ? Icons.notifications_none : Icons.notifications_active),
                title: Text(_notifications[i].message),
                subtitle: Text(_notifications[i].timestamp.toLocal().toString()),
              ),
            ),
    );
  }
}