class ApiConstants {
  ApiConstants._();

  static const String _envUrl = String.fromEnvironment('LARAVEL_BASE_URL');
  static const String laravelBaseUrl = _envUrl == ''
      ? 'https://tms-local-api.justerrand.ie/api/v1'
      : _envUrl;

  static const String defaultApiKey = String.fromEnvironment('TMS_API_KEY');
  static const String defaultChannelNumber =
      String.fromEnvironment('TMS_CHANNEL_NUMBER');
  static const String defaultValidationServiceNumber =
      String.fromEnvironment('TMS_VALIDATION_SERVICE_NUMBER');
  static const String defaultTransactionServiceNumber =
      String.fromEnvironment('TMS_TRANSACTION_SERVICE_NUMBER');

  static const Duration timeout = Duration(seconds: 30);

  /// The single TMS endpoint — all actions are POSTed here with key+action in body.
  static const String tmsEndpoint = '';


  // Official Laravel proxy endpoints used by the Flutter app.
  static const String validateVehicle = '/validation/validate-customer';
  static const String createTransaction = '/transaction/create-transaction';
  static const String approveTransaction = '/transaction/approve-transaction';
  static const String declineTransaction = '/transaction/decline-transaction';
  static const String registerVehicle = '/vehicle/register';
  static const String createCompany = '/corporate/create-company';
  static const String addAgent = '/agent/add-agent';
  static const String createTerminal = '/terminal/create-terminal-profile';
  static const String listTransactions = '/transaction/list-transactions';
  static const String verifyTransaction = '/transaction/verify-transaction';
  static const String abandonTransaction = '/transaction/abandon-transaction';
  static const String invalidateTransaction =
      '/transaction/invalidate-transaction';
  static const String getStates = '/state/get-states';
  static const String getLgas = '/state/get-lgas';
  static const String login = '/auth/login';

  // Agent management
  static const String listAgents = '/agent/list-agents';
  static const String getAgent = '/agent/get-agent';
  static const String getAgentStatus = '/agent/get-agent-status';
  static const String getAgentKycStatus = '/agent/get-kyc-status';
  static const String assignAgentToCompany = '/agent/assign-agent-to-company';

  // Corporate management
  static const String getCompanyKycStatus = '/corporate/get-company-kyc-status';
  static const String getCompanyStatus = '/corporate/get-company-status';

  // Session-based values (read from SessionManager at runtime)
  static const String channelNumberKey = 'channel_number';
  static const String serviceNumberValidationKey = 'service_number_validation';
  static const String serviceNumberTransactionKey =
      'service_number_transaction';

  // Legacy constant kept for inactive files.
  static const String baseUrl = laravelBaseUrl;
  static const String apiKey = defaultApiKey;
  static const String serviceNumber = defaultValidationServiceNumber;
  static const String channelNumber = defaultChannelNumber;

  static const String actionCreateCompany = 'create-company';
  static const String actionAddAgent = 'add-agent';
  static const String actionGetAgentDetails = 'get-agent-details';
  static const String actionGetAgentStatus = 'get-agent-status';
  static const String actionAssignAgentToCompany = 'assign-agent-to-company';
  static const String actionCreateTerminal = 'create-terminal';
  static const String actionValidateCustomer = 'validate-customer';
  static const String actionCreateTransaction = 'create-transaction';
  static const String actionApproveTransaction = 'approve-transaction';
  static const String actionDeclineTransaction = 'decline-transaction';
  static const String actionVerifyTransaction = 'verify-transaction';
  static const String actionGetStates = 'get-states';
  static const String actionGetLgas = 'get-lgas';
  static const String actionLogin = 'login';
  static const String actionGetCompany = 'get-company';
  static const String actionGetAllCompanies = 'get-all-companies';

  static const String validateCustomer = validateVehicle;
  static const String getCompany = '/corporate/get-company';
  static const String getTerminalProfile = '/terminal/get-terminalprofile';
  static const String terminalStatus = '/terminal/terminal-status';
  static const String assignTerminal = '/terminal/assign-terminal';
  static const String enableDisableTerminal =
      '/terminal/enable-disable-terminal';

  // Payment methods
  static const String paymentMethodCard = 'card';
  static const String paymentMethodWallet = 'wallet';
  static const String paymentMethodTransfer = 'transfer';

  // Transaction types
  static const String transactionTypeSingle = 'single';
  static const String transactionTypeComplete = 'complete';

  static List<String> get paymentMethods =>
      [paymentMethodCard, paymentMethodWallet, paymentMethodTransfer];

  static List<String> get transactionTypes =>
      [transactionTypeSingle, transactionTypeComplete];
}
