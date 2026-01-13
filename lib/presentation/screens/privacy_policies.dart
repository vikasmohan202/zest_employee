import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zest_employee/presentation/widgets/custom_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color _bgColor = Color.fromRGBO(51, 107, 63, 1);
  static const Color _accentColor = Color.fromRGBO(201, 248, 186, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: CustomAppBar(
        backgroundColor: _bgColor,
        elevation: 0,

        title: "Privacy Policy",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Introduction"),
              _cardText(
                "We value your privacy and are committed to protecting your personal information. "
                "This Privacy Policy explains how we collect, use, and safeguard your data.",
              ),

              const SizedBox(height: 20),

              _sectionTitle("Information We Collect"),
              _cardText(
                "• Personal details such as name, email, and profile information.\n"
                "• App usage data to improve user experience.\n"
                "• Support-related information when you raise a ticket.",
              ),

              const SizedBox(height: 20),

              _sectionTitle("How We Use Your Information"),
              _cardText(
                "Your information is used to:\n"
                "• Provide and improve app functionality.\n"
                "• Communicate important updates.\n"
                "• Resolve support requests efficiently.",
              ),

              const SizedBox(height: 20),

              _sectionTitle("Data Security"),
              _cardText(
                "We implement industry-standard security measures to protect your data "
                "from unauthorized access, alteration, or disclosure.",
              ),

              const SizedBox(height: 20),

              _sectionTitle("Contact Us"),
              _cardText(
                "If you have any questions about this Privacy Policy, "
                "please contact our support team through the Help & Support section.",
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // UI HELPERS
  // ------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: _accentColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _cardText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.08),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
