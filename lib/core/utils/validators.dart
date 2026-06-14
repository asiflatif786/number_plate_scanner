class Validators {
  static String? validatePhone(String value) {
    if (value.isEmpty) return 'Phone number is required';
    if (value.length != 11) return 'Phone number must be 11 digits';
    if (!value.startsWith('0')) return 'Phone number must start with 0';
    if (!RegExp(r'^\d{11}$').hasMatch(value)) return 'Phone number must contain only digits';
    return null;
  }

  static String? validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? validateBVN(String value) {
    if (value.isEmpty) return 'BVN is required';
    if (value.length != 11) return 'BVN must be exactly 11 digits';
    if (!RegExp(r'^\d{11}$').hasMatch(value)) return 'BVN must contain only digits';
    return null;
  }

  static String? validateNIN(String value) {
    if (value.isEmpty) return 'NIN is required';
    if (value.length != 11) return 'NIN must be exactly 11 digits';
    if (!RegExp(r'^\d{11}$').hasMatch(value)) return 'NIN must contain only digits';
    return null;
  }

  static String? validateRCNumber(String value) {
    if (value.isEmpty) return 'RC number is required';
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) return 'RC number must be alphanumeric';
    return null;
  }

  static String? validateAccountNumber(String value) {
    if (value.isEmpty) return 'Account number is required';
    if (value.length != 10) return 'Account number must be exactly 10 digits';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Account number must contain only digits';
    return null;
  }

  static String? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) return 'Year is required';
    final number = int.tryParse(value.trim());
    if (number == null) return 'Year must be a number';
    final currentYear = DateTime.now().year;
    if (number < 1990 || number > currentYear) {
      return 'Year must be between 1990 and $currentYear';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validatePasswordMatch(String password, String confirm) {
    if (confirm.isEmpty) return 'Please confirm your password';
    if (password != confirm) return 'Passwords do not match';
    return null;
  }

  static String? validatePlate(String value) {
    if (value.trim().isEmpty) return 'License plate is required';
    if (value.trim().length < 5) return 'License plate must be at least 5 characters';
    return null;
  }

  static String? validateMinLength(String value, int min, String fieldName) {
    if (value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length < min) return '$fieldName must be at least $min characters';
    return null;
  }
}
