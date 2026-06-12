import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/nigerian_states.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/vehicle_registration_entity.dart';
import '../viewmodels/vehicle_registration_viewmodel.dart';
import '../widgets/animated_form_section.dart';
import '../widgets/vehicle_type_dropdown.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  final String licensePlate;

  const VehicleRegistrationScreen({
    super.key,
    required this.licensePlate,
  });

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState
    extends State<VehicleRegistrationScreen> {
  static const String _tag = 'VehicleRegScreen';
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _engineNumberController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _lgaController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownerEmailController.text = 'owner@example.com';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleRegistrationViewModel>().loadVehicleTypes();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _engineNumberController.dispose();
    _chassisNumberController.dispose();
    _lgaController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _ownerAddressController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final viewmodel = context.read<VehicleRegistrationViewModel>();

    if (!_formKey.currentState!.validate()) return;

    if (viewmodel.selectedVehicleType == null) {
      _showError('Please select a vehicle type');
      return;
    }
    if (viewmodel.selectedIssuingState == null) {
      _showError('Please select an issuing state');
      return;
    }
    if (viewmodel.selectedPlateType == null) {
      _showError('Please select a plate type');
      return;
    }
    if (viewmodel.hasEnumeratingDetails) {
      if (viewmodel.selectedEnumeratingState == null) {
        _showError('Please select an enumerating state');
        return;
      }
      if (_lgaController.text.trim().isEmpty) {
        _showError('Please enter the enumerating LGA');
        return;
      }
    }

    final entity = VehicleRegistrationEntity(
      vehicleLicense: widget.licensePlate,
      vehicleType: viewmodel.selectedVehicleType!,
      engineNumber: _engineNumberController.text.trim(),
      chassisNumber: _chassisNumberController.text.trim(),
      color: _colorController.text.trim(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? 0,
      plateType: viewmodel.selectedPlateType!,
      issuingState: viewmodel.selectedIssuingState!,
      enumeratingState: viewmodel.hasEnumeratingDetails
          ? viewmodel.selectedEnumeratingState
          : null,
      enumeratingLga: viewmodel.hasEnumeratingDetails
          ? _lgaController.text.trim()
          : null,
      ownerName: _ownerNameController.text.trim(),
      ownerPhone: _ownerPhoneController.text.trim(),
      ownerEmail: _ownerEmailController.text.trim(),
      ownerAddress: _ownerAddressController.text.trim(),
    );

    AppLogger.info(_tag,
        'Submitting registration for: ${widget.licensePlate}');
    viewmodel.registerVehicle(entity);
  }

  void _showError(String message) {
    CustomDialog.showError(
      context,
      title: 'Validation Error',
      message: message,
    );
  }

  void _onSuccess(VehicleRegistrationViewModel viewmodel) {
    if (!viewmodel.isSubmitted ||
        viewmodel.successMessage == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomDialog.showSuccess(
        context,
        title: 'Vehicle Registered!',
        message:
            'The vehicle ${widget.licensePlate} has been successfully registered in the Cyber1 database.\n\nYou can now process a transaction for this vehicle.',
        buttonText: 'Proceed to Search',
        onClose: () {
          AppLogger.info(_tag,
              'Redirecting to search for: ${widget.licensePlate}');
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/vehicle-search',
            (route) => false,
            arguments: widget.licensePlate,
          );
        },
      );
    });
  }

  void _onError(VehicleRegistrationViewModel viewmodel) {
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
    return Consumer<VehicleRegistrationViewModel>(
      builder: (context, viewmodel, _) {
        _onSuccess(viewmodel);
        _onError(viewmodel);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Register Vehicle'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: ResponsiveHelper.isTablet(context) ? 64 : kToolbarHeight,
          ),
          body: LoadingOverlay(
            isLoading: viewmodel.isLoading,
            message: 'Registering vehicle...',
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotFoundBanner(),
                    const SizedBox(height: 16),
                    _buildVehicleInfoSection(viewmodel),
                    const SizedBox(height: 16),
                    _buildRegistrationDetailsSection(viewmodel),
                    const SizedBox(height: 16),
                    _buildOwnerInfoSection(),
                    const SizedBox(height: 16),
                    _buildInfoBox(),
                    const SizedBox(height: 16),
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

  Widget _buildNotFoundBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFFFE082)),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFF57C00), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle ${widget.licensePlate} was not found in the database.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF57C00),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please complete the form below to register it.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                ),
              ],
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

  Widget _buildSectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          filled: readOnly,
          fillColor: readOnly ? const Color(0xFFF5F5F5) : null,
          suffixIcon: readOnly
              ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStateDropdown({
    required String? value,
    required String label,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        validator: validator ??
            (v) => v == null ? '$label is required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide:
                const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
        items: NigerianStates.states.map((state) {
          return DropdownMenuItem(value: state, child: Text(state));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildVehicleInfoSection(
      VehicleRegistrationViewModel viewmodel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Vehicle Information'),
            _buildTextField(
              controller:
                  TextEditingController(text: widget.licensePlate),
              label: 'License Plate (Pre-filled)',
              readOnly: true,
            ),
            VehicleTypeDropdown(
              types: viewmodel.vehicleTypes,
              isLoading: viewmodel.isLoadingTypes,
              selectedValue: viewmodel.selectedVehicleType,
              onChanged: (value) => viewmodel.setVehicleType(value ?? ''),
            ),
            ResponsiveFieldRow(
              context: context,
              firstField: _buildTextField(
                controller: _makeController,
                label: 'Vehicle Make',
                hintText: 'e.g. Toyota, Honda, Mercedes',
                validator: (v) =>
                    (v == null || v.trim().length < 2)
                        ? 'Make must be at least 2 characters'
                        : null,
              ),
              secondField: _buildTextField(
                controller: _modelController,
                label: 'Vehicle Model',
                hintText: 'e.g. Camry, Civic, C-Class',
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Model is required'
                        : null,
              ),
            ),
            ResponsiveFieldRow(
              context: context,
              firstField: _buildTextField(
                controller: _yearController,
                label: 'Year of Manufacture',
                hintText: 'e.g. 2019',
                keyboardType: TextInputType.number,
                validator: Validators.validateYear,
              ),
              secondField: _buildTextField(
                controller: _colorController,
                label: 'Color',
                hintText: 'e.g. White, Black, Silver',
                validator: (v) =>
                    (v == null || v.trim().length < 3)
                        ? 'Color must be at least 3 characters'
                        : null,
              ),
            ),
            ResponsiveFieldRow(
              context: context,
              firstField: _buildTextField(
                controller: _engineNumberController,
                label: 'Engine Number',
                hintText: 'Engine number from vehicle documents',
                validator: (v) =>
                    (v == null || v.trim().length < 5)
                        ? 'Engine number must be at least 5 characters'
                        : null,
              ),
              secondField: _buildTextField(
                controller: _chassisNumberController,
                label: 'Chassis Number',
                hintText: 'VIN/Chassis number',
                validator: (v) =>
                    (v == null || v.trim().length < 8)
                        ? 'Chassis number must be at least 8 characters'
                        : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: viewmodel.selectedPlateType,
                validator: (v) =>
                    v == null ? 'Plate type is required' : null,
                decoration: const InputDecoration(
                  labelText: 'Plate Type',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF1A237E), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                items: ['Private', 'Commercial'].map((type) {
                  return DropdownMenuItem(
                      value: type, child: Text(type));
                }).toList(),
                onChanged: (value) =>
                    viewmodel.setPlateType(value ?? ''),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationDetailsSection(
      VehicleRegistrationViewModel viewmodel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Registration Details'),
            _buildStateDropdown(
              value: viewmodel.selectedIssuingState,
              label: 'Issuing State',
              onChanged: (value) =>
                  viewmodel.setIssuingState(value ?? ''),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Has Enumerating Details?',
                  style:
                      TextStyle(fontSize: 14, color: Color(0xFF616161)),
                ),
                const Spacer(),
                Switch(
                  value: viewmodel.hasEnumeratingDetails,
                  activeColor: const Color(0xFF1A237E),
                  onChanged: (value) =>
                      viewmodel.toggleEnumeratingDetails(value),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Enable if vehicle has a registered enumeration tag',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic),
              ),
            ),
            AnimatedFormSection(
              isVisible: viewmodel.hasEnumeratingDetails,
              child: Column(
                children: [
                  _buildStateDropdown(
                    value: viewmodel.selectedEnumeratingState,
                    label: 'Enumerating State',
                    onChanged: (value) =>
                        viewmodel.setEnumeratingState(value),
                    validator: viewmodel.hasEnumeratingDetails
                        ? (v) =>
                            v == null ? 'Enumerating state is required' : null
                        : null,
                  ),
                  _buildTextField(
                    controller: _lgaController,
                    label: 'Enumerating LGA',
                    hintText: 'LGA where tag was registered',
                    validator: viewmodel.hasEnumeratingDetails
                        ? (v) => (v == null || v.trim().isEmpty)
                            ? 'LGA is required'
                            : null
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Owner Information'),
            _buildSectionSubtitle('Details of the registered vehicle owner'),
            _buildTextField(
              controller: _ownerNameController,
              label: 'Owner Full Name',
              hintText: 'Full legal name of vehicle owner',
              validator: (v) =>
                  (v == null || v.trim().length < 3)
                      ? 'Name must be at least 3 characters'
                      : null,
            ),
            _buildTextField(
              controller: _ownerPhoneController,
              label: 'Owner Phone Number',
              hintText: '08XXXXXXXXX',
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  Validators.validatePhone(v?.trim() ?? ''),
            ),
            _buildTextField(
              controller: _ownerEmailController,
              label: 'Owner Email',
              hintText: 'owner@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  Validators.validateEmail(v?.trim() ?? ''),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Leave default if owner has no email',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic),
              ),
            ),
            _buildTextField(
              controller: _ownerAddressController,
              label: 'Owner Address',
              hintText: 'Residential or business address',
              maxLines: 2,
              validator: (v) =>
                  (v == null || v.trim().length < 10)
                      ? 'Address must be at least 10 characters'
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              color: Color(0xFF0288D1), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'After successful registration, you will be redirected to process a transaction for this vehicle.',
              style: TextStyle(fontSize: 12, color: Color(0xFF0288D1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(VehicleRegistrationViewModel viewmodel) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.buttonHeight(context),
      child: ElevatedButton.icon(
        onPressed: viewmodel.isLoading ? null : _onSubmit,
        icon: const Icon(Icons.app_registration, color: Colors.white),
        label: const Text(
          'Register Vehicle',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF1A237E).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
      ),
    );
  }
}
