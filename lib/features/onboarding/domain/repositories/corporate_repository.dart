import '../entities/corporate_entity.dart';

abstract class CorporateRepository {
  Future<String> registerCorporate(CorporateEntity corporate);
  Future<Map<String, dynamic>> getCompanyDetails(String companyNumber);
  Future<bool> getCompanyStatus(String companyNumber);
  Future<bool> getCompanyKycStatus(String companyNumber);
}
