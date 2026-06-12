class CorporateEntity {
  final String name;
  final String rcNumber;
  final String email;
  final String phoneNumber;
  final String address;
  final String contactAddress;
  final String tin;
  final String city;
  final String state;
  final String lga;

  final String? cac;
  final String? cac7;
  final String? memat;
  final String? proofOfAddress;
  final String? cacStatus;

  const CorporateEntity({
    required this.name,
    required this.rcNumber,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.contactAddress,
    required this.tin,
    required this.city,
    required this.state,
    required this.lga,
    this.cac,
    this.cac7,
    this.memat,
    this.proofOfAddress,
    this.cacStatus,
  });

  CorporateEntity copyWith({
    String? name,
    String? rcNumber,
    String? email,
    String? phoneNumber,
    String? address,
    String? contactAddress,
    String? tin,
    String? city,
    String? state,
    String? lga,
    String? cac,
    String? cac7,
    String? memat,
    String? proofOfAddress,
    String? cacStatus,
  }) {
    return CorporateEntity(
      name: name ?? this.name,
      rcNumber: rcNumber ?? this.rcNumber,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      contactAddress: contactAddress ?? this.contactAddress,
      tin: tin ?? this.tin,
      city: city ?? this.city,
      state: state ?? this.state,
      lga: lga ?? this.lga,
      cac: cac ?? this.cac,
      cac7: cac7 ?? this.cac7,
      memat: memat ?? this.memat,
      proofOfAddress: proofOfAddress ?? this.proofOfAddress,
      cacStatus: cacStatus ?? this.cacStatus,
    );
  }

  @override
  String toString() {
    return 'CorporateEntity(name: $name, rcNumber: $rcNumber, email: $email, '
        'phoneNumber: $phoneNumber, state: $state, lga: $lga, '
        'hasDocuments: ${cac != null || cac7 != null || memat != null || proofOfAddress != null || cacStatus != null})';
  }
}
