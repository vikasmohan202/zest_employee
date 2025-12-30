import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:zest_employee/core/utils/token_storage.dart';
import 'package:zest_employee/data/models/admin_model.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth/auth_event.dart';
import 'package:zest_employee/logic/bloc/auth/auth_state.dart';
import 'package:zest_employee/presentation/screens/edit_profile.dart';
import 'package:zest_employee/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: Color.fromRGBO(51, 107, 63, 1),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final Admin employee = state.employee;

        return Scaffold(
          backgroundColor: const Color.fromRGBO(51, 107, 63, 1),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _title(),
                  const SizedBox(height: 25),
                  _profileHeader(context, employee),
                  const SizedBox(height: 30),
                  _generalSection(),
                  const SizedBox(height: 20),
                  _notificationSection(),
                  const SizedBox(height: 20),
                  _divider(),
                  _logout(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // UI SECTIONS
  // ------------------------------------------------------------

  Widget _title() {
    return Text(
      "Profile",
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _profileHeader(BuildContext context, Admin employee) {
    final String name =
        employee.fullName.isNotEmpty ? employee.fullName : "Employee";
    final String email =
        employee.email.isNotEmpty ? employee.email : "email@example.com";

    final String? imageUrl = employee.profileImage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 42,
          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : const AssetImage("assets/images/user.png") as ImageProvider,
          child: (imageUrl == null || imageUrl.isEmpty)
              ? Text(
                  name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
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
              name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              email,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Spacer(),
        _editButton(context, employee),
      ],
    );
  }

  Widget _editButton(BuildContext context, Admin employee) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditProfileScreen(employee: employee),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
    );
  }

  Widget _generalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("GENERAL"),
        _profileOption(
          icon: Icons.location_on_outlined,
          title: "Assigned Areas",
          subtitle: "View assigned locations",
          onTap: () {},
        ),
      ],
    );
  }

  Widget _notificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("NOTIFICATIONS"),
        _notificationSwitch(
          icon: Icons.notifications_active_outlined,
          title: "Push Notifications",
          subtitle: "Daily updates",
          value: true,
          onChanged: (_) {},
        ),
        _notificationSwitch(
          icon: Icons.campaign_outlined,
          title: "Promotional Notifications",
          subtitle: "Offers & campaigns",
          value: true,
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _logout(BuildContext context) {
    return _profileOption(
      icon: Icons.logout,
      title: "Logout",
      subtitle: "",
      onTap: () async {
        context.read<AuthBloc>().add(AuthLogoutRequested());
        await TokenStorage().clear();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }

  // ------------------------------------------------------------
  // REUSABLE WIDGETS
  // ------------------------------------------------------------

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _profileOption({
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

  Widget _notificationSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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

  Widget _divider() {
    return const Divider(color: Colors.white24, thickness: 1);
  }
}
