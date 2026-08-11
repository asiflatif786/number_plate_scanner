import '../../core/utils/logger.dart';

class AgentModel {
  final int? id;
  final String agentNumber;
  final String title;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String companyNumber;
  final String rcNumber;
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
  final int mapToCompany;

  const AgentModel({
    this.id,
    required this.agentNumber,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.companyNumber,
    this.rcNumber = '',
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
    this.mapToCompany = 1, // Default to 1 to not show button if not present
  });

  String get fullName => '$title $firstName $lastName';

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    // 1. Resolve where the actual agent data is
    Map<String, dynamic> data = json;
    
    // Handle various response wrappers
    if (json.containsKey('agent_data') && json['agent_data'] is Map) {
      data = json['agent_data'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map) {
      final inner = json['data'] as Map<String, dynamic>;
      if (inner.containsKey('agent_data') && inner['agent_data'] is Map) {
        data = inner['agent_data'] as Map<String, dynamic>;
      } else if (inner.containsKey('email') || inner.containsKey('agent_number')) {
        data = inner;
      }
    }

    // 2. Helper to safely extract string values and handle 'null' strings
    String s(dynamic val) {
      if (val == null) return '';
      final str = val.toString().trim();
      if (str.toLowerCase() == 'null') return '';
      return str;
    }

    // 3. Robust RC Number extraction
    String rc = s(data['rc_number']);
    if (rc.isEmpty) {
      rc = s(json['rc_number']);
    }
    if (rc.isEmpty) {
      // Check nested objects
      final comp = data['company'] ?? json['company'] ?? json['data']?['company'];
      if (comp is Map) {
        rc = s(comp['rc_number']);
      }
    }

    int mtc = 1;
    if (data.containsKey('map_to_company')) {
      mtc = int.tryParse(data['map_to_company'].toString()) ?? 1;
    } else if (json.containsKey('map_to_company')) {
       mtc = int.tryParse(json['map_to_company'].toString()) ?? 1;
    }

    return AgentModel(
      id: data['id'] is int
          ? data['id'] as int
          : int.tryParse(data['id']?.toString() ?? ''),
      agentNumber: s(data['agent_number'] ?? data['id']),
      title: s(data['title']),
      firstName: s(data['first_name']),
      lastName: s(data['last_name']),
      email: s(data['email']),
      phoneNumber: s(data['phone_number'] ?? data['phone']),
      companyNumber: s(data['company_number'] ?? data['corporate_id']),
      rcNumber: rc,
      gender: s(data['gender']),
      maritalStatus: s(data['marital_status']),
      dateOfBirth: s(data['date_of_birth']),
      address: s(data['address']),
      city: s(data['city']),
      state: s(data['state']),
      lga: s(data['lga']),
      stateOfOrigin: s(data['state_of_origin']),
      lgaOfOrigin: s(data['lga_of_origin']),
      nationality: s(data['nationality'] ?? 'Nigerian'),
      bvn: s(data['bvn']),
      nin: s(data['nin']),
      bankName: s(data['bank_name']),
      accountNumber: s(data['account_number']),
      accountName: s(data['account_name']),
      sortCode: data['sort_code']?.toString(),
      idType: s(data['id_type'] ?? data['identity_type']),
      identityNumber: s(data['identity_number']),
      tin: data['tin']?.toString(),
      mapToCompany: mtc,
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
        'rc_number': rcNumber,
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
        'map_to_company': mapToCompany,
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
    String? rcNumber,
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
    int? mapToCompany,
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
      rcNumber: rcNumber ?? this.rcNumber,
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
      mapToCompany: mapToCompany ?? this.mapToCompany,
    );
  }
}
