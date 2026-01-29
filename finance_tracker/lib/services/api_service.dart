import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class ApiService {
  static const String apiUrl = "https://script.google.com/macros/s/AKfycbyiCgsCBuk8wMzJReISNte_fV3lYNXAdDfvfTSbPig9k-qKC9gU0VinQwvbaBwcZ9737Q/exec";
  static const String apiToken = "694ec953e60c832280e4316f7d02b261";

  Future<dynamic> _post(String action, Map<String, String> payload) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['token'] = apiToken;
      request.fields['action'] = action;
      request.fields.addAll(payload);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      final text = response.body;
      if (text.trim().startsWith('<!DOCTYPE') || text.trim().startsWith('<html')) {
         throw Exception('Received HTML instead of JSON');
      }

      final data = jsonDecode(text);
      if (data is Map && data.containsKey('error')) {
        throw Exception(data['error']);
      }
      return data;
    } catch (e) {
      print('API Error ($action): $e');
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchTransactions() async {
    final result = await _post('fetch', {});
    if (result is List) {
      return result.map((json) => TransactionModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await _post('add', {
        'id': tx.id,
        'date': tx.date.toIso8601String(),
        'amount': tx.amount.toString(),
        'note': tx.note,
    });
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    await _post('update', {
        'id': tx.id,
        'date': tx.date.toIso8601String(),
        'amount': tx.amount.toString(),
        'note': tx.note,
    });
  }

  Future<void> deleteTransaction(String id) async {
    await _post('delete', {'id': id});
  }
}
