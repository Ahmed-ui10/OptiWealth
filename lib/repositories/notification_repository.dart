import '../database_helper.dart';
import '../../models/notification_model.dart';

class NotificationRepository {
  final dbHelper = DatabaseHelper();

  Future<int> createNotification(NotificationModel notification) async {
    final db = await dbHelper.db;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<NotificationModel>> getNotificationsByUser(int userId) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => NotificationModel.fromMap(m)).toList();
  }

  Future<int> markAsRead(int notificationId) async {
    final db = await dbHelper.db;
    return await db.update('notifications', {'isRead': 1},
        where: 'notificationId = ?', whereArgs: [notificationId]);
  }
}