class NotificationModel
{
  int notificationId;
  String type;
  String message;
  bool isRead;
  DateTime timestamp;

  NotificationModel({
    required this.notificationId,
    required this.type,
    required this.message,
    this.isRead = false,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json)
  {
    return NotificationModel(
      notificationId: json['notificationId'],
      type: json['type'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'notificationId': notificationId,
      'type': type,
      'message': message,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  void send() {}

  void markAsRead()
  {
    isRead = true;
  }
}
