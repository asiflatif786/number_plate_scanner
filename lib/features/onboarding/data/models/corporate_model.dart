import 'dart:convert';
import '../../domain/entities/corporate_entity.dart';
import '../../../../core/utils/logger.dart';

class CorporateModel {
  static const String _tag = 'CorporateModel';

  static Map<String, dynamic> toJson(CorporateEntity entity) {
    final json = <String, dynamic>{
      'name': entity.name,
      'rc_number': entity.rcNumber,
      'email': entity.email,
      'phone_number': entity.phoneNumber,
      'address': entity.address,
      'contact_address': entity.contactAddress,
      'tin': entity.tin,
      'city': entity.city,
      'state': entity.state.toUpperCase(),
      'lga': entity.lga,
    };

    if (entity.cac != null) json['cac'] = entity.cac;
    if (entity.cac7 != null) json['cac_7'] = entity.cac7;
    if (entity.memat != null) json['memat'] = entity.memat;
    if (entity.proofOfAddress != null) {
      json['proof_of_address'] = entity.proofOfAddress;
    }
    if (entity.cacStatus != null) json['cac_status'] = entity.cacStatus;

    AppLogger.debug(_tag, 'toJson: ${jsonEncode(json)}');
    return json;
  }

  static CorporateEntity fromJson(Map<String, dynamic> json) {
    return CorporateEntity(
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
      cac: json['cac'] as String?,
      cac7: json['cac_7'] as String?,
      memat: json['memat'] as String?,
      proofOfAddress: json['proof_of_address'] as String?,
      cacStatus: json['cac_status'] as String?,
    );
  }
}
