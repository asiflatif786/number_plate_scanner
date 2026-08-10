import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/agent_model.dart';
import 'add_bank_account_viewmodel.dart';
import '../../app/routes.dart';

class AgentBankVerificationScreen extends StatefulWidget {
  final AgentModel agent;
  const AgentBankVerificationScreen({super.key, required this.agent});

  @override
  State<AgentBankVerificationScreen> createState() => _AgentBankVerificationScreenState();
}

class _AgentBankVerificationScreenState extends State<AgentBankVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bvnController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _bvnController = TextEditingController(text: widget.agent.bvn);
    _emailController = TextEditingController(text: widget.agent.email);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddBankAccountViewModel>().clearMessages();
    });
  }

  @override
  void dispose() {
    _bvnController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleCreateAgentBank() async {
    if (_formKey.currentState!.validate()) {
      final vm = context.read<AddBankAccountViewModel>();
      
      final success = await vm.createBankProfile(
        bvn: _bvnController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.successMessage ?? 'Agent bank profile created. OTP sent.')),
        );
        Navigator.pushNamed(context, AppRoutes.agentOtpVerification, arguments: widget.agent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Verification'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AddBankAccountViewModel>(
        builder: (context, vm, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vm.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'Verify Agent Payment Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please provide the BVN and Email associated with the agent to proceed with bank account generation.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _bvnController,
                  decoration: const InputDecoration(
                    labelText: 'BVN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    helperText: 'Enter 11-digit Bank Verification Number',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'BVN is required';
                    if (value.length != 11) return 'BVN must be 11 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _handleCreateAgentBank,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Agent Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
