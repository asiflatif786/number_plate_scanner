class ApiConstants {
  static const String baseUrl = 'https://tmsdev.cyber1apps.com';
  static const String apiKey = 'GJU3DCRTYDPTBL18';
  static const String channelNumber = 'CH84693954642';
  static const String serviceNumber = 'S13401182324';

  // Corporate
  static const String createCompany = '/api/corporate/create-company';
  static const String getCompany = '/api/corporate/get-company';
  static const String getCompanyStatus = '/api/corporate/get-company-status';
  static const String getCompanyKycStatus = '/api/corporate/get-company-kycstatus';

  // Agent
  static const String addAgent = '/api/agent/add-agent';
  static const String getAgent = '/api/agent/get-agent';
  static const String getAgentStatus = '/api/agent/get-agent-status';
  static const String listAgents = '/api/agent/list-agents';
  static const String assignAgentToCompany = '/api/agent/assign-agent-to-company';

  // Terminal
  static const String createTerminal = '/api/terminal/create-terminal-profile';
  static const String assignTerminal = '/api/terminal/assign-terminal';
  static const String getTerminalProfile = '/api/terminal/getterminalprofile';
  static const String terminalStatus = '/api/terminal/terminal-status';
  static const String enableDisableTerminal = '/api/terminal/enable-disableterminal';

  // Validation
  static const String validateCustomer = '/api/validation/validate-customer';
  static const String registerVehicle = '/api/vehicle/register-vehicle';

  // Transaction
  static const String createTransaction = '/api/transaction/create-transaction';
  static const String approveTransaction = '/api/transaction/approve-transaction';
  static const String declineTransaction = '/api/transaction/decline-transaction';
  static const String verifyTransaction = '/api/transaction/verify-transaction';
  static const String listTransactions = '/api/transaction/listtransactions';
  static const String abandonTransaction = '/api/transaction/abandon-transaction';

  // Enums
  static const String getTitles = '/api/enum/get-title';
  static const String getIdentityTypes = '/api/enum/get-identity-type';
  static const String getStates = '/api/state/get-states';
  static const String getLgas = '/api/state/get-lgas';
}
