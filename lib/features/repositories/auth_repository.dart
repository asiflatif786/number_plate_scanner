import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../data/models/user_model.dart';

class AuthRepository {
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.instance.post({
      'action': ApiConstants.actionLogin,
      'email': email,
      'password': password,
    });

    if (response.success && response.data != null) {
      final user = UserModel.fromJson(response.data!);
      return ApiResponse.success(user, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
