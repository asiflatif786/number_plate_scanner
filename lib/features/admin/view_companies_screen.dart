import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../data/models/company_model.dart';
import 'view_companies_viewmodel.dart';

class ViewCompaniesScreen extends StatefulWidget {
  const ViewCompaniesScreen({super.key});

  @override
  State<ViewCompaniesScreen> createState() => _ViewCompaniesScreenState();
}

class _ViewCompaniesScreenState extends State<ViewCompaniesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewCompaniesViewModel>().loadCompanies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Companies'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ViewCompaniesViewModel>(
        builder: (context, vm, _) => Column(
          children: [
            _buildSearchBar(vm),
            _buildSummaryRow(vm),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ViewCompaniesViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: AppTextField(
        label: 'Search',
        hint: 'Search by name or RC number',
        controller: _searchController,
        prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  vm.onSearchChanged('');
                },
              )
            : null,
        onChanged: vm.onSearchChanged,
        fillColor: Colors.grey.shade50,
        customPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  Widget _buildSummaryRow(ViewCompaniesViewModel vm) {
    if (vm.isLoading && vm.companies.isEmpty) return const SizedBox.shrink();
    
    final count = vm.filteredCompanies.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            'Showing $count compan${count == 1 ? 'y' : 'ies'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (vm.searchQuery.isNotEmpty)
            Text(
              ' • filtered',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          const Spacer(),
          if (vm.totalCompanies > 0)
            Text(
              '${vm.totalCompanies} total',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ViewCompaniesViewModel vm) {
    if (vm.isLoading && vm.companies.isEmpty) return _buildShimmerList();

    if (vm.errorMessage != null && vm.companies.isEmpty) {
      return ErrorStateWidget(
        message: vm.errorMessage!,
        onRetry: () => vm.loadCompanies(),
      );
    }

    if (vm.companies.isEmpty && !vm.isLoading) {
      return EmptyStateWidget(
        title: 'No companies registered yet',
        message: 'Add a new company from the dashboard',
        icon: Icons.business_outlined,
      );
    }

    if (vm.searchQuery.isNotEmpty && vm.filteredCompanies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64, color: Color(0xFFBDBDBD)),
              const SizedBox(height: 16),
              Text(
                "No companies found for '${vm.searchQuery}'",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: vm.filteredCompanies.length,
        itemBuilder: (context, index) {
          return _companyCard(vm.filteredCompanies[index], index + 1);
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return const ShimmerLoader(itemCount: 6, itemHeight: 80);
  }

  Widget _companyCard(CompanyModel company, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            company.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('RC: ${company.rcNumber}',
                  style: const TextStyle(fontSize: 12)),
              Text(company.email, style: const TextStyle(fontSize: 12)),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.companyDetail,
              arguments: company,
            );
          },
        ),
      ),
    );
  }
}
