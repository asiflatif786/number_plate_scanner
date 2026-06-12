class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://tms-local-api.justerrand.ie/api/api_data';
  static const String apiKey = 'tms_local_1776144090';

  static const Duration timeout = Duration(seconds: 30);

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

  // Legacy mappings for older repositories
  static const String addAgent = actionAddAgent;
  static const String getAgentDetails = actionGetAgentDetails;
  static const String getAgentStatus = actionGetAgentStatus;
  static const String assignAgentToCompany = actionAssignAgentToCompany;

  static const String createCompany = actionCreateCompany;
  static const String getCompany = 'get-company';
  static const String getCompanyStatus = 'get-company-status';
  static const String getCompanyKycStatus = 'get-company-kyc-status';

  static const String createTerminal = actionCreateTerminal;
  static const String getTerminalProfile = 'get-terminal-profile';
  static const String terminalStatus = 'get-terminal-status';
  static const String assignTerminal = 'assign-terminal';
  static const String enableDisableTerminal = 'enable-disable-terminal';

  static const String createTransaction = actionCreateTransaction;
  static const String approveTransaction = actionApproveTransaction;
  static const String declineTransaction = actionDeclineTransaction;
  static const String verifyTransaction = actionVerifyTransaction;
  static const String abandonTransaction = 'abandon-transaction';
  static const String listTransactions = 'list-transactions';

  static const String validateCustomer = actionValidateCustomer;
  static const String registerVehicle = 'register-vehicle';

  static const String channelNumber = '1';
  static const String serviceNumber = '1';

  static const String paymentMethodCard = 'card';
  static const String paymentMethodWallet = 'wallet';
  static const String paymentMethodTransfer = 'transfer';

  static const String transactionTypeSingle = 'single';
  static const String transactionTypeComplete = 'complete';

  static List<String> get paymentMethods =>
      [paymentMethodCard, paymentMethodWallet, paymentMethodTransfer];

  static List<String> get transactionTypes =>
      [transactionTypeSingle, transactionTypeComplete];
}
