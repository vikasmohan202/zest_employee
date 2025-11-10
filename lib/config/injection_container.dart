import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:zest_employee/data/repositories/auth_repo.dart';
import 'package:zest_employee/data/repositories/auth_repo_impl.dart';
import 'package:zest_employee/logic/bloc/auth_bloc.dart';
import '../core/utils/token_storage.dart';
import '../data/data_providers/auth_api.dart';
import '../data/data_providers/auth_api_impl.dart';


final sl = GetIt.instance;

Future<void> initDI() async {
  // externals
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // core
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // data
  sl.registerLazySingleton<AuthApi>(() => HttpAuthApi(sl<http.Client>()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(api: sl<AuthApi>(), storage: sl<TokenStorage>()));

  // blocs
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
}
