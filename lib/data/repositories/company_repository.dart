import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/logger.dart';

class CompanyRepository {
  static const String _tag = 'CompanyRepo';

  Future<ApiResponse<bool>> checkVendorExists(String rcNumber) async {
    AppLogger.logInfo(_tag, 'Checking if vendor exists: $rcNumber');

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionCheckVendorExist,
      fields: {'rc_number': rcNumber},
    );

    if (response.success) {
      // Assuming if success is true, the vendor exists based on user's provided response example
      // where status_code "00" indicates success/found.
      return ApiResponse.success(true, response.message);
    }

    // If it fails (e.g. 404 or business logic error), it likely doesn't exist or there was an error.
    // We'll treat failure as non-existence for the purpose of showing the "Add" button.
    return ApiResponse.success(false, response.message);
  }
}
