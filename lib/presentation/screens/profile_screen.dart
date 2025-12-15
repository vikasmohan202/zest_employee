import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zest_employee/core/utils/token_storage.dart';

import 'package:zest_employee/presentation/screens/edit_profile.dart';
import 'package:zest_employee/presentation/screens/login_screen.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth/auth_state.dart';
import 'package:zest_employee/logic/bloc/auth/auth_event.dart';
import 'package:zest_employee/data/models/admin_model.dart'; // where Employee is

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        Admin? employee;
        if (state is AuthAuthenticated) {
          employee = state.employee;
        }

        final displayName =
            (employee?.fullName ?? employee?.fullName ?? '').isNotEmpty
            ? (employee?.fullName ?? employee?.fullName)!
            : 'Employee';
        final displayEmail = (employee?.email ?? '').isNotEmpty
            ? employee!.email
            : 'email@example.com';
        final profileImage =
            employee?.profileImage; // change field name if different

        return Scaffold(
          backgroundColor: const Color.fromRGBO(51, 107, 63, 1),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Profile",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 25),

                    /// Profile Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              profileImage != null && profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : const AssetImage("assets/images/user.png")
                                    as ImageProvider,
                          child: (profileImage == null || profileImage.isEmpty)
                              ? Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              displayEmail,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return EditProfileScreen(employee: employee);
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color.fromRGBO(201, 248, 186, 1),
                              ),
                            ),
                            child: Text(
                              "Edit",
                              style: GoogleFonts.poppins(
                                color: const Color.fromRGBO(201, 248, 186, 1),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// GENERAL
                    sectionHeader("GENERAL"),
                    profileOption(
                      icon: Icons.location_on_outlined,
                      title: "Assigened Areas",
                      subtitle: "Add your credit & debit cards",
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),

                    /// NOTIFICATIONS
                    sectionHeader("NOTIFICATIONS"),
                    notificationSwitch(
                      icon: Icons.notifications_active_outlined,
                      title: "Push Notifications",
                      subtitle: "For daily updates and others.",
                      value: true,
                      onChanged: (v) {},
                    ),
                    notificationSwitch(
                      icon: Icons.campaign_outlined,
                      title: "Promotional Notifications",
                      subtitle: "New Campaign & Offers",
                      value: true,
                      onChanged: (v) {},
                    ),

                    const SizedBox(height: 20),
                    divider(),
                    profileOption(
                      icon: Icons.logout,
                      title: "Logout",
                      subtitle: "",
                      onTap: () {
                        // clear auth state
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        TokenStorage().clear();

                        // navigate to login and remove all previous routes
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget sectionHeader(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color.fromRGBO(201, 248, 186, 1),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget notificationSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color.fromRGBO(37, 96, 63, .3),
            activeTrackColor: const Color.fromRGBO(201, 248, 186, 1),
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return const Divider(color: Colors.white24, thickness: 1);
  }
}
