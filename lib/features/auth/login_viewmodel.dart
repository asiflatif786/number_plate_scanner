import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/errors/failure.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  static const String _tag = 'LoginVM';

  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isPasswordVisible = false;
  String selectedRole = 'Agent';

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  void setSelectedRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email address is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String _friendlyMessage(Failure failure) {
    if (failure is AuthFailure) {
      return 'Access denied. Contact your administrator.';
    }
    if (failure is NetworkFailure) {
      return 'No internet connection. Check your network.';
    }
    if (failure is ServerFailure) {
      return 'Invalid email or password. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final emailError = _validateEmail(email);
    if (emailError != null) {
      errorMessage = emailError;
      notifyListeners();
      return;
    }

    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      errorMessage = passwordError;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result.success && result.data != null) {
        final user = result.data!;

        final session = await SessionManager.instance;
        await session.saveOnboardingComplete(
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          agentNumber: user.agentNumber,
          companyNumber: user.companyNumber,
        );

        AppLogger.logInfo(_tag, 'Login successful — role: ${user.role}');

        if (!context.mounted) return;

        Fluttertoast.showToast(
          msg: 'Welcome, ${user.firstName}!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF2E7D32),
          textColor: Colors.white,
        );

        if (user.isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/agent-dashboard');
        }
      } else if (result.failure != null) {
        errorMessage = _friendlyMessage(result.failure!);
        AppLogger.logWarning(_tag, 'Login failed: ${result.failure!.message}');
      } else {
        errorMessage = 'Something went wrong. Please try again.';
      }
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      AppLogger.logError(_tag, 'Login error', e);
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
