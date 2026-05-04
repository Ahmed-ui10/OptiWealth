class NotificationModel {
  int? notificationId;
  int userId;
  String type;
  String message;
  bool isRead;
  DateTime timestamp;

  NotificationModel({
    this.notificationId,
    required this.userId,
    required this.type,
    required this.message,
    this.isRead = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'type': type,
      'message': message,
      'isRead': isRead ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
    if (notificationId != null && notificationId != 0) {
      map['notificationId'] = notificationId;
    }
    return map;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        notificationId: map['notificationId'],
        userId: map['userId'],
        type: map['type'],
        message: map['message'],
        isRead: map['isRead'] == 1,
        timestamp: DateTime.parse(map['timestamp']),
      );
}
