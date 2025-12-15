import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF3E673D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, // Your screen background header color
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // <-- This makes the back icon white
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Today",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notification Item 1
                    _notificationItem(
                      icon: Icons.notifications_active_outlined,
                      iconBg: const Color(0xFFDFF1FF),
                      title: "Reminder",
                      message: "Shirt Wash – #2F33J scheduled Tomorrow.",
                      time: "13min",
                    ),
                    _divider(),

                    // Notification Item 2
                    _notificationItem(
                      icon: Icons.verified_outlined,
                      iconBg: const Color(0xFFE8FBE5),
                      title: "Order Delivered",
                      message:
                          "Your Order – Black Shirt is successfully delivered.",
                      time: "1 hr",
                    ),
                    _divider(),

                    // Notification Item 3
                    _notificationItem(
                      icon: Icons.celebration,
                      iconBg: const Color(0xFFFDEBF9),
                      title: "Winter Offer",
                      message:
                          "49% off on Dry Cleaning Service until November 23rd.",
                      time: "1 hr",
                    ),
                    _divider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationItem({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String message,
    required String time,
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
          Text(
            time,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
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
}
