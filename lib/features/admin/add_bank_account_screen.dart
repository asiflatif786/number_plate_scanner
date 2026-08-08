import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/company_model.dart';
import 'add_bank_account_viewmodel.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _bankProfileFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _lookupFormKey = GlobalKey<FormState>();
  
  final _bvnController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _lookupEmailController = TextEditingController();

  int _currentView = 0; // 0: Management, 1: Lookup

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AddBankAccountViewModel>();
      vm.fetchAgents();
      
      // Check for passed arguments (from Company or Agent detail screens)
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('company')) {
        vm.setFromCompany(args['company'] as CompanyModel);
      }
    });
  }

  @override
  void dispose() {
    _bvnController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _lookupEmailController.dispose();
    super.dispose();
  }

  void _submitConfirmVendor() async {
    final vm = context.read<AddBankAccountViewModel>();
    final success = await vm.confirmAccount();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.successMessage ?? 'Vendor account verified.')),
      );
    }
  }

  void _submitCreateVendor() async {
    final vm = context.read<AddBankAccountViewModel>();
    final success = await vm.createVendorAccount();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.successMessage ?? 'Vendor account created.')),
      );
    }
  }

  void _submitCreateBankProfile() async {
    if (_bankProfileFormKey.currentState!.validate()) {
      final vm = context.read<AddBankAccountViewModel>();
      final success = await vm.createBankProfile(
        bvn: _bvnController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.successMessage ?? 'Bank profile created. Please verify OTP.')),
        );
      }
    }
  }

  void _submitVerifyOtp() async {
    if (_otpFormKey.currentState!.validate()) {
      final vm = context.read<AddBankAccountViewModel>();
      final success = await vm.generateAccount(
        otp: _otpController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.successMessage ?? 'Bank account generated successfully')),
        );
        vm.reset();
        _bvnController.clear();
        _emailController.clear();
        _otpController.clear();
      }
    }
  }

  void _resendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required to resend OTP'), backgroundColor: Colors.orange),
      );
      return;
    }
    final vm = context.read<AddBankAccountViewModel>();
    final success = await vm.regenerateOtp(email: email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.successMessage ?? 'OTP sent successfully')),
      );
    }
  }

  void _lookupCustomer() async {
    if (_lookupFormKey.currentState!.validate()) {
      final vm = context.read<AddBankAccountViewModel>();
      await vm.getCustomerDetails(
        email: _lookupEmailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Bank Account'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('CREATE/GENERATE', 0),
                ),
                Expanded(
                  child: _buildTabButton('LOOKUP AGENT', 1),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<AddBankAccountViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (vm.errorMessage != null) _buildErrorMessage(vm),
                if (vm.successMessage != null && vm.errorMessage == null) _buildSuccessMessage(vm),
                
                _currentView == 0 
                    ? _buildManagementFlow(vm)
                    : _buildLookupView(vm),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _currentView == index;
    return InkWell(
      onTap: () {
        context.read<AddBankAccountViewModel>().clearMessages();
        setState(() => _currentView = index);
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF1A237E) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF1A237E) : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(AddBankAccountViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red))),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => vm.clearMessages()),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(AddBankAccountViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(vm.successMessage!, style: const TextStyle(color: Colors.green))),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => vm.clearMessages()),
        ],
      ),
    );
  }

  Widget _buildManagementFlow(AddBankAccountViewModel vm) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildStageContent(vm),
    );
  }

  Widget _buildStageContent(AddBankAccountViewModel vm) {
    switch (vm.stage) {
      case BankAccountStage.agentSelection:
        return _buildAgentSelection(vm);
      case BankAccountStage.vendorConfirmation:
        return _buildVendorCreation(vm);
      case BankAccountStage.bankProfileCreation:
        // Pre-fill if needed
        if (_bvnController.text.isEmpty) _bvnController.text = vm.selectedAgent?['bvn']?.toString() ?? '';
        if (_emailController.text.isEmpty) _emailController.text = vm.selectedAgent?['email']?.toString() ?? '';
        return _buildBankProfileCreation(vm);
      case BankAccountStage.otpVerification:
        return _buildOtpVerification(vm);
    }
  }

  Widget _buildAgentSelection(AddBankAccountViewModel vm) {
    return Column(
      key: const ValueKey('agent_selection'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Step 1: Select Agent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        const SizedBox(height: 24),
        DropdownButtonFormField<Map<String, dynamic>>(
          value: vm.selectedAgent,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Select Agent', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
          items: vm.agentsList.map((agent) {
            return DropdownMenuItem(
              value: agent,
              child: Text('${agent['first_name'] ?? ''} ${agent['last_name'] ?? ''} (${agent['email']})', style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: vm.isLoading ? null : (value) => vm.setSelectedAgent(value),
          hint: const Text('Choose an existing agent'),
        ),
        if (vm.isLoading) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ]
      ],
    );
  }

  Widget _buildVendorCreation(AddBankAccountViewModel vm) {
    return Column(
      key: const ValueKey('vendor_creation'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Step 1: Vendor Account Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        const SizedBox(height: 16),
        _buildAgentInfoCard(vm),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : _submitConfirmVendor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: vm.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('CONFIRM ACCOUNT', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : _submitCreateVendor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: vm.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: () => vm.reset(), child: const Text('Back to Agent Selection')),
      ],
    );
  }

  Widget _buildBankProfileCreation(AddBankAccountViewModel vm) {
    return Form(
      key: _bankProfileFormKey,
      child: Column(
        key: const ValueKey('bank_profile'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Step 2: Create Bank Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bvnController,
            decoration: const InputDecoration(labelText: 'BVN', border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers)),
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty ? 'BVN is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: vm.isLoading ? null : _submitCreateBankProfile,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: vm.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('CREATE BANK PROFILE'),
          ),
          TextButton(onPressed: () => vm.reset(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _buildOtpVerification(AddBankAccountViewModel vm) {
    return Form(
      key: _otpFormKey,
      child: Column(
        key: const ValueKey('otp_verification'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Step 3: Verify OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 8),
          Text('Enter the OTP sent to ${vm.lastEmail}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: 'OTP',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: TextButton(onPressed: vm.isLoading ? null : _resendOtp, child: const Text('RESEND')),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty ? 'OTP is required' : null,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: vm.isLoading ? null : _submitVerifyOtp,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: vm.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('GENERATE ACCOUNT'),
          ),
          TextButton(onPressed: () => vm.reset(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _buildAgentInfoCard(AddBankAccountViewModel vm) {
    if (vm.selectedAgent == null) return const SizedBox.shrink();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.blue.shade200)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _agentDetailItem('Name', '${vm.selectedAgent!['first_name'] ?? ''} ${vm.selectedAgent!['last_name'] ?? ''}'),
            _agentDetailItem('RC/Company No', vm.selectedAgent!['company_number'] ?? 'N/A'),
            _agentDetailItem('Email', vm.selectedAgent!['email'] ?? 'N/A'),
            _agentDetailItem('Address', vm.selectedAgent!['address'] ?? 'N/A'),
            _agentDetailItem('City', vm.selectedAgent!['city'] ?? 'N/A'),
            _agentDetailItem('State', vm.selectedAgent!['state'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _agentDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildLookupView(AddBankAccountViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: _lookupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Lookup Agent Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 24),
              TextFormField(
                controller: _lookupEmailController,
                decoration: const InputDecoration(labelText: 'Agent Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: vm.isLoading ? null : _lookupCustomer,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: vm.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SEARCH AGENT'),
              ),
            ],
          ),
        ),
        if (vm.customerDetails != null) ...[
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Agent Bank Profile Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _detailRow('Full Name', vm.customerDetails!['name'] ?? 'N/A'),
          _detailRow('Email', vm.customerDetails!['email'] ?? 'N/A'),
          _detailRow('BVN', vm.customerDetails!['bvn'] ?? 'N/A'),
          _detailRow('Account Number', vm.customerDetails!['account_number'] ?? 'Not Generated'),
          _detailRow('Bank Name', vm.customerDetails!['bank_name'] ?? 'N/A'),
          _detailRow('KYC Status', vm.customerDetails!['kyc_status'] ?? 'N/A'),
        ],
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
