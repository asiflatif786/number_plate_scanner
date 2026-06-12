class CompanyModel {
  final String companyNumber;
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

  const CompanyModel({
    required this.companyNumber,
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
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyNumber: json['company_number'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rcNumber: json['rc_number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      contactAddress: json['contact_address'] as String? ?? '',
      tin: json['tin'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      lga: json['lga'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'company_number': companyNumber,
        'name': name,
        'rc_number': rcNumber,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
        'contact_address': contactAddress,
        'tin': tin,
        'city': city,
        'state': state,
        'lga': lga,
      };

  CompanyModel copyWith({
    String? companyNumber,
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
  }) {
    return CompanyModel(
      companyNumber: companyNumber ?? this.companyNumber,
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
    );
  }
}
