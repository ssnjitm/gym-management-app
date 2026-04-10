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
import 'features/members/data/datasources/member_remote_datasource.dart';
import 'features/members/data/datasources/member_detail_remote_datasource.dart';
import 'features/members/data/repositories/member_repository_impl.dart';
import 'features/members/data/repositories/member_detail_repository_impl.dart';
import 'features/members/domain/repositories/member_repository.dart';
import 'features/members/domain/repositories/member_detail_repository.dart';
import 'features/members/domain/usecases/create_member_usecase.dart';
import 'features/members/domain/usecases/delete_member_usecase.dart';
import 'features/members/domain/usecases/get_members_usecase.dart';
import 'features/members/domain/usecases/search_members_usecase.dart';
import 'features/members/domain/usecases/update_member_usecase.dart';
import 'features/members/domain/usecases/get_member_detail_usecase.dart';
import 'features/members/domain/usecases/record_payment_usecase.dart' as member_payments;
import 'features/members/domain/usecases/renew_subscription_usecase.dart';
import 'features/members/presentation/bloc/members_bloc.dart';
import 'features/members/presentation/bloc/member_detail_bloc.dart';
import 'features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'features/attendance/data/repositories/attendance_repository_impl.dart';
import 'features/attendance/domain/repositories/attendance_repository.dart';
import 'features/attendance/domain/usecases/check_in_usecase.dart';
import 'features/attendance/domain/usecases/check_out_usecase.dart';
import 'features/attendance/domain/usecases/get_today_attendance_usecase.dart';
import 'features/attendance/domain/usecases/search_members_for_attendance_usecase.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/admin/data/repositories/supabase_crud_repository.dart';
import 'core/crud/crud_repository.dart';
import 'features/subscriptions/data/datasources/subscriptions_remote_datasource.dart';
import 'features/subscriptions/data/repositories/subscriptions_repository_impl.dart';
import 'features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'features/subscriptions/domain/usecases/get_expiring_subscriptions_usecase.dart';
import 'features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'features/subscriptions/domain/usecases/update_subscription_status_usecase.dart';
import 'features/subscriptions/presentation/bloc/subscriptions_bloc.dart';
import 'features/payments/data/datasources/payments_remote_datasource.dart';
import 'features/payments/data/repositories/payments_repository_impl.dart';
import 'features/payments/domain/repositories/payments_repository.dart';
import 'features/payments/domain/usecases/get_payments_usecase.dart';
import 'features/payments/domain/usecases/record_payment_usecase.dart';
import 'features/payments/presentation/bloc/payments_bloc.dart';

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

  // Admin / CRUD Repository (generic management)
  sl.registerLazySingleton<CrudRepository>(() => SupabaseCrudRepository(client: sl()));
  
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

  // Member Data Sources
  sl.registerLazySingleton<MemberRemoteDataSource>(
    () => MemberRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<MemberDetailRemoteDataSource>(
    () => MemberDetailRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Member Repository
  sl.registerLazySingleton<MemberRepository>(
    () => MemberRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MemberDetailRepository>(
    () => MemberDetailRepositoryImpl(remote: sl()),
  );

  // Member Use Cases
  sl.registerLazySingleton(() => GetMembersUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateMemberUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateMemberUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteMemberUseCase(repository: sl()));
  sl.registerLazySingleton(() => SearchMembersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMemberDetailUseCase(repository: sl()));
  sl.registerLazySingleton(() => member_payments.RecordPaymentUseCase(repository: sl()));
  sl.registerLazySingleton(() => RenewSubscriptionUseCase(repository: sl()));

  // Member BLoC
  sl.registerFactory(() => MembersBloc(
    getMembersUseCase: sl(),
    createMemberUseCase: sl(),
    updateMemberUseCase: sl(),
    deleteMemberUseCase: sl(),
    searchMembersUseCase: sl(),
  ));
  sl.registerFactory(() => MemberDetailBloc(
        getMemberDetail: sl(),
        recordPayment: sl(),
        renewSubscription: sl(),
        authBloc: sl(),
      ));

  // Attendance Data Sources
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Attendance Repository
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(remoteDataSource: sl()),
  );

  // Attendance Use Cases
  sl.registerLazySingleton(() => GetTodayAttendanceUseCase(repository: sl()));
  sl.registerLazySingleton(() => SearchMembersForAttendanceUseCase(repository: sl()));
  sl.registerLazySingleton(() => CheckInUseCase(repository: sl()));
  sl.registerLazySingleton(() => CheckOutUseCase(repository: sl()));

  // Attendance BLoC
  sl.registerFactory(() => AttendanceBloc(
        getTodayAttendance: sl(),
        searchMembers: sl(),
        checkIn: sl(),
        checkOut: sl(),
      ));

  // Subscriptions Data Sources
  sl.registerLazySingleton<SubscriptionsRemoteDataSource>(
    () => SubscriptionsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Subscriptions Repository
  sl.registerLazySingleton<SubscriptionsRepository>(
    () => SubscriptionsRepositoryImpl(remote: sl()),
  );

  // Subscriptions Use Cases
  sl.registerLazySingleton(() => GetSubscriptionsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetExpiringSubscriptionsUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateSubscriptionStatusUseCase(repository: sl()));

  // Subscriptions BLoC
  sl.registerFactory(
    () => SubscriptionsBloc(
      getSubscriptions: sl(),
      getExpiringSubscriptions: sl(),
      updateStatus: sl(),
    ),
  );

  // Payments Data Source
  sl.registerLazySingleton<PaymentsRemoteDataSource>(
    () => PaymentsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Payments Repository
  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(remote: sl()),
  );

  // Payments Use Cases
  sl.registerLazySingleton(() => GetPaymentsUseCase(repository: sl()));
  sl.registerLazySingleton(() => RecordGymPaymentUseCase(repository: sl()));

  // Payments BLoC
  sl.registerFactory(
    () => PaymentsBloc(
      getPayments: sl(),
      recordPayment: sl(),
      authBloc: sl(),
    ),
  );
}