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
      final rawDataList = data['data_list'];
      if (rawDataList is List) {
        list = rawDataList;
      } else if (rawDataList is Map) {
        list = (rawDataList).values.toList();
      } else if (data.containsKey('terminal_id')) {
        list = [data];
      } else {
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

  Future<ApiResponse<Map<String, dynamic>>> getTerminalDetail({
    required String id,
  }) async {
    AppLogger.logInfo(_tag, 'Getting terminal detail for: $id');

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionGetTerminalDetail,
      fields: {'id': id},
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
