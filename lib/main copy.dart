// import 'dart:async';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'config/app_theme.dart';
// import 'config/injection_container.dart';
// import 'logic/bloc/auth/auth_bloc.dart';
// import 'logic/bloc/order/order_bloc.dart';
// import 'logic/obserber.dart';
// import 'presentation/routes/app_routes.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initDI();

//   Bloc.observer = SimpleBlocObserver();

//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<List<ConnectivityResult>>
//       _connectivitySubscription;

//   bool _isOffline = false;

//   @override
//   void initState() {
//     super.initState();
//     _initConnectivity();

//     _connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen(
//       _handleConnectivityChange,
//     );
//   }

//   @override
//   void dispose() {
//     _connectivitySubscription.cancel();
//     super.dispose();
//   }

//   Future<void> _initConnectivity() async {
//     try {
//       final result = await _connectivity.checkConnectivity();
//       if (!mounted) return;
//       _handleConnectivityChange(result);
//     } on PlatformException {
//       // ignore
//     }
//   }

//   void _handleConnectivityChange(List<ConnectivityResult> result) {
//     final bool isConnected =
//         !result.contains(ConnectivityResult.none);

//     if (!isConnected && !_isOffline) {
//       _isOffline = true;
//       Navigator.of(context).pushNamedAndRemoveUntil(
//         AppRoutes.noInternet,
//         (route) => false,
//       );
//     }

//     if (isConnected && _isOffline) {
//       _isOffline = false;
//       Navigator.of(context).pushNamedAndRemoveUntil(
//         AppRoutes.splash,
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
//         BlocProvider<OrderBloc>(create: (_) => sl<OrderBloc>()),
//       ],
//       child: MaterialApp(
//         title: 'Zest Employee',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.light,
//         initialRoute: AppRoutes.splash,
//         onGenerateRoute: AppRoutes.onGenerateRoute,
//       ),
//     );
//   }
// }
