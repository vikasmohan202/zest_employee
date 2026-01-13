// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zest_employee/firebase_options.dart';
import 'package:zest_employee/logic/bloc/notification/notification_bloc.dart';
import 'package:zest_employee/logic/bloc/notification/notificationn_services.dart';
import 'package:zest_employee/logic/bloc/order/order_bloc.dart';
import 'config/injection_container.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/obserber.dart';
import 'package:zest_employee/presentation/routes/app_routes.dart';
import 'config/app_theme.dart';



final GlobalKey<NavigatorState> navigatorKey=GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  await NotificationService.instance.init();
  try {
    await initDI();
  } catch (e, st) {
    // If DI fails, print error so you can see the cause.
    debugPrint('DI initialization failed: $e\n$st');
    // Optionally rethrow or continue (here we continue which will likely cause errors later).
  }

  Bloc.observer = SimpleBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // sl<AuthBloc>() must succeed because initDI has run and registered it.
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<OrderBloc>(create: (_) => sl<OrderBloc>()),
        BlocProvider<NotificationBloc>(create: (_) => sl<NotificationBloc>()),
      ],
      child: MaterialApp(
        title: 'Zest Employee',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
