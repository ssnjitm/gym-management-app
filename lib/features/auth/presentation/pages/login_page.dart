import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:members_management_app/core/constants/app_constants.dart';
import 'package:members_management_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/themes/color_schemes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric authentication not available on this device')),
          );
        }
        return;
      }

      bool authenticated = false;

      authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to login to FitManager',
      );

      if (authenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: Load saved credentials and auto-login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric login failed: ${e.toString()}')),
        );
      }
    }
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.userMessage),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: {
                'gymId': state.staff.gymId,
              },
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Section
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 1),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  size: 64,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'FITMANAGER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const Text(
                                'Professional Gym Management',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AuthTextField(
                                label: 'Email Address',
                                hint: 'Enter your email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
                                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                label: 'Password',
                                hint: 'Enter your password',
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                validator: Validators.validatePassword,
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.grey500,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: state is AuthLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Biometric & Other options
                        if (_isBiometricAvailable)
                          TextButton.icon(
                            onPressed: state is AuthLoading ? null : _handleBiometricLogin,
                            icon: const Icon(Icons.fingerprint, color: Colors.white),
                            label: const Text(
                              'Login with Biometrics',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                        const SizedBox(height: 16),
                        Text(
                          'Version ${AppConstants.appVersion}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}