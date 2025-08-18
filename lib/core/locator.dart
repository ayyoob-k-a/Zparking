import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:z_parking/core/dio_client.dart';
import 'package:z_parking/core/local_storage.dart';
import 'package:z_parking/features/auth/repository/auth_repository.dart';
import 'package:z_parking/features/vehicle/repository/vehicle_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> setupLocator() async {
  // Local storage
  final prefs = await SharedPreferences.getInstance();
  final localStorage = LocalStorage(prefs);

  // Tokens
  sl.registerLazySingleton<LocalStorage>(() => localStorage);
  sl.registerLazySingleton<LocalTokenStore>(() => LocalTokenStore(localStorage.readToken, localStorage.saveToken, localStorage.clearToken));
  sl.registerLazySingleton<TokenProvider>(() => sl<LocalTokenStore>());
  sl.registerLazySingleton<TokenSink>(() => sl<LocalTokenStore>());

  // Dio and Api client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(baseUrl: 'https://parking.api.salonsyncs.com/api/'));
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  });
  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl<Dio>(), tokenProvider: sl<TokenProvider>()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(apiClient: sl<ApiClient>(), tokenSink: sl<TokenSink>()));
  sl.registerLazySingleton<VehicleRepository>(() => VehicleRepository(apiClient: sl<ApiClient>()));
}


