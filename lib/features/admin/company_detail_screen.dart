import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/company_model.dart';
import 'add_bank_account_viewmodel.dart';

class CompanyDetailScreen extends StatelessWidget {
  final CompanyModel company;

  const CompanyDetailScreen({super.key, required this.company});

  void _handleAddCompanyToPayment(BuildContext context) async {
    final vm = context.read<AddBankAccountViewModel>();
    
    // Pre-populate VM with company details
    vm.setFromCompany(company);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Call the create-vendor-account API
    final success = await vm.createVendorAccount();
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Navigate to bank account management screen to continue the flow
        Navigator.pushNamed(
          context, 
          AppRoutes.addBankAccount,
          // We don't pass company arg here because we already pre-filled and advanced the VM state
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Failed to add company to payment system'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Company Details'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildInfoSection('Basic Information', [
              _infoRow('RC Number', company.rcNumber),
              _infoRow('Company Number', company.companyNumber),
              _infoRow('TIN', company.tin),
              _infoRow('Status', company.status, isStatus: true),
            ]),
            const SizedBox(height: 16),
            _buildInfoSection('Contact Details', [
              _infoRow('Email', company.email),
              _infoRow('Phone', company.phoneNumber),
            ]),
            const SizedBox(height: 16),
            _buildInfoSection('Location', [
              _infoRow('Address', company.address),
              _infoRow('Contact Address', company.contactAddress),
              _infoRow('City', company.city),
              _infoRow('State', company.state),
              _infoRow('LGA', company.lga),
            ]),
            const SizedBox(height: 32),
            _buildAddAgentButton(context),
            const SizedBox(height: 12),
            _buildAddCompanyToPaymentButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: Color(0xFF1A237E), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RC: ${company.rcNumber}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: isStatus
                ? _statusBadge(value)
                : Text(
                    value.isNotEmpty ? value : '—',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildAddAgentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.companyVerify,
            arguments: {'rc_number': company.rcNumber},
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Agent for this Company'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildAddCompanyToPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _handleAddCompanyToPayment(context),
        icon: const Icon(Icons.account_balance),
        label: const Text('Add Company To Payment System'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1A237E)),
          foregroundColor: const Color(0xFF1A237E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
