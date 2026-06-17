import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/logger.dart';
import '../models/terminal_model.dart';

class TerminalRepository {
  static const String _tag = 'TerminalRepo';

  Future<ApiResponse<List<TerminalModel>>> listTerminals() async {
    AppLogger.logInfo(_tag, 'Listing all POS terminals via TMS action: view-terminals');

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionViewTerminals,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      List<dynamic> list = [];

      // Handle different possible response structures
      if (data['data_list'] is List) {
        list = data['data_list'] as List;
      } else if (data['data_list'] is Map) {
        // Handle associative array/object representing a list
        list = (data['data_list'] as Map).values.toList();
      } else if (data.containsKey('terminal_id')) {
        // Single terminal object returned directly
        list = [data];
      } else {
        // Fallback: try to see if the map values themselves are terminals
        final values = data.values.whereType<Map<String, dynamic>>().toList();
        if (values.isNotEmpty && values.any((v) => v.containsKey('terminal_id'))) {
          list = values;
        }
      }

      final terminals = list
          .whereType<Map<String, dynamic>>()
          .map((e) => TerminalModel.fromJson(e))
          .toList();

      AppLogger.logInfo(_tag, 'Successfully retrieved ${terminals.length} terminals');
      return ApiResponse.success(terminals, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
