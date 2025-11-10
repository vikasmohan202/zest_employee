import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zest_employee/logic/bloc/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth_event.dart';
import 'package:zest_employee/logic/bloc/auth_state.dart';
import 'package:zest_employee/presentation/routes/app_routes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthAppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is AuthUnauthenticated || state is AuthFailure) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        },
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
