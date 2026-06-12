import '../../domain/entities/agent_entity.dart';
import '../../../../core/utils/logger.dart';

class AgentModel {
  static const String _tag = 'AgentModel';

  static Map<String, dynamic> toJson(AgentEntity entity) {
    final hasUtilityBill = entity.utilityBill.isNotEmpty;
    final hasIdentityDoc = entity.identityDocument.isNotEmpty;
    final hasPassportPhoto = entity.passportPhoto.isNotEmpty;

    AppLogger.debug(_tag,
        'Documents attached: utility_bill=$hasUtilityBill, identity_document=$hasIdentityDoc, passport_photo=$hasPassportPhoto');

    final json = <String, dynamic>{
      'title': entity.title,
      'first_name': entity.firstName,
      'last_name': entity.lastName,
      'middle_name': entity.middleName,
      'gender': entity.gender,
      'marital_status': entity.maritalStatus,
      'date_of_birth': entity.dateOfBirth,
      'email': entity.email,
      'phone_number': entity.phoneNumber,
      'address': entity.address,
      'city': entity.city,
      'nationality': entity.nationality,
      'state': entity.state.toUpperCase(),
      'lga': entity.lga,
      'state_of_origin': entity.stateOfOrigin.toUpperCase(),
      'lga_of_origin': entity.lgaOfOrigin.toUpperCase(),
      'bvn': entity.bvn,
      'nin': entity.nin,
      'bank_name': entity.bankName,
      'account_number': entity.accountNumber,
      'account_name': entity.accountName,
      'sort_code': entity.sortCode,
      'id_type': entity.idType,
      'identity_number': entity.identityNumber,
      'tin': entity.tin,
      'company_number': entity.companyNumber,
      'utility_bill': entity.utilityBill,
      'identity_document': entity.identityDocument,
      'passport_photo': entity.passportPhoto,
    };

    AppLogger.debug(_tag, 'Payload built');
    return json;
  }

  static AgentEntity fromJson(Map<String, dynamic> json) {
    return AgentEntity(
      title: json['title'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      gender: json['gender'] as String? ?? '',
      maritalStatus: json['marital_status'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      state: json['state'] as String? ?? '',
      lga: json['lga'] as String? ?? '',
      stateOfOrigin: json['state_of_origin'] as String? ?? '',
      lgaOfOrigin: json['lga_of_origin'] as String? ?? '',
      bvn: json['bvn'] as String? ?? '',
      nin: json['nin'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      sortCode: json['sort_code'] as String? ?? '',
      idType: json['id_type'] as String? ?? '',
      identityNumber: json['identity_number'] as String? ?? '',
      tin: json['tin'] as String?,
      companyNumber: json['company_number'] as String? ?? '',
      utilityBill: json['utility_bill'] as String? ?? '',
      identityDocument: json['identity_document'] as String? ?? '',
      passportPhoto: json['passport_photo'] as String? ?? '',
    );
  }
}
