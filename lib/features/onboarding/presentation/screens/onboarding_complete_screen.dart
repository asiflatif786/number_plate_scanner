import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  final String companyNumber;
  final String agentNumber;
  final String terminalId;

  const OnboardingCompleteScreen({
    super.key,
    required this.companyNumber,
    required this.agentNumber,
    required this.terminalId,
  });

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with SingleTickerProviderStateMixin {
  static const String _tag = 'OnboardingCompleteScreen';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
    AppLogger.success(_tag, 'Onboarding complete screen shown');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveHelper.iconSize(context, 100);
    final titleSize = ResponsiveHelper.fontSize(context, 28);
    final subtitleSize = ResponsiveHelper.fontSize(context, 16);

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
              colors: [Color(0xFF1A237E), Color(0xFF0288D1)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.horizontalPadding(context)),
                    child: Column(
                      children: [
                        SizedBox(
                            height: ResponsiveHelper.spacingBetweenSections(
                                context) *
                            2),
                        _buildAnimatedCheckmark(iconSize),
                        SizedBox(
                            height: ResponsiveHelper.spacingBetweenSections(
                                context)),
                        Text(
                          'Onboarding Complete!',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your account is ready to process transactions',
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height: ResponsiveHelper.spacingBetweenSections(
                                context) *
                            1.5),
                        _buildSummaryCard(),
                        const SizedBox(height: 16),
                        const Text(
                          'Please save these credentials securely. You will need them for transaction processing.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height: ResponsiveHelper.spacingBetweenSections(
                                context) *
                            1.5),
                        _buildStartButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCheckmark(double iconSize) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          color: const Color(0xFF2E7D32),
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 56,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Credentials',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const Divider(height: 24),
          _buildCredentialRow(
            icon: Icons.business,
            label: 'Company No.',
            value: widget.companyNumber,
          ),
          const SizedBox(height: 12),
          _buildCredentialRow(
            icon: Icons.person,
            label: 'Agent No.',
            value: widget.agentNumber,
          ),
          const SizedBox(height: 12),
          _buildCredentialRow(
            icon: Icons.point_of_sale,
            label: 'Terminal ID',
            value: widget.terminalId,
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A237E)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => ClipboardHelper.copyToClipboard(
            context,
            value,
            label,
          ),
          child: const Icon(
            Icons.copy,
            size: 18,
            color: Color(0xFF0288D1),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          AppLogger.info(_tag, 'Navigating to vehicle search');
          Navigator.pushReplacementNamed(context, '/vehicle-search');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A237E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
        child: const Text(
          'Start Processing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
