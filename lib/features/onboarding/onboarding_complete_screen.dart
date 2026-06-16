import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'onboarding_complete_viewmodel.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with SingleTickerProviderStateMixin {
  bool _credentialsLoaded = false;
  late final AnimationController _controller;
  late final Animation<double> _checkmarkScale;
  late final Animation<double> _headingFade;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _checkmarkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _headingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.6, curve: Curves.easeIn),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeIn),
      ),
    );

    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.95, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A237E), Color(0xFF0D1642)],
            ),
          ),
          child: SafeArea(
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<OnboardingCompleteViewModel>(
      builder: (context, vm, _) {
        if (!_credentialsLoaded) {
          _credentialsLoaded = true;
          vm.loadCredentials();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildCheckmark(),
              const SizedBox(height: 20),
              _buildHeading(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 28),
              _buildCredentialsCard(vm),
              const SizedBox(height: 10),
              _buildWarningText(),
              const SizedBox(height: 20),
              _buildButton(vm),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckmark() {
    return AnimatedBuilder(
      animation: _checkmarkScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkmarkScale.value,
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeading() {
    return FadeTransition(
      opacity: _headingFade,
      child: const Text(
        'Setup Complete!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return FadeTransition(
      opacity: _subtitleFade,
      child: const Text(
        'Your account is ready. You can now process transactions.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Colors.white70),
      ),
    );
  }

  Widget _buildCredentialsCard(OnboardingCompleteViewModel vm) {
    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        position: _cardSlide,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(vm),
              const Divider(height: 20),
              _credentialRow(label: 'Full Name', value: vm.agentFullName),
              _credentialRow(label: 'Email', value: vm.agentEmail),
              _credentialRow(label: 'Agent Number', value: vm.agentNumber),
              _credentialRow(label: 'Company Number', value: vm.companyNumber),
              _credentialRow(
                  label: 'Terminal ID', value: vm.terminalId, isLast: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardHeader(OnboardingCompleteViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Credentials',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        GestureDetector(
          onTap: vm.copyCredentials,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: vm.isCopied
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                  : const Color(0xFF1A237E).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  vm.isCopied ? Icons.check : Icons.copy,
                  size: 16,
                  color: vm.isCopied
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF1A237E),
                ),
                const SizedBox(width: 4),
                Text(
                  vm.isCopied ? 'Copied!' : 'Copy All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: vm.isCopied
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _credentialRow({
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }

  Widget _buildWarningText() {
    return FadeTransition(
      opacity: _buttonFade,
      child: const Text(
        '⚠️ Save these credentials. You will need them to log in.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.amberAccent),
      ),
    );
  }

  Widget _buildButton(OnboardingCompleteViewModel vm) {
    return FadeTransition(
      opacity: _buttonFade,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => vm.proceedToDashboard(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Text(
              'Proceed to Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
