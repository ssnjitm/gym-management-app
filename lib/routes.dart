import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'init_dependencies.dart';

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