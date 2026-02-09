import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class StorageService {
  static const String keyTransactions = 'transactions_cache';
  static const String keyTheme = 'theme';

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(keyTransactions, jsonString);
    if (kDebugMode) {
      print('[StorageService] Saved ${transactions.length} transactions');
    }
  }

  Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Force reload to get latest data from native code
    await prefs.reload();
    
    final jsonString = prefs.getString(keyTransactions);
    
    if (kDebugMode) {
      print('[StorageService] Loading transactions...');
      print('[StorageService] Raw JSON length: ${jsonString?.length ?? 0}');
    }
    
    if (jsonString == null || jsonString.isEmpty) {
      if (kDebugMode) print('[StorageService] No transactions found in cache');
      return [];
    }

    try {
      final List<TransactionModel> transactions = await compute(_parseTransactions, jsonString);
      if (kDebugMode) {
        print('[StorageService] Loaded ${transactions.length} transactions');
        if (transactions.isNotEmpty) {
          print('[StorageService] First tx: ${transactions.first.note}, amount: ${transactions.first.amount}');
        }
      }
      return transactions;
    } catch (e) {
      if (kDebugMode) {
        print('[StorageService] Error parsing transactions: $e');
        print('[StorageService] JSON was: ${jsonString.substring(0, jsonString.length.clamp(0, 200))}...');
      }
      return [];
    }
  }

  // Static function for compute
  static List<TransactionModel> _parseTransactions(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyTheme, theme);
  }

  Future<String?> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyTheme);
  }
}
