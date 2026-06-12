import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class AddAgentScreen extends StatefulWidget {
  const AddAgentScreen({super.key});

  @override
  State<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Map<String, TextEditingController> _controllers = {
    'title': TextEditingController(),
    'first_name': TextEditingController(),
    'last_name': TextEditingController(),
    'middle_name': TextEditingController(),
    'gender': TextEditingController(),
    'marital_status': TextEditingController(),
    'date_of_birth': TextEditingController(),
    'email': TextEditingController(),
    'phone_number': TextEditingController(),
    'address': TextEditingController(),
    'city': TextEditingController(),
    'nationality': TextEditingController(),
    'state': TextEditingController(),
    'lga': TextEditingController(),
    'state_of_origin': TextEditingController(),
    'lga_of_origin': TextEditingController(),
    'bvn': TextEditingController(),
    'nin': TextEditingController(),
    'bank_name': TextEditingController(),
    'account_number': TextEditingController(),
    'account_name': TextEditingController(),
    'sort_code': TextEditingController(),
    'id_type': TextEditingController(),
    'identity_number': TextEditingController(),
    'tin': TextEditingController(),
    'company_number': TextEditingController(),
    'password': TextEditingController(),
  };

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Formatted as YYYY-MM-DD manually to avoid dependency issues
        _controllers['date_of_birth']!.text = 
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _addAgent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic> body = {
      "key": ApiConstants.apiKey,
      "action": "add-agent",
    };

    _controllers.forEach((key, controller) {
      body[key] = controller.text.trim();
    });

    body['utility_bill'] = "base64_encoded_string_here";
    body['identity_document'] = "base64_encoded_string_here";
    body['passport_photo'] = "base64_encoded_string_here";

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Agent added successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to add agent'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Agent'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Personal Information'),
                    _buildDropdownField('title', 'Title', ['Mr', 'Mrs']),
                    _buildTextField('first_name', 'First Name'),
                    _buildTextField('last_name', 'Last Name'),
                    _buildTextField('middle_name', 'Middle Name', isOptional: true),
                    _buildDropdownField('gender', 'Gender', ['male', 'female', 'other']),
                    _buildDateField('date_of_birth', 'Date of Birth'),
                    _buildDropdownField('marital_status', 'Marital Status', ['Single', 'Married']),
                    
                    _buildSectionTitle('Contact Details'),
                    _buildTextField('email', 'Email', keyboardType: TextInputType.emailAddress),
                    _buildTextField('phone_number', 'Phone Number', keyboardType: TextInputType.phone),
                    _buildTextField('address', 'Address'),
                    _buildTextField('city', 'City'),
                    _buildTextField('state', 'State'),
                    _buildTextField('lga', 'LGA'),
                    _buildTextField('nationality', 'Nationality'),
                    
                    _buildSectionTitle('Origin Details'),
                    _buildTextField('state_of_origin', 'State of Origin'),
                    _buildTextField('lga_of_origin', 'LGA of Origin'),
                    
                    _buildSectionTitle('Identification & Finance'),
                    _buildTextField('bvn', 'BVN'),
                    _buildTextField('nin', 'NIN'),
                    _buildTextField('tin', 'TIN'),
                    _buildTextField('id_type', 'ID Type'),
                    _buildTextField('identity_number', 'Identity Number'),
                    _buildTextField('bank_name', 'Bank Name'),
                    _buildTextField('account_number', 'Account Number'),
                    _buildTextField('account_name', 'Account Name'),
                    _buildTextField('sort_code', 'Sort Code'),
                    _buildTextField('company_number', 'Company Number'),
                    
                    _buildSectionTitle('Account Security'),
                    _buildTextField('password', 'Password', obscureText: true),
                    
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _addAgent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Register Agent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildTextField(String key, String label, {TextInputType? keyboardType, bool obscureText = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label + (isOptional ? ' (Optional)' : ''),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        validator: (value) => (!isOptional && value!.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdownField(String key, String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _controllers[key]!.text.isEmpty ? null : _controllers[key]!.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _controllers[key]!.text = newValue!;
          });
        },
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildDateField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _controllers[key],
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }
}
