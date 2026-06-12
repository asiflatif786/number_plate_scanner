class AgentEntity {
  final String title;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String gender;
  final String maritalStatus;
  final String dateOfBirth;
  final String email;
  final String phoneNumber;

  final String address;
  final String city;
  final String nationality;
  final String state;
  final String lga;
  final String stateOfOrigin;
  final String lgaOfOrigin;

  final String bvn;
  final String nin;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String sortCode;
  final String idType;
  final String identityNumber;
  final String? tin;

  final String companyNumber;

  final String utilityBill;
  final String identityDocument;
  final String passportPhoto;

  const AgentEntity({
    required this.title,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.gender,
    required this.maritalStatus,
    required this.dateOfBirth,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.nationality,
    required this.state,
    required this.lga,
    required this.stateOfOrigin,
    required this.lgaOfOrigin,
    required this.bvn,
    required this.nin,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.sortCode,
    required this.idType,
    required this.identityNumber,
    this.tin,
    required this.companyNumber,
    required this.utilityBill,
    required this.identityDocument,
    required this.passportPhoto,
  });

  AgentEntity copyWith({
    String? title,
    String? firstName,
    String? lastName,
    String? middleName,
    String? gender,
    String? maritalStatus,
    String? dateOfBirth,
    String? email,
    String? phoneNumber,
    String? address,
    String? city,
    String? nationality,
    String? state,
    String? lga,
    String? stateOfOrigin,
    String? lgaOfOrigin,
    String? bvn,
    String? nin,
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? sortCode,
    String? idType,
    String? identityNumber,
    String? tin,
    String? companyNumber,
    String? utilityBill,
    String? identityDocument,
    String? passportPhoto,
  }) {
    return AgentEntity(
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      nationality: nationality ?? this.nationality,
      state: state ?? this.state,
      lga: lga ?? this.lga,
      stateOfOrigin: stateOfOrigin ?? this.stateOfOrigin,
      lgaOfOrigin: lgaOfOrigin ?? this.lgaOfOrigin,
      bvn: bvn ?? this.bvn,
      nin: nin ?? this.nin,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      sortCode: sortCode ?? this.sortCode,
      idType: idType ?? this.idType,
      identityNumber: identityNumber ?? this.identityNumber,
      tin: tin ?? this.tin,
      companyNumber: companyNumber ?? this.companyNumber,
      utilityBill: utilityBill ?? this.utilityBill,
      identityDocument: identityDocument ?? this.identityDocument,
      passportPhoto: passportPhoto ?? this.passportPhoto,
    );
  }

  @override
  String toString() {
    return 'AgentEntity(firstName: $firstName, lastName: $lastName, '
        'email: $email, phoneNumber: $phoneNumber, '
        'companyNumber: $companyNumber)';
  }
}
