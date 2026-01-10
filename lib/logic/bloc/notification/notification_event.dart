abstract class NotificationEvent {}

class FetchNotificationsRequested extends NotificationEvent {}

class DeleteNotificationsRequested extends NotificationEvent {
  final List<String> notificationIds;
  DeleteNotificationsRequested(this.notificationIds);
}
