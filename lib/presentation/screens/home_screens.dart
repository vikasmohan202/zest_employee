import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zest_employee/logic/bloc/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth_event.dart';
import 'package:zest_employee/logic/bloc/auth_state.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (_, state) {
            final name = switch (state) {
              AuthAuthenticated s => s.user.name ?? s.user.email,
              _ => 'Guest'
            };
            return Text('Welcome, $name');
          },
        ),
      ),
    );
  }
}
