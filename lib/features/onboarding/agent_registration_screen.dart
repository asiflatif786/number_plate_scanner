import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import 'agent_registration_viewmodel.dart';

class AgentRegistrationScreen extends StatefulWidget {
  const AgentRegistrationScreen({super.key});

  @override
  State<AgentRegistrationScreen> createState() =>
      _AgentRegistrationScreenState();
}

class _AgentRegistrationScreenState extends State<AgentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentRegistrationViewModel>().loadStates();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final companyNumber = args?['company_number'] as String?;
    final companyName = args?['company_name'] as String?;
    final companyVerified = companyNumber != null && companyNumber.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: companyVerified
          ? AppBar(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              title: const Text('Add Agent'),
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<AgentRegistrationViewModel>(
            builder: (context, vm, _) {
              return Column(
                children: [
                  _buildProgressBar(companyVerified),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildHeader(companyVerified),
                            if (companyVerified) ...[
                              const SizedBox(height: 16),
                              _buildVerifiedCompanyCard(companyNumber!, companyName),
                            ],
                            const SizedBox(height: 20),
                            _buildPersonalInfoCard(vm),
                            const SizedBox(height: 16),
                            _buildAddressCard(vm),
                            const SizedBox(height: 16),
                            _buildIdentityCard(vm),
                            const SizedBox(height: 16),
                            _buildBankingCard(vm),
                            const SizedBox(height: 16),
                            _buildDocumentsCard(vm),
                            const SizedBox(height: 12),
                            _buildErrorBanner(vm),
                            const SizedBox(height: 16),
                            _buildSubmitButton(vm),
                            const SizedBox(height: 8),
                            _buildStepIndicator(),
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

  Widget _buildProgressBar(bool companyVerified) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      color: Colors.white,
      child: Row(
        children: [
          _stepDot(
            label: 'Company',
            isComplete: companyVerified,
            isActive: false,
          ),
          _stepConnector(),
          _stepDot(label: 'Agent', isComplete: false, isActive: true),
          _stepConnector(),
          _stepDot(label: 'Terminal', isComplete: false, isActive: false),
        ],
      ),
    );
  }

  Widget _stepDot({
    required String label,
    required bool isComplete,
    required bool isActive,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isComplete
                  ? const Color(0xFF2E7D32)
                  : isActive
                      ? const Color(0xFF1A237E)
                      : const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isComplete
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      isActive ? '2' : '',
                      style: const TextStyle(
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
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive || isComplete
                  ? const Color(0xFF1A237E)
                  : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepConnector() {
    return Container(
      height: 2,
      width: 32,
      color: const Color(0xFFE0E0E0),
    );
  }

  // ──────────────────────────────────────────────
  // Header
  // ──────────────────────────────────────────────

  Widget _buildHeader(bool companyVerified) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          companyVerified ? 'Agent Registration' : 'Corporate Registration',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          companyVerified
              ? 'Personal and banking details'
              : 'Register your company to get started',
          style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
      ],
    );
  }

  Widget _buildVerifiedCompanyCard(String companyNumber, String? companyName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Company Verified',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  companyName ?? companyNumber,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Personal Information Card
  // ──────────────────────────────────────────────

  Widget _buildPersonalInfoCard(AgentRegistrationViewModel vm) {
    return _sectionCard(
      title: 'Personal Information',
      child: Column(
        children: [
          _dropdownField(
            label: 'Title *',
            value: vm.selectedTitle,
            items: AppConstants.agentTitles,
            onChanged: (v) => vm.setSelectedTitle(v),
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'First Name *',
            controller: vm.firstNameController,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'Middle Name (Optional)',
            controller: vm.middleNameController,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'Last Name *',
            controller: vm.lastNameController,
          ),
          const SizedBox(height: 14),
          _dropdownField(
            label: 'Gender *',
            value: vm.selectedGender,
            items: AppConstants.genderOptions,
            displayBuilder: (v) =>
                v.substring(0, 1).toUpperCase() + v.substring(1),
            onChanged: (v) => vm.setSelectedGender(v),
          ),
          const SizedBox(height: 14),
          _dropdownField(
            label: 'Marital Status *',
            value: vm.selectedMaritalStatus,
            items: AppConstants.maritalStatusOptions,
            displayBuilder: (v) =>
                v.substring(0, 1).toUpperCase() + v.substring(1),
            onChanged: (v) => vm.setSelectedMaritalStatus(v),
          ),
          const SizedBox(height: 14),
          _datePickerField(vm),
          const SizedBox(height: 14),
          _textField(
            label: 'Nationality',
            controller: vm.nationalityController,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'Phone Number *',
            controller: vm.phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 11,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'Email Address *',
            controller: vm.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _passwordField(
            label: 'Password *',
            controller: vm.passwordController,
            isVisible: vm.isPasswordVisible,
            onToggle: vm.togglePasswordVisibility,
          ),
          const SizedBox(height: 14),
          _passwordField(
            label: 'Confirm Password *',
            controller: vm.confirmPasswordController,
            isVisible: vm.isConfirmPasswordVisible,
            onToggle: vm.toggleConfirmPasswordVisibility,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Address Information Card
  // ──────────────────────────────────────────────

  Widget _buildAddressCard(AgentRegistrationViewModel vm) {
    return _sectionCard(
      title: 'Address Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            label: 'Residential Address *',
            controller: vm.addressController,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'City *',
            controller: vm.cityController,
          ),
          const SizedBox(height: 14),
          _stateDropdown(
            label: 'Residential State *',
            value: vm.selectedState,
            states: vm.states,
            loading: vm.isLoadingStates,
            onChanged: vm.onResidentialStateChanged,
          ),
          const SizedBox(height: 14),
          _lgaDropdown(
            label: 'Residential LGA *',
            value: vm.selectedLga,
            lgas: vm.lgas,
            loading: vm.isLoadingLgas,
            stateSelected: vm.selectedState != null,
            onChanged: (v) => vm.setSelectedLga(v),
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 6),
          _stateDropdown(
            label: 'State of Origin *',
            value: vm.selectedStateOfOrigin,
            states: vm.states,
            loading: vm.isLoadingStates,
            onChanged: vm.onOriginStateChanged,
          ),
          const SizedBox(height: 14),
          _lgaDropdown(
            label: 'LGA of Origin *',
            value: vm.selectedLgaOfOrigin,
            lgas: vm.lgasOfOrigin,
            loading: vm.isLoadingLgasOfOrigin,
            stateSelected: vm.selectedStateOfOrigin != null,
            onChanged: (v) => vm.setSelectedLgaOfOrigin(v),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Identity & Verification Card
  // ──────────────────────────────────────────────

  Widget _buildIdentityCard(AgentRegistrationViewModel vm) {
    return _sectionCard(
      title: 'Identity & Verification',
      child: Column(
        children: [
          _textField(
            label: 'BVN *',
            controller: vm.bvnController,
            keyboardType: TextInputType.number,
            maxLength: 11,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'NIN *',
            controller: vm.ninController,
            keyboardType: TextInputType.number,
            maxLength: 11,
          ),
          const SizedBox(height: 14),
          _dropdownField(
            label: 'ID Type *',
            value: vm.selectedIdType,
            items: AppConstants.idTypes,
            onChanged: (v) => vm.setSelectedIdType(v),
          ),
          const SizedBox(height: 14),
          _textField(
            label: _idNumberLabel(vm.selectedIdType),
            controller: vm.identityNumberController,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'Tax Identification Number (Optional)',
            controller: vm.tinController,
          ),
        ],
      ),
    );
  }

  String _idNumberLabel(String? idType) {
    if (idType == null) return 'Identity Number *';
    return '$idType Number *';
  }

  // ──────────────────────────────────────────────
  // Banking Details Card
  // ──────────────────────────────────────────────

  Widget _buildBankingCard(AgentRegistrationViewModel vm) {
    return _sectionCard(
      title: 'Banking Details',
      child: Column(
        children: [
          _textField(
            label: 'Bank Name *',
            controller: vm.bankNameController,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'Account Number *',
            controller: vm.accountNumberController,
            keyboardType: TextInputType.number,
            maxLength: 10,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'Account Name *',
            controller: vm.accountNameController,
          ),
          const SizedBox(height: 14),
          _textField(
            label: 'Sort Code (Optional)',
            controller: vm.sortCodeController,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Document Uploads Card
  // ──────────────────────────────────────────────

  Widget _buildDocumentsCard(AgentRegistrationViewModel vm) {
    return _sectionCard(
      title: 'Document Uploads',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _uploadRow(
            label: 'Utility Bill *',
            fileName: vm.utilityBillFileName,
            isUploaded: vm.utilityBillBase64 != null,
            onTap: () => _showDocumentPicker(vm, 'utility_bill'),
          ),
          const SizedBox(height: 12),
          _uploadRow(
            label: 'Identity Document *',
            fileName: vm.identityDocumentFileName,
            isUploaded: vm.identityDocumentBase64 != null,
            onTap: () => _showDocumentPicker(vm, 'identity_document'),
          ),
          const SizedBox(height: 12),
          _uploadRow(
            label: 'Passport Photo *',
            fileName: vm.passportPhotoFileName,
            isUploaded: vm.passportPhotoBase64 != null,
            onTap: () => _showDocumentPicker(vm, 'passport_photo'),
          ),
        ],
      ),
    );
  }

  Widget _uploadRow({
    required String label,
    required String? fileName,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!isUploaded)
                    const Text('* ',
                        style: TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              if (fileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    fileName,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.cloud_upload_outlined, size: 18),
          label: const Text('Upload'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1A237E),
            side: const BorderSide(color: Color(0xFF1A237E)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showDocumentPicker(AgentRegistrationViewModel vm, String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Source',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1A237E)),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  vm.pickDocumentFromSource(type, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1A237E)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  vm.pickDocumentFromSource(type, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Error Banner
  // ──────────────────────────────────────────────

  Widget _buildErrorBanner(AgentRegistrationViewModel vm) {
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

  Widget _buildSubmitButton(AgentRegistrationViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed:
            vm.isLoading ? null : () => vm.submit(context),
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
                'Continue to Terminal Setup',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return const Center(
      child: Text(
        'Step 2 of 3',
        style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Shared Form Helpers
  // ──────────────────────────────────────────────

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: _inputDeco(),
        ),
      ],
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: _inputDeco().copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9E9E9E),
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? displayBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _inputDeco(),
          isExpanded: true,
          hint: const Text('Select'),
          items: items.map((v) {
            final display = displayBuilder != null ? displayBuilder(v) : v;
            return DropdownMenuItem(value: v, child: Text(display));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _stateDropdown({
    required String label,
    required String? value,
    required List<String> states,
    required bool loading,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        loading
            ? _shimmer()
            : DropdownButtonFormField<String>(
                value: value,
                decoration: _inputDeco(),
                isExpanded: true,
                hint: const Text('Select State'),
                items: states
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: onChanged,
              ),
      ],
    );
  }

  Widget _lgaDropdown({
    required String label,
    required String? value,
    required List<String> lgas,
    required bool loading,
    required bool stateSelected,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        loading
            ? _shimmer()
            : DropdownButtonFormField<String>(
                value: value,
                decoration: _inputDeco(),
                isExpanded: true,
                hint: Text(
                  stateSelected ? 'Select LGA' : 'Select State first',
                  style: TextStyle(
                    color: stateSelected
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFFBDBDBD),
                  ),
                ),
                disabledHint: const Text('Select State first'),
                items: lgas
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: stateSelected ? onChanged : null,
              ),
      ],
    );
  }

  Widget _datePickerField(AgentRegistrationViewModel vm) {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 18, now.month, now.day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date of Birth *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          controller: vm.dateOfBirthController,
          readOnly: true,
          decoration: _inputDeco().copyWith(
            suffixIcon: const Icon(Icons.calendar_today,
                size: 18, color: Color(0xFF1A237E)),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: maxDate,
              firstDate: DateTime(1940),
              lastDate: maxDate,
            );
            if (picked != null) {
              vm.dateOfBirthController.text =
                  DateFormat('yyyy-MM-dd').format(picked);
            }
          },
        ),
      ],
    );
  }

  Widget _shimmer() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
      counterText: '',
    );
  }
}
