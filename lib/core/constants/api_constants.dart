class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://tms-local-api.justerrand.ie/api/api_data';
  static const String apiKey = 'YOUR_API_KEY_HERE';

  static const Duration timeout = Duration(seconds: 30);

  static const String actionCreateCompany = 'create-company';
  static const String actionAddAgent = 'add-agent';
  static const String actionCreateTerminal = 'create-terminal';
  static const String actionValidateCustomer = 'validate-customer';
  static const String actionCreateTransaction = 'create-transaction';
  static const String actionApproveTransaction = 'approve-transaction';
  static const String actionDeclineTransaction = 'decline-transaction';
  static const String actionVerifyTransaction = 'verify-transaction';
  static const String actionGetStates = 'get-states';
  static const String actionGetLgas = 'get-lgas';
  static const String actionLogin = 'login';

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
