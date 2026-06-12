import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/screens/agent_registration_screen.dart';
import '../../features/onboarding/presentation/screens/corporate_registration_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../../features/onboarding/presentation/screens/terminal_profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/transaction/presentation/screens/transaction_screen.dart';
import '../../features/vehicle/presentation/screens/vehicle_registration_screen.dart';
import '../../features/vehicle/presentation/screens/vehicle_search_screen.dart';
import '../utils/logger.dart';
import 'route_not_found_screen.dart';

class AppRouter {
  static const String _tag = 'AppRouter';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    AppLogger.info(_tag, 'Navigating to: ${settings.name}');

    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case '/company-registration':
        return MaterialPageRoute(
          builder: (_) => const CorporateRegistrationScreen(),
          settings: settings,
        );

      case '/agent-registration':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AgentRegistrationScreen(
            companyNumber: args['companyNumber'] as String,
          ),
          settings: settings,
        );

      case '/terminal-profile':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TerminalProfileScreen(
            companyNumber: args['companyNumber'] as String,
            agentNumber: args['agentNumber'] as String,
          ),
          settings: settings,
        );

      case '/onboarding-complete':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OnboardingCompleteScreen(
            companyNumber: args['companyNumber'] as String,
            agentNumber: args['agentNumber'] as String,
            terminalId: args['terminalId'] as String,
          ),
          settings: settings,
        );

      case '/vehicle-search':
        final initialLicensePlate = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => VehicleSearchScreen(
            initialLicensePlate: initialLicensePlate,
          ),
          settings: settings,
        );

      case '/vehicle-registration':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VehicleRegistrationScreen(
            licensePlate: args['licensePlate'] as String,
          ),
          settings: settings,
        );

      case '/transaction':
        return MaterialPageRoute(
          builder: (_) => const TransactionScreen(),
          settings: settings,
        );

      default:
        AppLogger.warning(_tag, 'Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => RouteNotFoundScreen(
            route: settings.name ?? 'unknown',
          ),
          settings: settings,
        );
    }
  }
}
