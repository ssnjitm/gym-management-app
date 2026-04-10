import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/members/presentation/pages/members_page.dart';
import 'features/members/presentation/bloc/members_bloc.dart';
import 'features/admin/presentation/pages/admin_management_page.dart';
import 'features/attendance/presentation/pages/attendance_page.dart';
import 'init_dependencies.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/members/presentation/pages/member_detail_page.dart';
import 'features/members/presentation/bloc/member_detail_bloc.dart';
import 'core/crud/crud_repository.dart';
import 'features/subscriptions/presentation/pages/subscriptions_page.dart';
import 'features/subscriptions/presentation/bloc/subscriptions_bloc.dart';
import 'features/payments/presentation/pages/payments_page.dart';
import 'features/payments/presentation/bloc/payments_bloc.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<AuthBloc>(context),
            child: const LoginPage(),
          ),
        );
      case '/home':
        // Get the staff entity from route arguments or from AuthBloc
        final args = settings.arguments as Map<String, dynamic>?;
        final gymId = args?['gymId'] as String? ?? '';
        
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: BlocProvider.of<AuthBloc>(context),
              ),
              BlocProvider(
                create: (_) => sl<HomeBloc>(),
              ),
            ],
            child: HomePage(gymId: gymId),
          ),
        );
      case '/members':
        final args = settings.arguments as Map<String, dynamic>?;
        final gymId = args?['gymId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => sl<MembersBloc>(),
            child: MembersPage(gymId: gymId),
          ),
        );
      case '/member':
        final args = settings.arguments as Map<String, dynamic>?;
        final memberId = args?['memberId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => sl<MemberDetailBloc>(),
            child: MemberDetailPage(memberId: memberId),
          ),
        );
      case '/manage':
        final args = settings.arguments as Map<String, dynamic>?;
        final gymId = args?['gymId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => RepositoryProvider<CrudRepository>.value(
            value: sl<CrudRepository>(),
            child: AdminManagementPage(gymId: gymId),
          ),
        );
      case '/attendance':
        final args = settings.arguments as Map<String, dynamic>?;
        final gymId = args?['gymId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<AttendanceBloc>(),
            child: AttendancePage(gymId: gymId),
          ),
        );
      case '/subscriptions':
        final args = settings.arguments as Map<String, dynamic>?;
        final gymId = args?['gymId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<SubscriptionsBloc>(),
            child: SubscriptionsPage(gymId: gymId),
          ),
        );
      case '/payments':
        final args = settings.arguments as Map<String, dynamic>?;
        final gymId = args?['gymId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<PaymentsBloc>(),
            child: PaymentsPage(gymId: gymId),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}