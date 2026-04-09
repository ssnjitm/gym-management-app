import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:members_management_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Trigger auth check when splash screen loads
    Future.microtask(() {
      context.read<AuthBloc>().add(AuthCheckStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to home with gymId
            Navigator.pushReplacementNamed(
              context, 
              '/home',
              arguments: {
                'gymId': state.staff.gymId,
              },
            );
          } else if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state is AuthFailure) {
            // On failure, go to login
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }
}