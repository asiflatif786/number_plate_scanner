class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? agentNumber;
  final String? companyNumber;
  final String? authToken;
  final String? channelNumber;
  final String? serviceNumberValidation;
  final String? serviceNumberTransaction;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.agentNumber,
    this.companyNumber,
    this.authToken,
    this.channelNumber,
    this.serviceNumberValidation,
    this.serviceNumberTransaction,
  });

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == 'Admin';
  bool get isAgent => role == 'Agent';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      agentNumber: json['agent_number'] as String?,
      companyNumber: json['company_number'] as String?,
      authToken: json['token'] as String?,
      channelNumber: json['channel_number'] as String?,
      serviceNumberValidation: json['service_number_validation'] as String? ?? json['service_number'] as String?,
      serviceNumberTransaction: json['service_number_transaction'] as String? ?? json['service_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
        'agent_number': agentNumber,
        'company_number': companyNumber,
        'token': authToken,
        'channel_number': channelNumber,
        'service_number_validation': serviceNumberValidation,
        'service_number_transaction': serviceNumberTransaction,
      };

  UserModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? agentNumber,
    String? companyNumber,
    String? authToken,
    String? channelNumber,
    String? serviceNumberValidation,
    String? serviceNumberTransaction,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      agentNumber: agentNumber ?? this.agentNumber,
      companyNumber: companyNumber ?? this.companyNumber,
      authToken: authToken ?? this.authToken,
      channelNumber: channelNumber ?? this.channelNumber,
      serviceNumberValidation: serviceNumberValidation ?? this.serviceNumberValidation,
      serviceNumberTransaction: serviceNumberTransaction ?? this.serviceNumberTransaction,
    );
  }
}
