import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'terminal_profiling_viewmodel.dart';

class TerminalProfilingScreen extends StatefulWidget {
  const TerminalProfilingScreen({super.key});

  @override
  State<TerminalProfilingScreen> createState() =>
      _TerminalProfilingScreenState();
}

class _TerminalProfilingScreenState extends State<TerminalProfilingScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<TerminalProfilingViewModel>(
            builder: (context, vm, _) {
              return Column(
                children: [
                  _buildProgressBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildHeader(),
                            const SizedBox(height: 16),
                            _buildInfoBanner(),
                            const SizedBox(height: 20),
                            _buildFormCard(vm),
                            const SizedBox(height: 12),
                            _buildErrorBanner(vm),
                            const SizedBox(height: 16),
                            _buildSubmitButton(vm),
                            const SizedBox(height: 12),
                            _buildFooter(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Progress Bar
  // ──────────────────────────────────────────────

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      color: Colors.white,
      child: Row(
        children: [
          _stepDot(label: 'Company', isComplete: true),
          _stepConnector(isComplete: true),
          _stepDot(label: 'Agent', isComplete: true),
          _stepConnector(isComplete: true),
          _stepDot(label: 'Terminal', isComplete: false),
        ],
      ),
    );
  }

  Widget _stepDot({required String label, required bool isComplete}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isComplete
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF1A237E),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isComplete
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : const Text(
                      '3',
                      style: TextStyle(
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
              fontWeight: isComplete ? FontWeight.w600 : FontWeight.w600,
              color: const Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepConnector({required bool isComplete}) {
    return Container(
      height: 2,
      width: 32,
      color: isComplete
          ? const Color(0xFF2E7D32)
          : const Color(0xFF1A237E),
    );
  }

  // ──────────────────────────────────────────────
  // Header
  // ──────────────────────────────────────────────

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terminal Profiling',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Link your POS device to complete setup',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Info Banner
  // ──────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 20, color: Color(0xFF1565C0)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enter the serial number and terminal ID exactly as printed on your POS terminal device label',
              style: TextStyle(fontSize: 13, color: Color(0xFF1565C0)),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Form Card
  // ──────────────────────────────────────────────

  Widget _buildFormCard(TerminalProfilingViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          _textField(
            label: 'Device Serial Number',
            hint: 'e.g. 920082592',
            controller: vm.serialNumberController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          _textField(
            label: 'Terminal ID',
            hint: 'e.g. TX3456QW',
            controller: vm.terminalIdController,
            textInputAction: TextInputAction.done,
            onSubmitted: () => vm.submit(context),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textInputAction: textInputAction,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          onFieldSubmitted: onSubmitted != null
              ? (_) => onSubmitted()
              : null,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Error Banner
  // ──────────────────────────────────────────────

  Widget _buildErrorBanner(TerminalProfilingViewModel vm) {
    if (vm.errorMessage == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFFC62828).withValues(alpha: 0.3)),
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

  // ──────────────────────────────────────────────
  // Submit Button
  // ──────────────────────────────────────────────

  Widget _buildSubmitButton(TerminalProfilingViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: vm.isLoading ? null : () => vm.submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF1A237E).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: vm.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Complete Setup',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Footer
  // ──────────────────────────────────────────────

  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          'Step 3 of 3 — Final Step',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'These details are printed on your physical terminal device',
          style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}
