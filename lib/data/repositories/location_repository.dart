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

    // POST to /api_data with action: 'get-states'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionGetStates,
    );

    if (response.success && response.data != null) {
      final raw = response.data!['data'] ?? response.data!['data_list'] ?? [];
      final states = (raw as List).map((e) {
        if (e is Map<String, dynamic>) return StateModel.fromJson(e);
        final stateName = e.toString();
        return StateModel(stateId: stateName, stateName: stateName);
      }).toList();
      _cachedStates = states;
      return ApiResponse.success(states, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<List<LgaModel>>> getLgas(String stateId) async {
    if (_lgaCache.containsKey(stateId)) {
      return ApiResponse.success(_lgaCache[stateId]!, 'Loaded from cache');
    }

    // POST to /api_data with action: 'get-lgas'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionGetLgas,
      fields: {
        'state_id': stateId,
      },
    );

    if (response.success && response.data != null) {
      final raw = response.data!['data'] ?? response.data!['data_list'] ?? [];
      final lgas = (raw as List).map((e) {
        if (e is Map<String, dynamic>) return LgaModel.fromJson(e);
        final lgaName = e.toString();
        return LgaModel(lgaId: lgaName, lgaName: lgaName, stateId: stateId);
      }).toList();
      _lgaCache[stateId] = lgas;
      return ApiResponse.success(lgas, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
