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
import 'package:zest_employee/presentation/screens/privacy_policies.dart';
import 'package:zest_employee/presentation/support/create%20ticket.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _bgColor = Color.fromRGBO(51, 107, 63, 1);
  static const Color _accentColor = Color.fromRGBO(201, 248, 186, 1);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: _bgColor,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final Admin employee = state.employee;

        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Column(
                children: [
                  _title(),
                  const SizedBox(height: 24),

                  _profileCard(context, employee),
                  const SizedBox(height: 36),

                  _sectionHeader("ACCOUNT"),
                  _cardOption(
                    icon: Icons.edit_outlined,
                    title: "Edit Profile",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(employee: employee),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // _sectionHeader("SUPPORT"),
                  // _cardOption(
                  //   icon: Icons.help_outline,
                  //   title: "Help & Support",
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return CreateTicketScreen();
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),
                  _cardOption(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return PrivacyPolicyScreen();
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  _logoutButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // UI WIDGETS
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

  Widget _profileCard(BuildContext context, Admin employee) {
    final String name = employee.fullName.isNotEmpty
        ? employee.fullName
        : "Employee";
    final String email = employee.email.isNotEmpty
        ? employee.email
        : "email@example.com";
    final String? imageUrl = employee.profileImage;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditProfileScreen(employee: employee),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.08),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage("assets/images/user.png") as ImageProvider,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: _accentColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _cardOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.06),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        context.read<AuthBloc>().add(AuthLogoutRequested());
        await TokenStorage().clear();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Center(
          child: Text(
            "Logout",
            style: GoogleFonts.poppins(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
