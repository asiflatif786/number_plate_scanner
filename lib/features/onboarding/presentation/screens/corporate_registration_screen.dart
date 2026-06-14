import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/nigerian_states.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/corporate_entity.dart';
import '../viewmodels/corporate_viewmodel.dart';

class CorporateRegistrationScreen extends StatefulWidget {
  const CorporateRegistrationScreen({super.key});

  @override
  State<CorporateRegistrationScreen> createState() =>
      _CorporateRegistrationScreenState();
}

class _CorporateRegistrationScreenState
    extends State<CorporateRegistrationScreen> {
  static const String _tag = 'CorporateRegistrationScreen';
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _nameController = TextEditingController();
  final _rcNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tinController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _lgaController = TextEditingController();

  String? _selectedState;
  String? _cacBase64;
  String? _cac7Base64;
  String? _mematBase64;
  String? _proofOfAddressBase64;
  String? _cacStatusBase64;

  String? _cacFileName;
  String? _cac7FileName;
  String? _mematFileName;
  String? _proofOfAddressFileName;
  String? _cacStatusFileName;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _rcNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _tinController.dispose();
    _addressController.dispose();
    _contactAddressController.dispose();
    _cityController.dispose();
    _lgaController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument({
    required void Function(String base64, String fileName) onPicked,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final fileName = pickedFile.name;

      AppLogger.info(_tag, 'Picked: $fileName (${bytes.length} bytes)');
      onPicked(base64String, fileName);
    } catch (e) {
      AppLogger.error(_tag, 'Failed to pick document', e);
    }
  }

  Widget _buildUploadField({
    required String label,
    required String? fileName,
    required VoidCallback onUpload,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                if (fileName != null)
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 12,
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
          const SizedBox(width: 8),
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
  }) {
    return AppTextField(
      label: label,
      hint: hintText,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines,
    );
  }

  Widget _buildStateDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedState,
        validator: (value) =>
            value == null ? 'State is required' : null,
        decoration: InputDecoration(
          labelText: 'State',
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
        items: NigerianStates.states.map((state) {
          return DropdownMenuItem(value: state, child: Text(state));
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedState = value);
        },
      ),
    );
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final viewmodel = context.read<CorporateViewModel>();
    final entity = CorporateEntity(
      name: _nameController.text.trim(),
      rcNumber: _rcNumberController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      contactAddress: _contactAddressController.text.trim(),
      tin: _tinController.text.trim(),
      city: _cityController.text.trim(),
      state: _selectedState ?? '',
      lga: _lgaController.text.trim(),
      cac: _cacBase64,
      cac7: _cac7Base64,
      memat: _mematBase64,
      proofOfAddress: _proofOfAddressBase64,
      cacStatus: _cacStatusBase64,
    );

    viewmodel.registerCorporate(entity);
  }

  void _onSuccess(BuildContext context, CorporateViewModel viewmodel) {
    if (!viewmodel.isSubmitted ||
        viewmodel.companyNumber == null ||
        viewmodel.successMessage == null) {
      return;
    }

    final companyNumber = viewmodel.companyNumber!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomDialog.showSuccess(
        context,
        title: 'Company Registered!',
        message:
            'Your company number is: $companyNumber\n\nPlease save this for agent registration.',
        onClose: () => Navigator.pop(context),
      );
    });
  }

  void _onError(BuildContext context, CorporateViewModel viewmodel) {
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
    return Consumer<CorporateViewModel>(
      builder: (context, viewmodel, _) {
        _onSuccess(context, viewmodel);
        _onError(context, viewmodel);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Register Company'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: ResponsiveHelper.isTablet(context) ? 64 : kToolbarHeight,
          ),
          body: LoadingOverlay(
            isLoading: viewmodel.isLoading,
            message: 'Registering company...',
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
              child: Form(
                key: _formKey,
                child: ResponsiveHelper.isTablet(context)
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCompanySection(),
                              SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                              _buildAddressSection(),
                              SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                              _buildDocumentsSection(),
                              const SizedBox(height: 32),
                              _buildSubmitButton(viewmodel),
                              SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompanySection(),
                          SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                          _buildAddressSection(),
                          SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                          _buildDocumentsSection(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(viewmodel),
                          SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompanySection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Company Information', fontSize: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Company Name',
              validator: (value) {
                if (value == null || value.trim().length < 3) {
                  return 'Company name must be at least 3 characters';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _rcNumberController,
              label: 'RC Number',
              validator: (value) =>
                  Validators.validateRequired(value ?? '', 'RC Number'),
            ),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  Validators.validateEmail(value ?? ''),
            ),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              hintText: '08XXXXXXXXX',
              validator: (value) =>
                  Validators.validatePhone(value ?? ''),
            ),
            _buildTextField(
              controller: _tinController,
              label: 'TIN (Tax ID Number)',
              validator: (value) =>
                  Validators.validateRequired(value ?? '', 'TIN'),
            ),
          ],
        ),
    );
  }

  Widget _buildAddressSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Address Details', fontSize: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Registered Address',
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().length < 5) {
                  return 'Address must be at least 5 characters';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _contactAddressController,
              label: 'Contact Address',
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().length < 5) {
                  return 'Contact address must be at least 5 characters';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _cityController,
              label: 'City',
              validator: (value) =>
                  Validators.validateRequired(value ?? '', 'City'),
            ),
            _buildStateDropdown(),
            _buildTextField(
              controller: _lgaController,
              label: 'LGA',
              hintText: 'Will auto-populate later',
              validator: (value) =>
                  Validators.validateRequired(value ?? '', 'LGA'),
            ),
          ],
        ),
    );
  }

  Widget _buildDocumentsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Documents (Optional)',
            subtitle: 'Upload supporting documents in PDF or image format',
            fontSize: 16,
          ),
            _buildUploadField(
              label: 'CAC',
              fileName: _cacFileName,
              onUpload: () => _pickDocument(
                onPicked: (base64, name) =>
                    setState(() { _cacBase64 = base64; _cacFileName = name; }),
              ),
            ),
            _buildUploadField(
              label: 'CAC 7',
              fileName: _cac7FileName,
              onUpload: () => _pickDocument(
                onPicked: (base64, name) =>
                    setState(() { _cac7Base64 = base64; _cac7FileName = name; }),
              ),
            ),
            _buildUploadField(
              label: 'MEMAT',
              fileName: _mematFileName,
              onUpload: () => _pickDocument(
                onPicked: (base64, name) =>
                    setState(() { _mematBase64 = base64; _mematFileName = name; }),
              ),
            ),
            _buildUploadField(
              label: 'Proof of Address',
              fileName: _proofOfAddressFileName,
              onUpload: () => _pickDocument(
                onPicked: (base64, name) {
                  setState(() {
                    _proofOfAddressBase64 = base64;
                    _proofOfAddressFileName = name;
                  });
                },
              ),
            ),
            _buildUploadField(
              label: 'CAC Status',
              fileName: _cacStatusFileName,
              onUpload: () => _pickDocument(
                onPicked: (base64, name) {
                  setState(() {
                    _cacStatusBase64 = base64;
                    _cacStatusFileName = name;
                  });
                },
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildSubmitButton(CorporateViewModel viewmodel) {
    return AppButton(
      label: 'Register Company',
      onPressed: viewmodel.isLoading ? null : _onSubmit,
      isLoading: viewmodel.isLoading,
      height: ResponsiveHelper.buttonHeight(context),
    );
  }
}
