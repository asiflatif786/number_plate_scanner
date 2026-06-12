import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/lga_model.dart';
import '../models/state_model.dart';

class LocationRepository {
  List<StateModel>? _cachedStates;
  final Map<String, List<LgaModel>> _lgaCache = {};

  Future<ApiResponse<List<StateModel>>> getStates() async {
    if (_cachedStates != null) {
      return ApiResponse.success(_cachedStates!, 'Loaded from cache');
    }

    final response = await ApiClient.instance.post({
      'action': ApiConstants.actionGetStates,
    });

    if (response.success && response.data != null) {
      final raw = response.data!['data_list'] as List<dynamic>? ?? [];
      final states = raw
          .map((e) => StateModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _cachedStates = states;
      return ApiResponse.success(states, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<List<LgaModel>>> getLgas(String stateId) async {
    if (_lgaCache.containsKey(stateId)) {
      return ApiResponse.success(_lgaCache[stateId]!, 'Loaded from cache');
    }

    final response = await ApiClient.instance.post({
      'action': ApiConstants.actionGetLgas,
      'state_id': stateId,
    });

    if (response.success && response.data != null) {
      final raw = response.data!['data_list'] as List<dynamic>? ?? [];
      final lgas = raw
          .map((e) => LgaModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _lgaCache[stateId] = lgas;
      return ApiResponse.success(lgas, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
