import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'corporate_registration_viewmodel.dart';

class CorporateRegistrationScreen extends StatefulWidget {
  const CorporateRegistrationScreen({super.key});

  @override
  State<CorporateRegistrationScreen> createState() =>
      _CorporateRegistrationScreenState();
}

class _CorporateRegistrationScreenState
    extends State<CorporateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  final _rcFocus = FocusNode();
  final _tinFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _contactAddressFocus = FocusNode();
  final _cityFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CorporateRegistrationViewModel>().loadStates();
    });
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _rcFocus.dispose();
    _tinFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _contactAddressFocus.dispose();
    _cityFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<CorporateRegistrationViewModel>(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildCompanyInfoCard(vm),
                            const SizedBox(height: 16),
                            _buildAddressCard(vm),
                            const SizedBox(height: 16),
                            _buildLocationCard(vm),
                            const SizedBox(height: 16),
                            _buildDocumentsCard(),
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

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _stepDot(label: 'Company', isActive: true),
              _stepConnector(),
              _stepDot(label: 'Agent', isActive: false),
              _stepConnector(),
              _stepDot(label: 'Terminal', isActive: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepDot({required String label, required bool isActive}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1A237E)
                  : const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isActive ? '1' : '',
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
              color: isActive ? const Color(0xFF1A237E) : const Color(0xFF9E9E9E),
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

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Corporate Registration',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Register your company to get started',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
      ],
    );
  }

  Widget _buildCompanyInfoCard(CorporateRegistrationViewModel vm) {
    return _sectionCard(
      title: 'Company Information',
      child: Column(
        children: [
          _requiredField(
            label: 'Company Name',
            controller: vm.nameController,
            focusNode: _nameFocus,
            nextFocus: _rcFocus,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _requiredField(
            label: 'CAC Registration Number',
            controller: vm.rcNumberController,
            focusNode: _rcFocus,
            nextFocus: _tinFocus,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _requiredField(
            label: 'Tax Identification Number',
            controller: vm.tinController,
            focusNode: _tinFocus,
            nextFocus: _emailFocus,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _requiredField(
            label: 'Email Address',
            controller: vm.emailController,
            focusNode: _emailFocus,
            nextFocus: _phoneFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _requiredField(
            label: 'Phone Number',
            controller: vm.phoneController,
            focusNode: _phoneFocus,
            nextFocus: _addressFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 11,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(CorporateRegistrationViewModel vm) {
    return _sectionCard(
      title: 'Address Information',
      child: Column(
        children: [
          _requiredField(
            label: 'Registered Address',
            controller: vm.addressController,
            focusNode: _addressFocus,
            nextFocus: _contactAddressFocus,
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _requiredField(
            label: 'Contact Address',
            controller: vm.contactAddressController,
            focusNode: _contactAddressFocus,
            nextFocus: _cityFocus,
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _requiredField(
            label: 'City',
            controller: vm.cityController,
            focusNode: _cityFocus,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(CorporateRegistrationViewModel vm) {
    return _sectionCard(
      title: 'Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stateDropdown(vm),
          const SizedBox(height: 14),
          _lgaDropdown(vm),
        ],
      ),
    );
  }

  Widget _stateDropdown(CorporateRegistrationViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledText('State *'),
        const SizedBox(height: 6),
        if (vm.isLoadingStates)
          _shimmer()
        else
          DropdownButtonFormField<String>(
            value: vm.selectedState,
            decoration: _dropdownDeco(),
            hint: const Text('Select State'),
            isExpanded: true,
            items: vm.states.map((s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
            onChanged: vm.onStateChanged,
            validator: (_) =>
                vm.selectedState == null ? 'Please select a state' : null,
          ),
      ],
    );
  }

  Widget _lgaDropdown(CorporateRegistrationViewModel vm) {
    final disabled = vm.selectedState == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledText('LGA *'),
        const SizedBox(height: 6),
        if (vm.isLoadingLgas)
          _shimmer()
        else
          DropdownButtonFormField<String>(
            value: vm.selectedLga,
            decoration: _dropdownDeco(),
            hint: Text(
              disabled ? 'Select State first' : 'Select LGA',
              style: TextStyle(
                color: disabled ? const Color(0xFFBDBDBD) : const Color(0xFF9E9E9E),
              ),
            ),
            isExpanded: true,
            disabledHint: const Text('Select State first'),
            items: vm.lgas.map((l) {
              return DropdownMenuItem(value: l, child: Text(l));
            }).toList(),
            onChanged: disabled ? null : (v) => vm.setSelectedLga(v),
            validator: (_) =>
                vm.selectedLga == null ? 'Please select an LGA' : null,
          ),
      ],
    );
  }

  Widget _buildDocumentsCard() {
    final docs = [
      'CAC Certificate',
      'CAC Form 7',
      'MEMAT Certificate',
      'Proof of Address',
    ];
    return _sectionCard(
      title: 'Required Documents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...docs.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 18, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 8),
                    Text(d, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          const Text(
            'Documents will be uploaded in the next step',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9E9E9E),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(CorporateRegistrationViewModel vm) {
    if (vm.errorMessage == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFC62828).withValues(alpha: 0.3),
        ),
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

  Widget _buildSubmitButton(CorporateRegistrationViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: vm.isLoading || vm.isLoadingStates
            ? null
            : () => vm.submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: vm.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Continue to Agent Registration',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return const Center(
      child: Text(
        'Step 1 of 3',
        style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Shared Helpers
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

  Widget _requiredField({
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledText('$label *'),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction ?? TextInputAction.next,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: _textFieldDeco(),
          onFieldSubmitted: nextFocus != null
              ? (_) => FocusScope.of(context).requestFocus(nextFocus)
              : null,
        ),
      ],
    );
  }

  Widget _labeledText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  InputDecoration _textFieldDeco() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
      counterText: '',
    );
  }

  InputDecoration _dropdownDeco() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
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
}
