import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

abstract class NotificationObserver {
  void onNotification(NotificationModel notification);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _initLocalNotifications();
  }

  final List<NotificationObserver> _observers = [];
  final NotificationRepository _notificationRepo = NotificationRepository();
  late final FlutterLocalNotificationsPlugin _localNotifications;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  bool _initialized = false;

  Future<void> _initLocalNotifications() async {
    if (_initialized) return;
    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'budget_channel',
      'Budget Alerts',
      description: 'Notifications for budget limits and goals',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final parts = response.payload!.split(':');
      if (parts.length == 2 && parts[0] == 'userId') {
        final userId = int.tryParse(parts[1]);
        if (userId != null) {
          navigatorKey.currentState?.pushNamed(
            '/notifications',
            arguments: userId,
          );
        }
      }
    }
  }

  DateTime _nowWithoutMillis() =>
      DateTime.now().toLocal().copyWith(millisecond: 0, microsecond: 0);

  Future<void> notify(NotificationModel notification) async {
    final cleanNotification = NotificationModel(
      notificationId: null,
      userId: notification.userId,
      type: notification.type,
      message: notification.message,
      isRead: notification.isRead,
      timestamp: _nowWithoutMillis(),
    );

    final insertedId = await _notificationRepo.createNotification(
      cleanNotification,
    );
    cleanNotification.notificationId = insertedId;

    for (var observer in _observers) {
      observer.onNotification(cleanNotification);
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'budget_channel',
          'Budget Alerts',
          channelDescription: 'Notifications for budget limits and goals',
          importance: Importance.high,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _localNotifications.show(
      insertedId,
      cleanNotification.type == 'BUDGET_EXCEEDED'
          ? 'Budget Exceeded'
          : 'Budget Warning',
      cleanNotification.message,
      details,
      payload: 'userId:${cleanNotification.userId}',
    );
  }

  void addObserver(NotificationObserver observer) => _observers.add(observer);
  void removeObserver(NotificationObserver observer) =>
      _observers.remove(observer);

  Future<List<NotificationModel>> getUserNotifications(int userId) async {
    return await _notificationRepo.getNotificationsByUser(userId);
  }
}
