import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:zest_employee/logic/bloc/notification/notification_bloc.dart';
import 'package:zest_employee/logic/bloc/notification/notification_event.dart';
import 'package:zest_employee/logic/bloc/notification/notification_state.dart';
import 'package:zest_employee/presentation/widgets/custom_appbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {

    context.read<NotificationBloc>().add(FetchNotificationsRequested());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF3E673D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: "Notifications",
      ),
      body: SafeArea(
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state is NotificationError) {
              return Center(
                child: Text(
                  state.message,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return _emptyView();
              }

              return _notificationList(state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// 🔔 Notification List
  Widget _notificationList(NotificationLoaded state) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];

                return Column(
                  children: [
                    _notificationItem(
                      icon: _getIcon(notification.title),
                      iconBg: _getIconBg(notification.title),
                      title: notification.title,
                      message: notification.body,
                      //time: _timeAgo(notification.updatedAt),
                    ),
                    _divider(),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 📭 Empty State
  Widget _emptyView() {
    return Center(
      child: Text(
        "No notifications found",
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  /// 🔔 Single Notification UI
  Widget _notificationItem({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String message,
    // required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF3E673D), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Text(
          //   time,
          //   style: GoogleFonts.poppins(
          //     color: Colors.white70,
          //     fontSize: 12,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: Colors.white.withOpacity(0.25),
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  /// 🎯 Icon based on title
  IconData _getIcon(String title) {
    if (title.toLowerCase().contains("order")) {
      return Icons.verified_outlined;
    }
    if (title.toLowerCase().contains("offer")) {
      return Icons.celebration;
    }
    return Icons.notifications_active_outlined;
  }

  /// 🎨 Icon background
  Color _getIconBg(String title) {
    if (title.toLowerCase().contains("order")) {
      return const Color(0xFFE8FBE5);
    }
    if (title.toLowerCase().contains("offer")) {
      return const Color(0xFFFDEBF9);
    }
    return const Color(0xFFDFF1FF);
  }

  /// ⏱ Time ago helper
  String _timeAgo(String timestamp) {
    final date = DateTime.tryParse(timestamp);
    if (date == null) return "";

    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 60) return "${diff.inMinutes} min";
    if (diff.inHours < 24) return "${diff.inHours} hr";
    return "${diff.inDays} d";
  }
}
