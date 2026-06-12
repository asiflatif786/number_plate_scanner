import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/corporate_entity.dart';
import '../../domain/repositories/corporate_repository.dart';
import '../models/corporate_model.dart';
import '../models/corporate_response_model.dart';

class CorporateRepositoryImpl implements CorporateRepository {
  static const String _tag = 'CorporateRepo';
  final NetworkClient _networkClient;

  CorporateRepositoryImpl({required NetworkClient networkClient})
      : _networkClient = networkClient;

  @override
  Future<String> registerCorporate(CorporateEntity corporate) async {
    AppLogger.info(_tag, 'Registering corporate: ${corporate.name}');

    try {
      final json = CorporateModel.toJson(corporate);
      final response = await _networkClient.post(
        ApiConstants.createCompany,
        body: json,
      );

      final responseModel = CorporateResponseModel.fromJson(response);
      final companyNumber = responseModel.companyNumber;

      if (companyNumber == null || companyNumber.isEmpty) {
        AppLogger.error(_tag, 'Company number not found in response');
        throw const ServerFailure('Company number not found in response');
      }

      AppLogger.success(_tag, 'Company registered: $companyNumber');
      return companyNumber;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to register corporate', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCompanyDetails(String companyNumber) async {
    AppLogger.info(_tag, 'Fetching company details: $companyNumber');

    try {
      final response = await _networkClient.get(
        ApiConstants.getCompany,
        queryParams: {'company_number': companyNumber},
      );

      AppLogger.success(_tag, 'Company details fetched');
      return response;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch company details', e);
      rethrow;
    }
  }

  @override
  Future<bool> getCompanyStatus(String companyNumber) async {
    AppLogger.info(_tag, 'Fetching company status: $companyNumber');

    try {
      final response = await _networkClient.get(
        ApiConstants.getCompanyStatus,
        queryParams: {'company_number': companyNumber},
      );

      final status = response['data'] is Map
          ? (response['data'] as Map)['status'] as String?
          : null;
      final isActive = status?.toLowerCase() == 'active';
      AppLogger.info(_tag, 'Company status: $status → active: $isActive');
      return isActive;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch company status', e);
      rethrow;
    }
  }

  @override
  Future<bool> getCompanyKycStatus(String companyNumber) async {
    AppLogger.info(_tag, 'Fetching company KYC status: $companyNumber');

    try {
      final response = await _networkClient.get(
        ApiConstants.getCompanyKycStatus,
        queryParams: {'company_number': companyNumber},
      );

      final kycStatus = response['data'] is Map
          ? (response['data'] as Map)['kyc_status'] as String?
          : null;
      final isComplete = kycStatus?.toLowerCase() == 'complete';
      AppLogger.info(_tag, 'Company KYC status: $kycStatus → complete: $isComplete');
      return isComplete;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch company KYC status', e);
      rethrow;
    }
  }
}
