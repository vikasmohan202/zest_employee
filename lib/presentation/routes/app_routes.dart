import 'package:flutter/material.dart';
import 'package:zest_employee/presentation/screens/home_screens.dart';
import 'package:zest_employee/presentation/screens/login_screen.dart';
import 'package:zest_employee/presentation/screens/sign_up_screens.dart';
import 'package:zest_employee/presentation/screens/splash_screens.dart';


class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
