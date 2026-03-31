class NotificationResponse {
  final bool success;
  final List<NotificationItem> notifications;

  NotificationResponse({required this.success, required this.notifications});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'],
      notifications: (json['notifications'] as List)
          .map((e) => NotificationItem.fromJson(e))
          .toList(),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime createdAt;

  NotificationItem({
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}