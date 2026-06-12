import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';

class VehicleTypeDropdown extends StatelessWidget {
  final List<String> types;
  final bool isLoading;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const VehicleTypeDropdown({
    super.key,
    required this.types,
    required this.isLoading,
    required this.selectedValue,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Loading vehicle types...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: const InputDecoration(
          labelText: 'Vehicle Type',
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        hint: const Text('Select vehicle type'),
        items: types.map((type) {
          return DropdownMenuItem(value: type, child: Text(type));
        }).toList(),
        validator: (value) => value == null ? 'Vehicle type is required' : null,
        onChanged: (value) {
          AppLogger.debug('VehicleTypeDropdown', 'Type selected: $value');
          onChanged(value);
        },
      ),
    );
  }
}
