import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_bank_account_viewmodel.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();
  final _lookupFormKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _lookupEmailController = TextEditingController();

  int _currentView = 0; // 0: Profile/Generate, 1: Lookup

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddBankAccountViewModel>().fetchAgents();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _lookupEmailController.dispose();
    super.dispose();
  }

  void _submitProfile() async {
    final vm = context.read<AddBankAccountViewModel>();
    
    if (vm.selectedAgent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an agent from the list')),
      );
      return;
    }

    final bvn = vm.selectedAgent!['bvn']?.toString() ?? '';
    final email = vm.selectedAgent!['email']?.toString() ?? '';

    if (bvn.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected agent is missing BVN or Email information')),
      );
      return;
    }

    final success = await vm.createCustomerProfile(
      bvn: bvn,
      email: email,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.successMessage ?? 'Profile created. Now generate account.')),
      );
      // Auto-fill the confirm email for the next step
      _emailController.text = email;
    }
  }

  void _submitGenerateAccount() async {
    if (_accountFormKey.currentState!.validate()) {
      final vm = context.read<AddBankAccountViewModel>();
      final success = await vm.generateAccount(
        otp: _otpController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.successMessage ?? 'Account generated successfully')),
        );
        vm.reset();
        _emailController.clear();
        _otpController.clear();
      }
    }
  }

  void _resendOtp() async {
    if (_emailController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required to resend OTP'), backgroundColor: Colors.orange),
      );
      return;
    }
    final vm = context.read<AddBankAccountViewModel>();
    final success = await vm.regenerateOtp(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.successMessage ?? 'OTP resent successfully')),
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
        title: const Text('Bank Account Management'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read<AddBankAccountViewModel>().clearMessages();
                      setState(() => _currentView = 0);
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentView == 0 ? const Color(0xFF1A237E) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'CREATE/GENERATE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentView == 0 ? const Color(0xFF1A237E) : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read<AddBankAccountViewModel>().clearMessages();
                      setState(() => _currentView = 1);
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentView == 1 ? const Color(0xFF1A237E) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'LOOKUP CUSTOMER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentView == 1 ? const Color(0xFF1A237E) : Colors.grey,
                        ),
                      ),
                    ),
                  ),
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
                if (vm.errorMessage != null)
                  Container(
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
                        Expanded(
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.red),
                          onPressed: () => vm.clearMessages(),
                        )
                      ],
                    ),
                  ),
                _currentView == 0 
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: !vm.profileCreated 
                            ? _buildProfileForm(vm) 
                            : _buildGenerateAccountForm(vm),
                      )
                    : _buildLookupView(vm),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileForm(AddBankAccountViewModel vm) {
    return Form(
      key: _profileFormKey,
      child: Column(
        key: const ValueKey('profile_form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step 1: Create Customer Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select an existing agent to create a bank profile.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Agent Selection Dropdown
          DropdownButtonFormField<Map<String, dynamic>>(
            value: vm.selectedAgent,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Agent',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            items: vm.agentsList.map((agent) {
              final firstName = agent['first_name'] ?? '';
              final lastName = agent['last_name'] ?? '';
              final email = agent['email'] ?? '';
              final bvn = agent['bvn'] ?? 'No BVN';
              return DropdownMenuItem(
                value: agent,
                child: Text(
                  '$firstName $lastName ($email)',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: vm.isLoading ? null : (value) {
              vm.setSelectedAgent(value);
            },
            hint: vm.isLoading && vm.agentsList.isEmpty 
                ? const Text('Loading agents...') 
                : const Text('Choose an existing agent'),
            validator: (value) => value == null ? 'Please select an agent' : null,
          ),
          
          if (vm.selectedAgent != null) ...[
            const SizedBox(height: 20),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selected Agent Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('BVN: ${vm.selectedAgent!['bvn'] ?? 'N/A'}'),
                    Text('Email: ${vm.selectedAgent!['email'] ?? 'N/A'}'),
                    Text('Phone: ${vm.selectedAgent!['phone_number'] ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : _submitProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('CREATE PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateAccountForm(AddBankAccountViewModel vm) {
    return Form(
      key: _accountFormKey,
      child: Column(
        key: const ValueKey('account_form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step 2: Generate Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Profile created successfully. Enter the OTP sent to the agent.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter OTP received',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: TextButton(
                onPressed: vm.isLoading ? null : _resendOtp,
                child: const Text('RESEND'),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty ? 'OTP is required' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Confirm Email',
              hintText: 'Confirm customer email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : _submitGenerateAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('GENERATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => vm.reset(),
            child: const Text('Back to Agent Selection'),
          ),
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
              const Text(
                'Lookup Customer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _lookupEmailController,
                decoration: const InputDecoration(
                  labelText: 'Customer Email',
                  hintText: 'Enter email to search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: vm.isLoading ? null : _lookupCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                  child: vm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SEARCH CUSTOMER'),
                ),
              ),
            ],
          ),
        ),
        if (vm.customerDetails != null) ...[
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Customer Profile Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
