import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zest_employee/data/repositories/auth/auth_repo.dart';

import 'package:zest_employee/logic/bloc/notification/notification_state.dart';

import 'notification_event.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final AuthRepository repo;

  NotificationBloc(this.repo) : super(NotificationInitial()) {
    /// 🔔 FETCH NOTIFICATIONS
    on<FetchNotificationsRequested>((event, emit) async {
      emit(NotificationLoading());
      try {
        final res = await repo.getNotifications();

        if (res.success) {
          emit(
            NotificationLoaded(
              notifications: res.notifications,
              total: res.total,
              page: res.page,
              totalPages: res.totalPages,
            ),
          );
        } else {
          emit(NotificationError("Failed to load notifications"));
        }
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });

    //   /// 🗑 DELETE NOTIFICATIONS
    //   on<DeleteNotificationsRequested>((event, emit) async {
    //     emit(NotificationLoading());
    //     try {
    //       final res = await repo.deleteNotification(event.notificationIds);

    //       if (res.success) {
    //         emit(NotificationDeleted(res.message));
    //         add(FetchNotificationsRequested()); // refresh
    //       } else {
    //         emit(NotificationError(res.message));
    //       }
    //     } catch (e) {
    //       emit(NotificationError(e.toString()));
    //     }
    //   });
    // }
  }
}
