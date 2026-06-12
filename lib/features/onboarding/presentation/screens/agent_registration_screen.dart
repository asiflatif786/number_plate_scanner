import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/nigerian_states.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/agent_entity.dart';
import '../viewmodels/agent_viewmodel.dart';

class AgentRegistrationScreen extends StatefulWidget {
  final String companyNumber;

  const AgentRegistrationScreen({super.key, required this.companyNumber});

  @override
  State<AgentRegistrationScreen> createState() =>
      _AgentRegistrationScreenState();
}

class _AgentRegistrationScreenState extends State<AgentRegistrationScreen> {
  static const String _tag = 'AgentRegistrationScreen';
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'Nigerian');
  final _lgaController = TextEditingController();
  final _lgaOfOriginController = TextEditingController();
  final _bvnController = TextEditingController();
  final _ninController = TextEditingController();
  final _identityNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _sortCodeController = TextEditingController();
  final _tinController = TextEditingController();

  String? _dateOfBirthDisplay;
  String? _dateOfBirthApi;
  bool _obscureBvn = true;
  bool _obscureNin = true;

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _nationalityController.dispose();
    _lgaController.dispose();
    _lgaOfOriginController.dispose();
    _bvnController.dispose();
    _ninController.dispose();
    _identityNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _sortCodeController.dispose();
    _tinController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final minAge = now.subtract(const Duration(days: 365 * 18));
    final maxAge = DateTime(1940);

    final picked = await showDatePicker(
      context: context,
      initialDate: minAge,
      firstDate: maxAge,
      lastDate: minAge,
    );

    if (picked != null) {
      _dateOfBirthApi = DateFormat('yyyy-MM-dd').format(picked);
      _dateOfBirthDisplay = DateFormat('dd/MM/yyyy').format(picked);
      AppLogger.debug(_tag, 'DOB selected: $_dateOfBirthApi');
      setState(() {});
    }
  }

  Future<void> _pickDocument({
    required void Function(String base64, String fileName) onPicked,
  }) async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: result,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final fileName = pickedFile.name;

      AppLogger.info(_tag, 'Document uploaded: $fileName (${bytes.length} bytes)');
      onPicked(base64String, fileName);
    } catch (e) {
      AppLogger.error(_tag, 'Failed to pick document', e);
    }
  }

  void _onSubmit() {
    final viewmodel = context.read<AgentViewModel>();

    if (!_formKey.currentState!.validate()) return;

    if (!viewmodel.allDocumentsUploaded) {
      CustomDialog.showError(
        context,
        title: 'Missing Documents',
        message: 'Please upload all required documents.',
      );
      return;
    }

    final entity = AgentEntity(
      title: viewmodel.selectedTitle ?? '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      gender: viewmodel.selectedGender ?? '',
      maritalStatus: viewmodel.selectedMaritalStatus ?? '',
      dateOfBirth: _dateOfBirthApi ?? '',
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      nationality: _nationalityController.text.trim(),
      state: viewmodel.selectedState ?? '',
      lga: _lgaController.text.trim(),
      stateOfOrigin: viewmodel.selectedStateOfOrigin ?? '',
      lgaOfOrigin: _lgaOfOriginController.text.trim(),
      bvn: _bvnController.text.trim(),
      nin: _ninController.text.trim(),
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      accountName: _accountNameController.text.trim(),
      sortCode: _sortCodeController.text.trim(),
      idType: viewmodel.selectedIdType ?? '',
      identityNumber: _identityNumberController.text.trim(),
      tin: _tinController.text.trim().isEmpty
          ? null
          : _tinController.text.trim(),
      companyNumber: widget.companyNumber,
      utilityBill: viewmodel.utilityBillBase64 ?? '',
      identityDocument: viewmodel.identityDocumentBase64 ?? '',
      passportPhoto: viewmodel.passportPhotoBase64 ?? '',
    );

    viewmodel.registerAgent(entity);
  }

  void _onSuccess(BuildContext context, AgentViewModel viewmodel) {
    if (!viewmodel.isSubmitted || viewmodel.agentNumber == null) return;

    final agentNum = viewmodel.agentNumber!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomDialog.showSuccess(
        context,
        title: 'Agent Registered!',
        message:
            'Agent number: $agentNum\n\nPlease save this number.',
        onClose: () => Navigator.pop(context),
      );
    });
  }

  void _onError(BuildContext context, AgentViewModel viewmodel) {
    if (viewmodel.errorMessage == null) return;

    final errorMsg = viewmodel.errorMessage!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomDialog.showError(
        context,
        title: 'Registration Failed',
        message: errorMsg,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentViewModel>(
      builder: (context, viewmodel, _) {
        _onSuccess(context, viewmodel);
        _onError(context, viewmodel);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Register Agent'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: ResponsiveHelper.isTablet(context) ? 64 : kToolbarHeight,
          ),
          body: LoadingOverlay(
            isLoading: viewmodel.isLoading,
            message: 'Registering agent...',
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoBanner(),
                    SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                    _buildPersonalInfoSection(viewmodel),
                    SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                    _buildAddressSection(viewmodel),
                    SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                    _buildIdentityBankingSection(viewmodel),
                    SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                    _buildDocumentsSection(viewmodel),
                    const SizedBox(height: 32),
                    _buildSubmitButton(viewmodel),
                    const SizedBox(height: 24),
                  ],
                ),
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
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF0288D1), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Registering under Company: ${widget.companyNumber}',
              style: const TextStyle(
                color: Color(0xFF0288D1),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? hintText,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixIcon,
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
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        validator: (v) => v == null ? '$label is required' : null,
        decoration: InputDecoration(
          labelText: label,
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
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionCard(Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildPersonalInfoSection(AgentViewModel viewmodel) {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Information'),
          _buildDropdown(
            label: 'Title',
            value: viewmodel.selectedTitle,
            items: viewmodel.titles,
            onChanged: (v) {
              if (v != null) viewmodel.setTitle(v);
            },
          ),
          ResponsiveFieldRow(
            context: context,
            firstField: _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              validator: (v) =>
                  Validators.validateRequired(v ?? '', 'First Name'),
            ),
            secondField: _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              validator: (v) =>
                  Validators.validateRequired(v ?? '', 'Last Name'),
            ),
          ),
          _buildTextField(
            controller: _middleNameController,
            label: 'Middle Name (Optional)',
          ),
          _buildDropdown(
            label: 'Gender',
            value: viewmodel.selectedGender,
            items: viewmodel.genders,
            onChanged: (v) {
              if (v != null) viewmodel.setGender(v);
            },
          ),
          _buildDropdown(
            label: 'Marital Status',
            value: viewmodel.selectedMaritalStatus,
            items: viewmodel.maritalStatuses,
            onChanged: (v) {
              if (v != null) viewmodel.setMaritalStatus(v);
            },
          ),
          _buildDateOfBirthField(),
          ResponsiveFieldRow(
            context: context,
            firstField: _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => Validators.validateEmail(v ?? ''),
            ),
            secondField: _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              hintText: '08XXXXXXXXX',
              validator: (v) => Validators.validatePhone(v ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(text: _dateOfBirthDisplay ?? ''),
        validator: (v) =>
            _dateOfBirthApi == null ? 'Date of birth is required' : null,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          hintText: 'dd/MM/yyyy',
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1A237E)),
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
        onTap: _selectDateOfBirth,
      ),
    );
  }

  Widget _buildAddressSection(AgentViewModel viewmodel) {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Address Information'),
          _buildTextField(
            controller: _addressController,
            label: 'Residential Address',
            maxLines: 2,
            validator: (v) {
              if (v == null || v.trim().length < 5) {
                return 'Address must be at least 5 characters';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _cityController,
            label: 'City',
            validator: (v) =>
                Validators.validateRequired(v ?? '', 'City'),
          ),
          _buildTextField(
            controller: _nationalityController,
            label: 'Nationality',
            validator: (v) =>
                Validators.validateRequired(v ?? '', 'Nationality'),
          ),
          _buildDropdown(
            label: 'State of Residence',
            value: viewmodel.selectedState,
            items: NigerianStates.states,
            onChanged: (v) {
              if (v != null) viewmodel.setState(v);
            },
          ),
          _buildTextField(
            controller: _lgaController,
            label: 'LGA of Residence',
            validator: (v) =>
                Validators.validateRequired(v ?? '', 'LGA of Residence'),
          ),
          _buildDropdown(
            label: 'State of Origin',
            value: viewmodel.selectedStateOfOrigin,
            items: NigerianStates.states,
            onChanged: (v) {
              if (v != null) viewmodel.setStateOfOrigin(v);
            },
          ),
          _buildTextField(
            controller: _lgaOfOriginController,
            label: 'LGA of Origin',
            validator: (v) =>
                Validators.validateRequired(v ?? '', 'LGA of Origin'),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityBankingSection(AgentViewModel viewmodel) {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Identity & Banking'),
          _buildTextField(
            controller: _bvnController,
            label: 'BVN',
            keyboardType: TextInputType.number,
            obscureText: _obscureBvn,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureBvn ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscureBvn = !_obscureBvn),
            ),
            validator: (v) => Validators.validateBVN(v ?? ''),
          ),
          _buildTextField(
            controller: _ninController,
            label: 'NIN',
            keyboardType: TextInputType.number,
            obscureText: _obscureNin,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNin ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscureNin = !_obscureNin),
            ),
            validator: (v) => Validators.validateNIN(v ?? ''),
          ),
          _buildDropdown(
            label: 'ID Type',
            value: viewmodel.selectedIdType,
            items: viewmodel.idTypes,
            onChanged: (v) {
              if (v != null) viewmodel.setIdType(v);
            },
          ),
          _buildTextField(
            controller: _identityNumberController,
            label: 'Identity Number',
            validator: (v) =>
                Validators.validateRequired(v ?? '', 'Identity Number'),
          ),
          _buildTextField(
            controller: _bankNameController,
            label: 'Bank Name',
            validator: (v) =>
                Validators.validateRequired(v ?? '', 'Bank Name'),
          ),
          _buildTextField(
            controller: _accountNumberController,
            label: 'Account Number',
            keyboardType: TextInputType.number,
            validator: (v) =>
                Validators.validateAccountNumber(v ?? ''),
          ),
          _buildTextField(
            controller: _accountNameController,
            label: 'Account Name',
            validator: (v) =>
                Validators.validateRequired(v ?? '', 'Account Name'),
          ),
          _buildTextField(
            controller: _sortCodeController,
            label: 'Sort Code',
            validator: (v) =>
                Validators.validateRequired(v ?? '', 'Sort Code'),
          ),
          _buildTextField(
            controller: _tinController,
            label: 'TIN (Optional)',
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(AgentViewModel viewmodel) {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Required Documents'),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'All three documents are required',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          _buildDocRow(
            label: 'Utility Bill',
            required: true,
            fileName: viewmodel.utilityBillName,
            onUpload: () => _pickDocument(
              onPicked: (base64, name) =>
                  viewmodel.setUtilityBill(base64, name),
            ),
          ),
          const SizedBox(height: 8),
          _buildDocRow(
            label: 'Identity Document',
            required: true,
            fileName: viewmodel.identityDocumentName,
            onUpload: () => _pickDocument(
              onPicked: (base64, name) =>
                  viewmodel.setIdentityDocument(base64, name),
            ),
          ),
          const SizedBox(height: 8),
          _buildDocRow(
            label: 'Passport Photo',
            required: true,
            fileName: viewmodel.passportPhotoName,
            onUpload: () => _pickDocument(
              onPicked: (base64, name) =>
                  viewmodel.setPassportPhoto(base64, name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocRow({
    required String label,
    required bool required,
    required String? fileName,
    required VoidCallback onUpload,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Icon(Icons.description, color: fileName != null
              ? const Color(0xFF2E7D32)
              : Colors.grey),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (required)
                    const Text(' *', style: TextStyle(color: Colors.red)),
                ],
              ),
              if (fileName != null)
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2E7D32),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onUpload,
          icon: Icon(
            fileName != null ? Icons.refresh : Icons.upload_file,
            size: 18,
          ),
          label: Text(fileName != null ? 'Change' : 'Upload'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1A237E),
            side: const BorderSide(color: Color(0xFF1A237E)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AgentViewModel viewmodel) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.buttonHeight(context),
      child: ElevatedButton(
        onPressed: viewmodel.isLoading ? null : _onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF1A237E).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
        child: const Text(
          'Register Agent',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
