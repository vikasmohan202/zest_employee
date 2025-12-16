import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOffline = false;
  bool _hasCheckedLogin = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final List<ConnectivityResult> result = await _connectivity
        .checkConnectivity();
    _handleConnectivityChange(result);
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    final bool isConnected =
        result.isNotEmpty && !result.contains(ConnectivityResult.none);

    if (!isConnected && !_isOffline) {
      _isOffline = true;
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.noInternet);
      }
      return;
    }

    if (isConnected) {
      _isOffline = false;
      _hasCheckedLogin = false;
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    if (_hasCheckedLogin || _isOffline) return;
    _hasCheckedLogin = true;

    await Future.delayed(_splashDuration);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(keyAccessToken);
      final userJsonString = prefs.getString(keyUserJson);

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        Admin? employee;

        if (userJsonString != null && userJsonString.isNotEmpty) {
          final Map<String, dynamic> jsonMap = jsonDecode(userJsonString);
          employee = Admin.fromJson(jsonMap);

          context.read<AuthBloc>().add(AuthRestoreSession(employee: employee));
        }

        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e, st) {
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
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(70),
                ),
              ),
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
