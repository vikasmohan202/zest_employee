class NotificationResponse {
  final bool success;
  final int total;
  final int page;
  final int totalPages;
  final List<NotificationModel> notifications;

  NotificationResponse({
    required this.success,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<dynamic, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      notifications: (json['notifications'] as List<dynamic>? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'total': total,
      'page': page,
      'totalPages': totalPages,
      'notifications': notifications.map((e) => e.toJson()).toList(),
    };
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String receiverId;
  final String notificationType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.receiverId,
    required this.notificationType,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['isRead'] ?? false,
      receiverId: json['receiverId'] ?? '',
      notificationType: json['notificationType'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'body': body,
      'isRead': isRead,
      'receiverId': receiverId,
      'notificationType': notificationType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}
