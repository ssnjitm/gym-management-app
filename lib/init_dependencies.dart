import 'package:get_it/get_it.dart';
import 'package:members_management_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:members_management_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:members_management_app/features/home/domain/repositories/home_repository.dart';
import 'package:members_management_app/features/home/domain/usecases/get_dashboard_stats.dart';
import 'package:members_management_app/features/home/domain/usecases/get_expiring_members.dart';
import 'package:members_management_app/features/home/domain/usecases/get_recent_activities.dart';
import 'package:members_management_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/network/network_info.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_staff_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<ConnectionChecker>(
    () => ConnectionCheckerImpl(sl()),
  );
  
  // Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  
  // Auth Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
  
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectionChecker: sl(),
    ),
  );
  
  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentStaffUseCase(sl()));
  
  // Auth BLoC
  sl.registerFactory(() => AuthBloc(
    login: sl(),
    logout: sl(),
    getCurrentStaff: sl(),
  ));

  // Home Data Sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(supabaseClient: sl()),
  );
  
  // Home Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      connectionChecker: sl(),
    ),
  );
  
  // Home Use Cases
  sl.registerLazySingleton(() => GetDashboardStats(sl()));
  sl.registerLazySingleton(() => GetRecentActivities(sl()));
  sl.registerLazySingleton(() => GetExpiringMembers(sl()));
  
  // Home BLoC
  sl.registerFactory(() => HomeBloc(
    getDashboardStats: sl(),
    getRecentActivities: sl(),
    getExpiringMembers: sl(),
  ));


}