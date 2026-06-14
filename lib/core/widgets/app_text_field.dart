import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../utils/responsive_helper.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? initialValue;
  final bool enabled;
  final int? maxLength;
  final Color? fillColor;
  final EdgeInsets? customPadding;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.enabled = true,
    this.maxLength,
    this.fillColor,
    this.customPadding,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        AppLogger.debug('AppTextField', 'Field focused: ${widget.label}');
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final contentPadding = widget.customPadding ??
        EdgeInsets.symmetric(
          horizontal: isTablet ? 20.0 : 16.0,
          vertical: isTablet ? 16.0 : 14.0,
        );

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.spacingBetweenFields(context)),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        initialValue: widget.initialValue,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        scrollPadding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 80,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          contentPadding: contentPadding,
          labelStyle: TextStyle(
            fontSize: ResponsiveHelper.fontSize(context, 14),
          ),
          hintStyle: TextStyle(
            fontSize: ResponsiveHelper.fontSize(context, 14),
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.readOnly
              ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
              : widget.suffixIcon,
          filled: widget.readOnly,
          fillColor: widget.readOnly
              ? (widget.fillColor ?? const Color(0xFFF5F5F5))
              : widget.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
      ),
    );
  }
}

class ResponsiveFieldRow extends StatelessWidget {
  final BuildContext context;
  final Widget firstField;
  final Widget secondField;

  const ResponsiveFieldRow({
    super.key,
    required this.context,
    required this.firstField,
    required this.secondField,
  });

  @override
  Widget build(BuildContext _) {
    if (ResponsiveHelper.isTablet(context)) {
      return Row(
        children: [
          Expanded(child: firstField),
          const SizedBox(width: 16),
          Expanded(child: secondField),
        ],
      );
    }
    return Column(
      children: [
        firstField,
        SizedBox(height: ResponsiveHelper.spacingBetweenFields(context)),
        secondField,
      ],
    );
  }
}
