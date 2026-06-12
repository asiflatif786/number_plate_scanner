import 'dart:math';

class TransactionReferenceGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static String generate() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomPart = List.generate(
      8,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
    return 'TXN${timestamp.substring(timestamp.length - 8)}$randomPart';
  }
}
