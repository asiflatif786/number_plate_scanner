class AgentModel {
  final int? id;
  final String agentNumber;
  final String title;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String companyNumber;
  final String gender;
  final String maritalStatus;
  final String dateOfBirth;
  final String address;
  final String city;
  final String state;
  final String lga;
  final String stateOfOrigin;
  final String lgaOfOrigin;
  final String nationality;
  final String bvn;
  final String nin;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String? sortCode;
  final String idType;
  final String identityNumber;
  final String? tin;

  const AgentModel({
    this.id,
    required this.agentNumber,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.companyNumber,
    required this.gender,
    required this.maritalStatus,
    required this.dateOfBirth,
    required this.address,
    required this.city,
    required this.state,
    required this.lga,
    required this.stateOfOrigin,
    required this.lgaOfOrigin,
    required this.nationality,
    required this.bvn,
    required this.nin,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.sortCode,
    required this.idType,
    required this.identityNumber,
    this.tin,
  });

  String get fullName => '$title $firstName $lastName';

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()),
      agentNumber: json['agent_number'] as String? ?? '',
      title: json['title'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      companyNumber: json['company_number'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      maritalStatus: json['marital_status'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      lga: json['lga'] as String? ?? '',
      stateOfOrigin: json['state_of_origin'] as String? ?? '',
      lgaOfOrigin: json['lga_of_origin'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      bvn: json['bvn'] as String? ?? '',
      nin: json['nin'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      sortCode: json['sort_code'] as String?,
      idType: json['id_type'] as String? ?? '',
      identityNumber: json['identity_number'] as String? ?? '',
      tin: json['tin'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'agent_number': agentNumber,
        'title': title,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'company_number': companyNumber,
        'gender': gender,
        'marital_status': maritalStatus,
        'date_of_birth': dateOfBirth,
        'address': address,
        'city': city,
        'state': state,
        'lga': lga,
        'state_of_origin': stateOfOrigin,
        'lga_of_origin': lgaOfOrigin,
        'nationality': nationality,
        'bvn': bvn,
        'nin': nin,
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_name': accountName,
        'sort_code': sortCode,
        'id_type': idType,
        'identity_number': identityNumber,
        'tin': tin,
      };

  AgentModel copyWith({
    int? id,
    String? agentNumber,
    String? title,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? companyNumber,
    String? gender,
    String? maritalStatus,
    String? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? lga,
    String? stateOfOrigin,
    String? lgaOfOrigin,
    String? nationality,
    String? bvn,
    String? nin,
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? sortCode,
    String? idType,
    String? identityNumber,
    String? tin,
  }) {
    return AgentModel(
      id: id ?? this.id,
      agentNumber: agentNumber ?? this.agentNumber,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      companyNumber: companyNumber ?? this.companyNumber,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      lga: lga ?? this.lga,
      stateOfOrigin: stateOfOrigin ?? this.stateOfOrigin,
      lgaOfOrigin: lgaOfOrigin ?? this.lgaOfOrigin,
      nationality: nationality ?? this.nationality,
      bvn: bvn ?? this.bvn,
      nin: nin ?? this.nin,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      sortCode: sortCode ?? this.sortCode,
      idType: idType ?? this.idType,
      identityNumber: identityNumber ?? this.identityNumber,
      tin: tin ?? this.tin,
    );
  }
}
