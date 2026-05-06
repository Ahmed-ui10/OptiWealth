import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

// Observer pattern interface for receiving notification events
abstract class NotificationObserver {
  void onNotification(NotificationModel notification);
}

// Singleton service for managing local push notifications and in-app notifications
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

  // Initialize the local notifications plugin and create notification channel
  Future<void> _initLocalNotifications() async {
    if (_initialized) return;
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Create Android notification channel
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

    // Configure initialization settings for both Android and iOS
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

  // Handle when user taps on a notification
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final parts = response.payload!.split(':');
      if (parts.length == 2 && parts[0] == 'userId') {
        final userId = int.tryParse(parts[1]);
        if (userId != null) {
          // Navigate to notifications screen
          navigatorKey.currentState?.pushNamed(
            '/notifications',
            arguments: userId,
          );
        }
      }
    }
  }

  // Get current datetime without milliseconds for consistent storage
  DateTime _nowWithoutMillis() =>
      DateTime.now().toLocal().copyWith(millisecond: 0, microsecond: 0);

  // Send a notification (saves to database, shows local notification, notifies observers)
  Future<void> notify(NotificationModel notification) async {
    // Create clean notification with consistent timestamp
    final cleanNotification = NotificationModel(
      notificationId: null,
      userId: notification.userId,
      type: notification.type,
      message: notification.message,
      isRead: notification.isRead,
      timestamp: _nowWithoutMillis(),
    );

    // Save to database and get the auto-generated ID
    final insertedId = await _notificationRepo.createNotification(
      cleanNotification,
    );
    cleanNotification.notificationId = insertedId;

    // Notify all observers (e.g., UI components)
    for (var observer in _observers) {
      observer.onNotification(cleanNotification);
    }

    // Show local push notification
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
      insertedId, // Unique ID for the notification
      cleanNotification.type == 'BUDGET_EXCEEDED'
          ? 'Budget Exceeded'
          : 'Budget Warning', // Title based on notification type
      cleanNotification.message,
      details,
      payload: 'userId:${cleanNotification.userId}', // Payload for navigation on tap
    );
  }

  // Observer management methods
  void addObserver(NotificationObserver observer) => _observers.add(observer);
  void removeObserver(NotificationObserver observer) =>
      _observers.remove(observer);

  // Retrieve all notifications for a specific user from database
  Future<List<NotificationModel>> getUserNotifications(int userId) async {
    return await _notificationRepo.getNotificationsByUser(userId);
  }
}