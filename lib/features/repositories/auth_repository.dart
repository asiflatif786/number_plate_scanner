import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/user_model.dart';

class AuthRepository {
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    // POST to /api_data with key + action + credentials in body
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionLogin, // 'login'
      fields: {
        'email': email,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      // If server returns an updated API key, persist it
      final apiKey = response.data!['api_key'] as String? ??
          response.data!['api-key'] as String? ??
          response.data!['key'] as String?;
      if (apiKey != null && apiKey.isNotEmpty) {
        ApiClient.instance.setApiKey(apiKey);
      }

      final user = UserModel.fromJson(response.data!);
      return ApiResponse.success(user, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
