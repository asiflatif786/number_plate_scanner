import 'package:flutter/material.dart';
import '../../core/utils/logger.dart';
import '../../data/models/company_model.dart';
import '../../data/repositories/company_repository.dart';

class CompanyDetailViewModel extends ChangeNotifier {
  static const String _tag = 'CompanyDetVM';
  final CompanyRepository _repository = CompanyRepository();

  final CompanyModel company;
  bool _isCheckingExistence = false;
  bool _vendorExists = false;

  bool get isCheckingExistence => _isCheckingExistence;
  bool get vendorExists => _vendorExists;

  CompanyDetailViewModel({required this.company}) {
    checkCompanyExistence();
  }

  Future<void> checkCompanyExistence() async {
    if (company.rcNumber.isEmpty) return;

    _isCheckingExistence = true;
    notifyListeners();

    try {
      final result = await _repository.checkVendorExists(company.rcNumber);
      if (result.success) {
        _vendorExists = result.data ?? false;
        AppLogger.logInfo(_tag, 'Vendor existence check: $_vendorExists');
      } else {
        _vendorExists = false;
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Error checking company existence: $e');
      _vendorExists = false;
    } finally {
      _isCheckingExistence = false;
      notifyListeners();
    }
  }
}
