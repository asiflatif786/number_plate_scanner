import 'package:flutter/material.dart';

import '../../core/errors/failure.dart';
import '../../core/utils/logger.dart';
import '../../data/models/company_model.dart';
import '../repositories/onboarding_repository.dart';

class CompanyVerifyViewModel extends ChangeNotifier {
  static const String _tag = 'CompVerVM';

  final OnboardingRepository _repository;

  CompanyVerifyViewModel({OnboardingRepository? repository})
      : _repository = repository ?? OnboardingRepository();

  final rcNumberController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  CompanyModel? verifiedCompany;

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  String _friendlyMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Check your network.';
    }
    if (failure is ServerFailure) {
      if (failure.message.toLowerCase().contains('not found')) {
        return 'No company found with this RC number.';
      }
      return failure.message;
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> verifyCompany(BuildContext context) async {
    final rcNumber = rcNumberController.text.trim();

    if (rcNumber.isEmpty) {
      errorMessage = 'Please enter a company RC number';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    verifiedCompany = null;
    notifyListeners();

    try {
      final result = await _repository.verifyCompany(rcNumber);

      if (result.success && result.data != null) {
        verifiedCompany = result.data;
        AppLogger.logInfo(
          _tag,
          'Company verified: ${result.data!.companyNumber}',
        );
      } else if (result.failure != null) {
        errorMessage = _friendlyMessage(result.failure!);
        AppLogger.logWarning(
          _tag,
          'Verify company failed: ${result.failure!.message}',
        );
      } else {
        errorMessage = 'Something went wrong. Please try again.';
      }
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      AppLogger.logError(_tag, 'verifyCompany error', e);
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    rcNumberController.dispose();
    super.dispose();
  }
}
