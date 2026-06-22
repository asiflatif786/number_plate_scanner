import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/agent_model.dart';
import '../data/models/company_model.dart';
import '../features/auth/login_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/agent/agent_dashboard_screen.dart';
import '../features/agent/notification_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/view_companies_screen.dart';
import '../features/admin/view_companies_viewmodel.dart';
import '../features/admin/company_detail_screen.dart';
import '../features/admin/view_agents_screen.dart';
import '../features/admin/view_agents_viewmodel.dart';
import '../features/admin/agent_detail_screen.dart';
import '../features/admin/agent_detail_viewmodel.dart';
import '../features/admin/view_terminals_screen.dart';
import '../features/admin/view_terminals_viewmodel.dart';
import '../features/onboarding/corporate_registration_screen.dart';
import '../features/onboarding/agent_registration_screen.dart';
import '../features/onboarding/terminal_profiling_screen.dart';
import '../features/onboarding/onboarding_complete_screen.dart';
import '../features/onboarding/company_verify_screen.dart';
import '../features/onboarding/company_verify_viewmodel.dart';
import '../features/vehicle/vehicle_search_screen.dart';
import '../features/vehicle/vehicle_found_screen.dart';
import '../features/vehicle/vehicle_not_found_screen.dart';
import '../features/vehicle/scanner_view.dart';
import '../features/transaction/transaction_creation_screen.dart';
import '../features/transaction/transaction_success_screen.dart';
import '../features/transaction/transaction_success_viewmodel.dart';

class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String corporateRegistration = '/corporate-registration';
  static const String agentRegistration = '/agent-registration';
  static const String terminalProfiling = '/terminal-profiling';
  static const String onboardingComplete = '/onboarding-complete';
  static const String adminDashboard = '/admin-dashboard';
  static const String agentDashboard = '/agent-dashboard';
  static const String companyVerify = '/company-verify';
  static const String vehicleSearch = '/vehicle-search';
  static const String vehicleFound = '/vehicle-found';
  static const String vehicleNotFound = '/vehicle-not-found';
  static const String transactionCreation = '/transaction-creation';
  static const String transactionSuccess = '/transaction-success';
  static const String paymentSuccess = '/payment-success';
  static const String notifications = '/notifications';
  static const String scanner = '/scanner';
  static const String viewCompanies = '/view-companies';
  static const String companyDetail = '/company-detail';
  static const String viewAgents = '/view-agents';
  static const String agentDetail = '/agent-detail';
  static const String viewTerminals = '/view-terminals';

  static Map<String, WidgetBuilder> routes = {
    root: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    corporateRegistration: (context) => const CorporateRegistrationScreen(),
    agentRegistration: (context) => const AgentRegistrationScreen(),
    terminalProfiling: (context) => const TerminalProfilingScreen(),
    onboardingComplete: (context) => const OnboardingCompleteScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    agentDashboard: (context) => const AgentDashboardScreen(),
    companyVerify: (context) => ChangeNotifierProvider(
      create: (_) => CompanyVerifyViewModel(),
      child: const CompanyVerifyScreen(),
    ),
    vehicleSearch: (context) => const VehicleSearchScreen(),
    vehicleFound: (context) => const VehicleFoundScreen(),
    vehicleNotFound: (context) => const VehicleNotFoundScreen(),
    transactionCreation: (context) => const TransactionCreationScreen(),
    transactionSuccess: (context) => const TransactionSuccessScreen(),
    paymentSuccess: (context) => const PaymentSuccessLinkHandler(),
    notifications: (context) => const NotificationScreen(),
    scanner: (context) => const ScannerView(),
    viewCompanies: (context) => ChangeNotifierProvider(
      create: (_) => ViewCompaniesViewModel(),
      child: const ViewCompaniesScreen(),
    ),
    companyDetail: (context) {
      final company = ModalRoute.of(context)!.settings.arguments as CompanyModel;
      return CompanyDetailScreen(company: company);
    },
    viewAgents: (context) => ChangeNotifierProvider(
      create: (_) => ViewAgentsViewModel(),
      child: const ViewAgentsScreen(),
    ),
    agentDetail: (context) {
      final agent = ModalRoute.of(context)!.settings.arguments as AgentModel;
      return ChangeNotifierProvider(
        create: (_) => AgentDetailViewModel(agent: agent),
        child: AgentDetailScreen(agent: agent),
      );
    },
    viewTerminals: (context) => ChangeNotifierProvider(
      create: (_) => ViewTerminalsViewModel(),
      child: const ViewTerminalsScreen(),
    ),
  };
}

class PaymentSuccessLinkHandler extends StatelessWidget {
  const PaymentSuccessLinkHandler({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Signal the Success ViewModel that we've returned from a successful payment
      TransactionSuccessViewModel.signalPaymentSuccess();
      
      // Close this link handler and return to the underlying screen
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
    
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Processing Payment Result...', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
