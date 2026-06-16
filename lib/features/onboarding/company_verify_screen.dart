import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import 'company_verify_viewmodel.dart';

class CompanyVerifyScreen extends StatefulWidget {
  final String? initialRcNumber;
  const CompanyVerifyScreen({super.key, this.initialRcNumber});

  @override
  State<CompanyVerifyScreen> createState() => _CompanyVerifyScreenState();
}

class _CompanyVerifyScreenState extends State<CompanyVerifyScreen> {
  final _rcFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CompanyVerifyViewModel>();
      
      // Check if RC number was passed via constructor or route arguments
      String? rc = widget.initialRcNumber;
      if (rc == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map<String, dynamic>) {
          rc = args['rc_number'];
        } else if (args is String) {
          rc = args;
        }
      }

      if (rc != null && rc.isNotEmpty) {
        vm.rcNumberController.text = rc;
        vm.verifyCompany(context);
      }
    });
  }

  @override
  void dispose() {
    _rcFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Verify Company'),
        elevation: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<CompanyVerifyViewModel>(
            builder: (context, vm, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildProgressBar(),
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildCompanyCard(vm),
                    const SizedBox(height: 16),
                    if (vm.verifiedCompany != null) _buildCompanyInfo(vm),
                    const SizedBox(height: 12),
                    _buildErrorBanner(vm),
                    const SizedBox(height: 16),
                    _buildActionButton(vm),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _stepDot(label: 'Company', isActive: true),
          _stepConnector(),
          _stepDot(label: 'Agent', isActive: false),
          _stepConnector(),
          _stepDot(label: 'Terminal', isActive: false),
        ],
      ),
    );
  }

  Widget _stepDot({required String label, required bool isActive}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1A237E)
                  : const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isActive ? '1' : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive
                  ? const Color(0xFF1A237E)
                  : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepConnector() {
    return Container(
      height: 2,
      width: 32,
      color: const Color(0xFFE0E0E0),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Company',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Enter the company RC number to verify before adding an agent',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
      ],
    );
  }

  Widget _buildCompanyCard(CompanyVerifyViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company RC Number',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: vm.rcNumberController,
            focusNode: _rcFocus,
            decoration: InputDecoration(
              hintText: 'e.g. RC1234567',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => vm.verifyCompany(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(CompanyVerifyViewModel vm) {
    final company = vm.verifiedCompany!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Company Verified',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Company Name', company.name),
          _infoRow('RC Number', company.rcNumber),
          _infoRow('Company Number', company.companyNumber),
          if (company.email.isNotEmpty) _infoRow('Email', company.email),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF616161)),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(CompanyVerifyViewModel vm) {
    if (vm.errorMessage == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFC62828).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              vm.errorMessage!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFC62828)),
            ),
          ),
          GestureDetector(
            onTap: vm.clearError,
            child: const Icon(Icons.close, color: Color(0xFFC62828), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(CompanyVerifyViewModel vm) {
    final verified = vm.verifiedCompany != null;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: vm.isLoading
            ? null
            : () {
                if (verified) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.agentRegistration,
                    arguments: {
                      'company_number': vm.verifiedCompany!.companyNumber,
                      'company_name': vm.verifiedCompany!.name,
                    },
                  );
                } else {
                  vm.verifyCompany(context);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: verified
              ? const Color(0xFF2E7D32)
              : const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: vm.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                verified ? 'Continue to Agent Registration' : 'Verify Company',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
