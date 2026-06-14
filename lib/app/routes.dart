import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/agent/agent_dashboard_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/onboarding/corporate_registration_screen.dart';
import '../features/onboarding/agent_registration_screen.dart';
import '../features/onboarding/terminal_profiling_screen.dart';
import '../features/onboarding/onboarding_complete_screen.dart';
import '../features/vehicle/vehicle_search_screen.dart';
import '../features/vehicle/vehicle_found_screen.dart';
import '../features/vehicle/vehicle_not_found_screen.dart';
import 'package:provider/provider.dart';
import '../features/vehicle/scanner_view.dart';
import '../features/vehicle/scanner_viewmodel.dart';
import '../features/transaction/transaction_creation_screen.dart';
import '../features/transaction/transaction_success_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String corporateRegistration = '/corporate-registration';
  static const String agentRegistration = '/agent-registration';
  static const String terminalProfiling = '/terminal-profiling';
  static const String onboardingComplete = '/onboarding-complete';
  static const String adminDashboard = '/admin-dashboard';
  static const String agentDashboard = '/agent-dashboard';
  static const String vehicleSearch = '/vehicle-search';
  static const String vehicleFound = '/vehicle-found';
  static const String vehicleNotFound = '/vehicle-not-found';
  static const String transactionCreation = '/transaction-creation';
  static const String transactionSuccess = '/transaction-success';
  static const String scanner = '/scanner';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    corporateRegistration: (context) => const CorporateRegistrationScreen(),
    agentRegistration: (context) => const AgentRegistrationScreen(),
    terminalProfiling: (context) => const TerminalProfilingScreen(),
    onboardingComplete: (context) => const OnboardingCompleteScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    agentDashboard: (context) => const AgentDashboardScreen(),
    vehicleSearch: (context) => const VehicleSearchScreen(),
    vehicleFound: (context) => const VehicleFoundScreen(),
    vehicleNotFound: (context) => const VehicleNotFoundScreen(),
    transactionCreation: (context) => const TransactionCreationScreen(),
    transactionSuccess: (context) => const TransactionSuccessScreen(),
    scanner: (context) => ChangeNotifierProvider(
      create: (_) => ScannerViewModel(),
      child: const ScannerView(),
    ),
  };
}
