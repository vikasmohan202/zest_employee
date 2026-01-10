import 'package:zest_employee/data/models/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int total;
  final int page;
  final int totalPages;

  NotificationLoaded({
    required this.notifications,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

class NotificationDeleted extends NotificationState {
  final String message;
  NotificationDeleted(this.message);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}
