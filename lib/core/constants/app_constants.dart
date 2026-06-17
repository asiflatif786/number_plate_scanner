class AppConstants {
  AppConstants._();

  static const String appName = 'Cyber1 TMS';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String isOnboardedKey = 'is_onboarded';
  static const String companyNumberKey = 'company_number';
  static const String agentNumberKey = 'agent_number';
  static const String terminalIdKey = 'terminal_id';
  static const String serialNumberKey = 'serial_number';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userFirstNameKey = 'user_first_name';
  static const String userLastNameKey = 'user_last_name';
  static const String authTokenKey = 'auth_token';

  // User Roles
  static const String roleAdmin = 'Admin';
  static const String roleAgent = 'Agent';

  // Agent Title Options
  static const List<String> agentTitles = [
    'Mr',
    'Mrs',
    'Miss',
    'Chief',
    'Dr',
    'Prof',
  ];

  // ID Types
  static const List<String> idTypes = [
    'Voters Card',
    'International Passport',
    'Drivers License',
  ];

  // Gender Options
  static const List<String> genderOptions = ['male', 'female'];

  // Marital Status Options
  static const List<String> maritalStatusOptions = [
    'single',
    'married',
    'engaged',
    'divorced',
    'widowed',
  ];

  // Vehicle Types (as returned by backend)
  static const List<String> vehicleTypes = [
    'Saloon Car',
    'SUV/Jeep (4 Tyres)',
    'Pick Up Vans (4 Tyres)',
    'Pick Up Heavy Duty (6/8 Tyres)',
    'Buses (18+ seater)',
    'Mini Bus (14-17 seater)',
    'Motorcycles',
    'Tricycles (Keke)',
    'Trucks (6 Tyres)',
    'Trucks (10+ Tyres)',
    'Trailers',
    'Tankers',
  ];

  // Fee Calculation Constants
  static const double adminFeePercent = 0.02;
  static const double flatTransactionFee = 100.0;
  static const double vatPercent = 0.075;

  // UI Defaults
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultButtonHeight = 52.0;
}
