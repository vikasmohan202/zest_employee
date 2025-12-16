import 'package:flutter/material.dart';
import 'package:zest_employee/core/utils/no_internate_connnections.dart';
import 'package:zest_employee/presentation/screens/dash_board_screen.dart';
import 'package:zest_employee/presentation/screens/home_screen.dart';
import 'package:zest_employee/presentation/screens/login_screen.dart';
import 'package:zest_employee/presentation/screens/sign_up_screens.dart';
import 'package:zest_employee/presentation/screens/splash_screens.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const dashboard = '/home';
  static const String noInternet = '/no-internet';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case noInternet:
        return MaterialPageRoute(builder: (_) => const NoInternetScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
