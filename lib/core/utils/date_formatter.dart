import 'package:intl/intl.dart';
import 'logger.dart';

class DateFormatter {
  static const String _tag = 'DateFormatter';

  static String toApiFormat(DateTime date) {
    final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    AppLogger.debug(_tag, 'toApiFormat: $formatted');
    return formatted;
  }

  static String toDisplayFormat(DateTime date) {
    final formatted = DateFormat('dd/MM/yyyy').format(date);
    AppLogger.debug(_tag, 'toDisplayFormat: $formatted');
    return formatted;
  }

  static String toDateOnlyApiFormat(DateTime date) {
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    AppLogger.debug(_tag, 'toDateOnlyApiFormat: $formatted');
    return formatted;
  }

  static String toReadableDateTime(String apiDateTime) {
    try {
      final date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(apiDateTime);
      final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(date);
      return formatted;
    } catch (e) {
      AppLogger.debug(_tag, 'Parse error for: $apiDateTime');
      return apiDateTime;
    }
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 3) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }
}
