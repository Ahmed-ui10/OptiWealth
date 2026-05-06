import '../database_helper.dart';
import '../../models/notification_model.dart';

// Repository class for handling Notification database operations
class NotificationRepository {
  final dbHelper = DatabaseHelper(); // Database helper instance

  // Create a new notification record in the database
  Future<int> createNotification(NotificationModel notification) async {
    final db = await dbHelper.db;
    return await db.insert('notifications', notification.toMap());
  }

  // Retrieve all notifications for a specific user, ordered by most recent first
  Future<List<NotificationModel>> getNotificationsByUser(int userId) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC', // Most recent notifications first
    );
    return maps.map((m) => NotificationModel.fromMap(m)).toList();
  }

  // Mark a specific notification as read (set isRead = 1)
  Future<int> markAsRead(int notificationId) async {
    final db = await dbHelper.db;
    return await db.update('notifications', {'isRead': 1},
        where: 'notificationId = ?', whereArgs: [notificationId]);
  }
}