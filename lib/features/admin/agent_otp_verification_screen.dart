import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/agent_model.dart';
import 'add_bank_account_viewmodel.dart';
import '../../app/routes.dart';

class AgentOtpVerificationScreen extends StatefulWidget {
  final AgentModel agent;
  const AgentOtpVerificationScreen({super.key, required this.agent});

  @override
  State<AgentOtpVerificationScreen> createState() => _AgentOtpVerificationScreenState();
}

class _AgentOtpVerificationScreenState extends State<AgentOtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.agent.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleGenerateAccount() async {
    if (_formKey.currentState!.validate()) {
      final vm = context.read<AddBankAccountViewModel>();
      
      final success = await vm.generateAccount(
        otp: _otpController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.successMessage ?? 'Bank account generated successfully')),
        );
        // Navigate back to detail
        Navigator.popUntil(context, (route) => route.settings.name == AppRoutes.agentDetail);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
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
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const Text(
                  'Verify Your Identity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the 6-digit code sent to your email to complete the bank account generation.',
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
                  readOnly: true,
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter OTP';
                    if (value.length < 6) return 'Enter full 6-digit code';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.agentRegenerateOtp, arguments: widget.agent);
                    },
                    child: const Text('regenerate otp'),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _handleGenerateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('generate account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
