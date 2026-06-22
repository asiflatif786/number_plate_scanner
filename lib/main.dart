import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/routes.dart';
import 'core/session/session_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/agent/agent_dashboard_viewmodel.dart';
import 'features/admin/admin_dashboard_viewmodel.dart';
import 'features/auth/login_viewmodel.dart';
import 'features/onboarding/agent_registration_viewmodel.dart';
import 'features/onboarding/corporate_registration_viewmodel.dart';
import 'features/onboarding/onboarding_complete_viewmodel.dart';
import 'features/onboarding/terminal_profiling_viewmodel.dart';
import 'features/splash/splash_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Consolidated Haulage Levy',
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        // Enhanced route handler to handle deep links with query parameters
        onGenerateRoute: (settings) {
          final String name = settings.name ?? '';
          
          // Handle cases where the path is just "/" but has query params like ?reference=...
          if (name.contains('?reference=') || name.contains('&reference=')) {
             return MaterialPageRoute(
               builder: AppRoutes.routes[AppRoutes.paymentSuccess]!,
               settings: settings,
             );
          }

          final Uri uri = Uri.parse(name);
          String path = uri.path;
          
          // Check host for custom schemes like chl://payment-success
          if (uri.host == 'payment-success') {
            path = AppRoutes.paymentSuccess;
          }

          // Strip trailing slashes and ensure base path matching
          if (path.isEmpty || path == '/') {
             // Default to splash or let standard logic handle it
          }

          final builder = AppRoutes.routes[path];
          
          if (builder != null) {
            return MaterialPageRoute(
              builder: builder,
              settings: settings,
            );
          }

          // Final fallback
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
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
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
