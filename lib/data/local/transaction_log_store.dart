import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionLogStore {
  static const String _key = 'transaction_log';
  static const int _maxEntries = 200;

  Future<void> saveTransaction(TransactionModel transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = _decodeList(prefs.getString(_key));
    existing.insert(0, transaction);
    if (existing.length > _maxEntries) {
      existing.removeRange(_maxEntries, existing.length);
    }
    await prefs.setString(
        _key, jsonEncode(existing.map((e) => e.toJson()).toList()));
  }

  Future<List<TransactionModel>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      return _decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> updateStatus(
      String transactionReference, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _decodeList(prefs.getString(_key));
    bool found = false;
    for (int i = 0; i < list.length; i++) {
      if (list[i].transactionReference == transactionReference) {
        list[i] = list[i].copyWith(status: newStatus);
        found = true;
        break;
      }
    }
    if (found) {
      await prefs.setString(
          _key, jsonEncode(list.map((e) => e.toJson()).toList()));
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  List<TransactionModel> _decodeList(String? raw) {
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
