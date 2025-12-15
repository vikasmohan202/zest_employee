// lib/config/injection_container.dart
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:zest_employee/core/network/api_clients.dart';

import 'package:zest_employee/core/utils/token_storage.dart';
import 'package:zest_employee/data/data_providers/auth/auth_api.dart';
import 'package:zest_employee/data/data_providers/auth/auth_api_impl.dart';
import 'package:zest_employee/data/data_providers/order/order_api.dart';
import 'package:zest_employee/data/data_providers/order/order_api_impl.dart';
import 'package:zest_employee/data/repositories/auth/auth_repo.dart';
import 'package:zest_employee/data/repositories/auth/auth_repo_impl.dart';
import 'package:zest_employee/data/repositories/orders/auth_repo.dart';
import 'package:zest_employee/data/repositories/orders/auth_repo_impli.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/order/order_bloc.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  try {
    // Core / external packages
    sl.registerLazySingleton<http.Client>(() => http.Client());

    // Storage for tokens / cached user data
    sl.registerLazySingleton<TokenStorage>(() => TokenStorage());

    // Centralized ApiClient that reads token from TokenStorage and wraps http.Client
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(
        client: sl<http.Client>(),
        tokenStorage: sl<TokenStorage>(),
      ),
    );

    // --- APIs ---
    sl.registerLazySingleton<AuthApi>(() => HttpAuthApi(sl<ApiClient>()));
    sl.registerLazySingleton<OrderApi>(() => OrderApiImpl(sl<ApiClient>()));

    // --- Repositories ---
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(api: sl<AuthApi>(), storage: sl<TokenStorage>()),
    );

    sl.registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(api: sl<OrderApi>()),
    );

    // --- Blocs / Cubits ---
    sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));

    // OrderBloc: each consumer gets a fresh instance
    sl.registerFactory<OrderBloc>(
      () => OrderBloc(orderRepository: sl<OrderRepository>()),
    );

    if (kDebugMode) {
      debugPrint('DI: initDI completed - all services registered');
    }
  } catch (e, st) {
    debugPrint('initDI failed: $e\n$st');
    rethrow;
  }
}
