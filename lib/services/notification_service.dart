import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

abstract class NotificationObserver {
  void onNotification(NotificationModel notification);
}

class NotificationService {
  final List<NotificationObserver> _observers = [];
  final NotificationRepository _notificationRepo = NotificationRepository();

  void addObserver(NotificationObserver observer) => _observers.add(observer);
  void removeObserver(NotificationObserver observer) => _observers.remove(observer);

  Future<void> notify(NotificationModel notification) async {
    await _notificationRepo.createNotification(notification);
    for (var observer in _observers) {
      observer.onNotification(notification);
    }
  }

  Future<List<NotificationModel>> getUserNotifications(int userId) async {
    return await _notificationRepo.getNotificationsByUser(userId);
  }
}