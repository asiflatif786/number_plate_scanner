import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/network/network_client.dart';
import 'core/router/app_router.dart';
import 'core/services/session_provider.dart';
import 'core/utils/logger.dart';
import 'features/onboarding/data/repositories/agent_repository_impl.dart';
import 'features/onboarding/data/repositories/corporate_repository_impl.dart';
import 'features/onboarding/data/repositories/terminal_repository_impl.dart';
import 'features/onboarding/presentation/viewmodels/agent_viewmodel.dart';
import 'features/onboarding/presentation/viewmodels/corporate_viewmodel.dart';
import 'features/onboarding/presentation/viewmodels/terminal_viewmodel.dart';
import 'features/transaction/data/repositories/transaction_repository_impl.dart';
import 'features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'features/vehicle/presentation/viewmodels/vehicle_registration_viewmodel.dart';
import 'features/vehicle/presentation/viewmodels/vehicle_search_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info(
      'App', 'Starting ${AppConstants.appName} v${AppConstants.appVersion}');
  runApp(const Cyber1TMSApp());
}

class Cyber1TMSApp extends StatelessWidget {
  const Cyber1TMSApp({super.key});

  static final VehicleRepositoryImpl _vehicleRepo = VehicleRepositoryImpl(
    networkClient: NetworkClient.instance,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(
          create: (_) => CorporateViewModel(
            repository: CorporateRepositoryImpl(
              networkClient: NetworkClient.instance,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AgentViewModel(
            repository: AgentRepositoryImpl(
              networkClient: NetworkClient.instance,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TerminalViewModel(
            repository: TerminalRepositoryImpl(
              networkClient: NetworkClient.instance,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => VehicleSearchViewModel(repository: _vehicleRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              VehicleRegistrationViewModel(repository: _vehicleRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionViewModel(
            repository: TransactionRepositoryImpl(
              networkClient: NetworkClient.instance,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A237E),
            primary: const Color(0xFF1A237E),
            secondary: const Color(0xFF0288D1),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF1A237E),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultRadius),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
        initialRoute: '/splash',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
