import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/routes.dart';
import 'core/session/session_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/agent/agent_dashboard_viewmodel.dart';
import 'features/admin/admin_dashboard_viewmodel.dart';
import 'features/admin/add_bank_account_viewmodel.dart';
import 'features/auth/login_viewmodel.dart';
import 'features/onboarding/agent_registration_viewmodel.dart';
import 'features/onboarding/corporate_registration_viewmodel.dart';
import 'features/onboarding/onboarding_complete_viewmodel.dart';
import 'features/onboarding/terminal_profiling_viewmodel.dart';
import 'features/splash/splash_viewmodel.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bypass SSL certificate verification for development
  HttpOverrides.global = DevHttpOverrides();

  await (await SessionManager.instance).init();

  runApp(const HaulageLevyApp());
}

class HaulageLevyApp extends StatelessWidget {
  const HaulageLevyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => CorporateRegistrationViewModel()),
        ChangeNotifierProvider(create: (_) => AgentRegistrationViewModel()),
        ChangeNotifierProvider(create: (_) => TerminalProfilingViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingCompleteViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AgentDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AddBankAccountViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Consolidated Haulage Levy',
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          final String name = settings.name ?? '';
          
          if (name.contains('?reference=') || name.contains('&reference=')) {
             return MaterialPageRoute(
               builder: AppRoutes.routes[AppRoutes.paymentSuccess]!,
               settings: settings,
             );
          }

          final Uri uri = Uri.parse(name);
          String path = uri.path;
          
          if (uri.host == 'payment-success') {
            path = AppRoutes.paymentSuccess;
          }

          final builder = AppRoutes.routes[path];
          
          if (builder != null) {
            return MaterialPageRoute(
              builder: builder,
              settings: settings,
            );
          }

          return MaterialPageRoute(
            builder: (_) => RouteNotFoundScreen(route: name),
          );
        },
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? message;
  
  const PlaceholderScreen(this.title, {this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message ?? 'The server encountered an error (HTTP 500) while processing this request. This usually means there is a temporary issue with the backend service or invalid data was provided.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Go Back and Try Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteNotFoundScreen extends StatelessWidget {
  final String route;
  const RouteNotFoundScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text('Route not found: $route',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
