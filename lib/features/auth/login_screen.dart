import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final vm = context.read<LoginViewModel>();
    vm.emailController.addListener(_onFieldChanged);
    vm.passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    context.read<LoginViewModel>().clearError();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D1642)],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildCard(),
                    const SizedBox(height: 24),
                    _buildBottomLink(),
                    const SizedBox(height: 16),
                    const Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.white24),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Image.asset(
          'assets/images/logo.png',
          width: 72,
          height: 72,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'C1',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 14, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoleToggle(vm),
                const SizedBox(height: 24),
                _buildEmailField(vm),
                const SizedBox(height: 16),
                _buildPasswordField(vm),
                const SizedBox(height: 12),
                _buildErrorBanner(vm),
                const SizedBox(height: 16),
                _buildLoginButton(vm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleToggle(LoginViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _roleChip(
            label: 'Admin',
            isSelected: vm.selectedRole == 'Admin',
            onTap: () => vm.setSelectedRole('Admin'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _roleChip(
            label: 'Agent',
            isSelected: vm.selectedRole == 'Agent',
            onTap: () => vm.setSelectedRole('Agent'),
          ),
        ),
      ],
    );
  }

  Widget _roleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(LoginViewModel vm) {
    return AppTextField(
      label: 'Email Address',
      controller: vm.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1A237E)),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email address is required';
        final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
        return null;
      },
    );
  }

  Widget _buildPasswordField(LoginViewModel vm) {
    return AppTextField(
      label: 'Password',
      controller: vm.passwordController,
      obscureText: !vm.isPasswordVisible,
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF1A237E)),
      suffixIcon: IconButton(
        icon: Icon(
          vm.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: const Color(0xFF9E9E9E),
        ),
        onPressed: vm.togglePasswordVisibility,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      onSubmitted: (_) => vm.login(context),
    );
  }

  Widget _buildErrorBanner(LoginViewModel vm) {
    if (vm.errorMessage == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              vm.errorMessage!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFC62828)),
            ),
          ),
          GestureDetector(
            onTap: vm.clearError,
            child: const Icon(Icons.close, color: Color(0xFFC62828), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel vm) {
    return AppButton(
      label: 'Sign In',
      onPressed: vm.isLoading ? null : () => vm.login(context),
      isLoading: vm.isLoading,
      color: const Color(0xFF1A237E),
    );
  }

  Widget _buildBottomLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'New corporate entity? ',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.corporateRegistration),
          child: const Text(
            'Register Here',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
