import 'package:flutter/material.dart';
import '../../data/models/terminal_model.dart';
import '../../data/repositories/terminal_repository.dart';
import '../../core/utils/logger.dart';

class ViewTerminalsViewModel extends ChangeNotifier {
  static const String _tag = 'ViewTerminalsVM';
  final TerminalRepository _terminalRepository = TerminalRepository();

  List<TerminalModel> _terminals = [];
  List<TerminalModel> get terminals => _terminals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadTerminals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _terminalRepository.listTerminals();

      if (response.success) {
        _terminals = response.data ?? [];
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to load terminals';
        AppLogger.logWarning(_tag, 'Load terminals failed: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while parsing terminal data.';
      AppLogger.logError(_tag, 'Exception in loadTerminals', e);
    }

    _isLoading = false;
    notifyListeners();
  }
}
