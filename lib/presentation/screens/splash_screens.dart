import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zest_employee/core/utils/token_storage.dart';
import 'package:zest_employee/data/models/admin_model.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth/auth_event.dart';
import 'package:zest_employee/presentation/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _splashDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(_splashDuration);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(keyAccessToken);
      final userJsonString = prefs.getString(keyUserJson);

      if (!mounted) return;

      // Token exists — restore user session
      if (token != null && token.isNotEmpty) {
        Admin? employee;

        if (userJsonString != null && userJsonString.isNotEmpty) {
          try {
            final Map<String, dynamic> jsonMap =
                jsonDecode(userJsonString) as Map<String, dynamic>;
            employee = Admin.fromJson(jsonMap);

            // Restore session to AuthBloc
            context.read<AuthBloc>().add(
              AuthRestoreSession(employee: employee),
            );
          } catch (e) {
            debugPrint("Error parsing saved user JSON: $e");
          }
        }

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        // No token → go to login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e, st) {
      debugPrint('Splash token check failed: $e\n$st');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1.2, -1.0),
            radius: 1.4,
            colors: [Color(0xFF336B3F), Color(0xFFC9F8BA)],
          ),
        ),
        child: SafeArea(child: _buildSplashLayout(context)),
      ),
    );
  }

  Widget _buildSplashLayout(BuildContext context) {
    return Column(
      children: [
        const Spacer(),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/images/splash_logo_1.png"),
                  Image.asset("assets/images/splash_logo_2.png"),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(70),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                "assets/images/splash_logo.png",
                height: MediaQuery.of(context).size.height * 0.35,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Image.asset(
            "assets/images/aayan_infotech_logo.png",
            height: 60,
          ),
        ),
      ],
    );
  }
}
