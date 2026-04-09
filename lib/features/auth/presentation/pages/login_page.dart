import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:members_management_app/core/constants/app_constants.dart';
import 'package:members_management_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_text_field.dart';
import '../../../../core/constants/strings.dart';
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
      
      try {
        authenticated = await _localAuth.authenticate(
          localizedReason: 'Verify your identity to login to FitManager',
        );
      } catch (e) {
        try {
          authenticated = await _localAuth.authenticate(
            localizedReason: 'Verify your identity to login to FitManager',
            biometricOnly: true,
          );
        } catch (e2) {
          authenticated = await _localAuth.authenticate(
            localizedReason: 'Verify your identity to login to FitManager',
          );
        }
      }
      
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
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            // Navigate to home with gymId
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
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/App Name
                    const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gym Management System',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Email Field
                    AuthTextField(
                      label: AppStrings.email,
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    AuthTextField(
                      label: AppStrings.password,
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: Validators.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Forgot password feature coming soon!')),
                          );
                        },
                        child: Text(AppStrings.forgotPassword),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : _handleLogin,
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(AppStrings.signIn),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Biometric Login Button
                    if (_isBiometricAvailable)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: state is AuthLoading ? null : _handleBiometricLogin,
                          icon: const Icon(Icons.fingerprint),
                          label: Text(AppStrings.biometricLogin),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    Text(
                      'Version ${AppConstants.appVersion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}