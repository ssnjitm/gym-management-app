import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:members_management_app/init_dependencies.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/app_initialization.dart';
import 'core/widgets/error_widgets.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool success = await initializeApp();
  if (success) {
    runApp(const MyApp());
  } else {
    runApp(ErrorApp(onRetry: _retryInitialization));
  }
}

Future<void> _retryInitialization() async {
  bool success = await initializeApp();
  if (success) {
    runApp(const MyApp());
  }
  // If still failed, ErrorApp remains
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}