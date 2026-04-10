import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:members_management_app/core/themes/color_schemes.dart';
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
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Add a small delay for a professional feel
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.read<AuthBloc>().add(AuthCheckStatusEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(
              context, 
              '/home',
              arguments: {'gymId': state.staff.gymId},
            );
          } else if (state is AuthUnauthenticated || state is AuthFailure) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.fitness_center,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'FITMANAGER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}