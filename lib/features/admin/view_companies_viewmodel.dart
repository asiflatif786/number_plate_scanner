import 'package:flutter/material.dart';
import '../../core/utils/logger.dart';
import '../../data/models/company_model.dart';
import '../repositories/onboarding_repository.dart';

class ViewCompaniesViewModel extends ChangeNotifier {
  static const String _tag = 'ViewCompaniesVM';
  final OnboardingRepository _repository = OnboardingRepository();

  List<CompanyModel> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<CompanyModel> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get totalCompanies => _companies.length;

  List<CompanyModel> get filteredCompanies {
    if (_searchQuery.isEmpty) return _companies;
    final q = _searchQuery.toLowerCase();
    return _companies.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.companyNumber.toLowerCase().contains(q) ||
          c.rcNumber.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> loadCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAllCompanies();

    if (result.success) {
      _companies = result.data ?? [];
    } else {
      _errorMessage = result.failure?.message ?? 'Failed to load companies';
      AppLogger.logWarning(_tag, _errorMessage!);
    }

    _isLoading = false;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> onRefresh() async {
    await loadCompanies();
  }
}
