import 'package:flutter/material.dart';

class MaskedField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator;

  const MaskedField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLength,
    this.validator,
  });

  @override
  State<MaskedField> createState() => _MaskedFieldState();
}

class _MaskedFieldState extends State<MaskedField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          obscureText: _obscured,
          style: TextStyle(
            fontFamily: _obscured ? null : 'monospace',
            letterSpacing: _obscured ? null : 2,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
            counterText: '',
            suffixIcon: IconButton(
              icon: Icon(
                _obscured ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9E9E9E),
                size: 20,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
