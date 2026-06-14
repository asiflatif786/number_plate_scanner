import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/onboarding_progress_indicator.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/terminal_entity.dart';
import '../viewmodels/terminal_viewmodel.dart';

class TerminalProfileScreen extends StatefulWidget {
  final String companyNumber;
  final String agentNumber;

  const TerminalProfileScreen({
    super.key,
    required this.companyNumber,
    required this.agentNumber,
  });

  @override
  State<TerminalProfileScreen> createState() => _TerminalProfileScreenState();
}

class _TerminalProfileScreenState extends State<TerminalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();
  final _terminalIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _terminalIdController.addListener(_uppercaseListener);
  }

  void _uppercaseListener() {
    final text = _terminalIdController.text;
    final uppercase = text.toUpperCase();
    if (uppercase != text) {
      _terminalIdController.value = TextEditingValue(
        text: uppercase,
        selection: TextSelection.collapsed(offset: uppercase.length),
      );
    }
  }

  @override
  void dispose() {
    _terminalIdController.removeListener(_uppercaseListener);
    _serialNumberController.dispose();
    _terminalIdController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final viewmodel = context.read<TerminalViewModel>();
    final entity = TerminalEntity(
      serialNumber: _serialNumberController.text.trim(),
      terminalId: _terminalIdController.text.trim().toUpperCase(),
      agentNumber: widget.agentNumber,
    );

    viewmodel.createTerminalProfile(entity);
  }

  void _onSuccess(BuildContext context, TerminalViewModel viewmodel) {
    if (!viewmodel.isSubmitted || viewmodel.savedTerminalId == null) return;

    final terminalId = viewmodel.savedTerminalId!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomDialog.showSuccess(
        context,
        title: 'Terminal Profiled!',
        message:
            'Terminal ID: $terminalId has been successfully registered.\n\n'
            'Onboarding is now complete! You can proceed to process transactions.',
        onClose: () {
          Navigator.pushReplacementNamed(
            context,
            '/onboarding-complete',
            arguments: {
              'companyNumber': widget.companyNumber,
              'agentNumber': widget.agentNumber,
              'terminalId': terminalId,
            },
          );
        },
      );
    });
  }

  void _onError(BuildContext context, TerminalViewModel viewmodel) {
    if (viewmodel.errorMessage == null) return;

    final errorMsg = viewmodel.errorMessage!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomDialog.showError(
        context,
        title: 'Profiling Failed',
        message: errorMsg,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TerminalViewModel>(
      builder: (context, viewmodel, _) {
        _onSuccess(context, viewmodel);
        _onError(context, viewmodel);

         return Scaffold(
           appBar: AppBar(
             title: const Text('Profile Terminal'),
             backgroundColor: const Color(0xFF1A237E),
             foregroundColor: Colors.white,
             elevation: 0,
             toolbarHeight: ResponsiveHelper.isTablet(context) ? 64 : kToolbarHeight,
           ),
           body: LoadingOverlay(
             isLoading: viewmodel.isLoading,
             message: 'Profiling terminal...',
             child: SingleChildScrollView(
               padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
               child: ResponsiveHelper.isTablet(context)
                   ? Center(
                       child: ConstrainedBox(
                         constraints: const BoxConstraints(maxWidth: 680),
                         child: Column(
                           children: [
                             const OnboardingProgressIndicator(
                               currentStep: 3,
                               stepLabels: ['Company', 'Agent', 'Terminal'],
                             ),
                             SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                             _buildInfoBanner(),
                             SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                             _buildTerminalSection(context),
                           ],
                         ),
                       ),
                     )
                   : Column(
                       children: [
                         const OnboardingProgressIndicator(
                           currentStep: 3,
                           stepLabels: ['Company', 'Agent', 'Terminal'],
                         ),
                         const SizedBox(height: 20),
                         _buildInfoBanner(),
                         const SizedBox(height: 20),
                         _buildTerminalSection(context),
                       ],
                     ),
             ),
           ),
         );
      },
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Color(0xFF0288D1), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Company: ${widget.companyNumber}',
                  style: const TextStyle(
                    color: Color(0xFF0288D1),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF0288D1), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Agent: ${widget.agentNumber}',
                  style: const TextStyle(
                    color: Color(0xFF0288D1),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalSection(BuildContext context) {
    final viewmodel = context.watch<TerminalViewModel>();
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Terminal Information',
              subtitle: 'Enter the details printed on your POS device',
              fontSize: 16,
            ),
            const SizedBox(height: 20),
            _buildSerialNumberField(),
            const SizedBox(height: 16),
            _buildTerminalIdField(),
            const SizedBox(height: 20),
            _buildInfoBox(),
            const SizedBox(height: 24),
            _buildSubmitButton(viewmodel),
          ],
        ),
      ),
    );
  }

  Widget _buildSerialNumberField() {
    return TextFormField(
      controller: _serialNumberController,
      validator: (v) {
        if (v == null || v.trim().length < 5) {
          return 'Serial number must be at least 5 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Serial Number',
        hintText: 'e.g. 920082592',
        suffixIcon: const Icon(Icons.qr_code_scanner, color: Color(0xFF1A237E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildTerminalIdField() {
    return TextFormField(
      controller: _terminalIdController,
      validator: (v) {
        if (v == null || v.trim().length < 4) {
          return 'Terminal ID must be at least 4 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Terminal ID',
        hintText: 'e.g. TX3456QW',
        suffixIcon:
            const Icon(Icons.point_of_sale, color: Color(0xFF1A237E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Make sure the Serial Number and Terminal ID match exactly '
              'what is printed on your POS device. These cannot be changed '
              'after profiling.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(TerminalViewModel viewmodel) {
    return AppButton(
      label: 'Profile Terminal',
      onPressed: viewmodel.isLoading ? null : _onSubmit,
      isLoading: viewmodel.isLoading,
      height: AppConstants.defaultButtonHeight,
      fontSize: 16,
    );
  }
}
