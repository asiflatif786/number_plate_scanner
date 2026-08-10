import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/agent_model.dart';
import 'add_bank_account_viewmodel.dart';

class AgentRegenerateOtpScreen extends StatefulWidget {
  final AgentModel agent;
  const AgentRegenerateOtpScreen({super.key, required this.agent});

  @override
  State<AgentRegenerateOtpScreen> createState() => _AgentRegenerateOtpScreenState();
}

class _AgentRegenerateOtpScreenState extends State<AgentRegenerateOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.agent.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleRegenerateOtp() async {
    if (_formKey.currentState!.validate()) {
      final vm = context.read<AddBankAccountViewModel>();
      final success = await vm.regenerateOtp(email: _emailController.text.trim());

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.successMessage ?? 'OTP regenerated successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regenerate OTP'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AddBankAccountViewModel>(
        builder: (context, vm, _) => Padding(
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
                  'Regenerate OTP',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the agent email to receive a new OTP code.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Agent Email',
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
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _handleRegenerateOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('regenerate otp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
