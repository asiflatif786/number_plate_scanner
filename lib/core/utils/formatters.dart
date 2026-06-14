import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(dynamic amount) {
    final num value;
    if (amount is num) {
      value = amount;
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    } else {
      value = 0.0;
    }
    final format = NumberFormat('#,##0.00', 'en_US');
    return 'NGN ${format.format(value)}';
  }

  static String formatDate(String dateStr, {String inputFormat = 'yyyy-MM-dd HH:mm:ss', String outputFormat = 'MMM dd, yyyy hh:mm a'}) {
    try {
      final parsed = DateFormat(inputFormat).parse(dateStr);
      return DateFormat(outputFormat).format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateShort(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  static String maskString(String value, {int visibleStart = 4, int visibleEnd = 2}) {
    if (value.length <= visibleStart + visibleEnd) {
      return value;
    }
    final start = value.substring(0, visibleStart);
    final end = value.substring(value.length - visibleEnd);
    final masked = '*' * (value.length - visibleStart - visibleEnd);
    return '$start$masked$end';
  }

  static String formatPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
  }

  static String formatPlate(String plate) {
    final cleaned = plate.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    if (cleaned.length == 8) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    if (cleaned.length == 7) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 5)} ${cleaned.substring(5)}';
    }
    return cleaned;
  }
}
