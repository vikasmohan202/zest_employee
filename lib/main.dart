import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zest_employee/logic/bloc/auth_bloc.dart';
import 'package:zest_employee/logic/obserber.dart';
import 'package:zest_employee/presentation/routes/app_routes.dart';
import 'config/app_theme.dart';
import 'config/injection_container.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();
  Bloc.observer = SimpleBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp(
        title: 'Auth Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
