import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class ApiService {
  static const String apiUrl =
      "https://script.google.com/macros/s/AKfycbyiCgsCBuk8wMzJReISNte_fV3lYNXAdDfvfTSbPig9k-qKC9gU0VinQwvbaBwcZ9737Q/exec";
  static const String apiToken = "694ec953e60c832280e4316f7d02b261";

  /// POST request to Google Apps Script (matches doPost function)
  Future<dynamic> _post(String action, Map<String, String> payload) async {
    final client = http.Client();
    try {
      final uri = Uri.parse(apiUrl);
      
      // Create form data body (same as web app)
      final body = {
        'token': apiToken,
        'action': action,
        ...payload,
      };


      // POST request with form data
      final request = http.Request('POST', uri)
        ..bodyFields = body
        ..followRedirects = false; // Handle redirects manually

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);


      
      // Handle 302 redirect from Google Apps Script
      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectResponse = await client.get(Uri.parse(redirectUrl));

          
          if (redirectResponse.statusCode >= 400) {
            throw Exception('HTTP ${redirectResponse.statusCode}: ${redirectResponse.reasonPhrase}');
          }
          
          final data = jsonDecode(redirectResponse.body);
          
          // Check for error in response
          if (data is Map && data.containsKey('error')) {
            throw Exception(data['error']);
          }
          
          return data;
        }
      }


      
      // Only print first 200 chars to avoid flooding console
      if (response.body.length > 200) {

      } else {

      }

      if (response.statusCode >= 400) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      // Check for HTML response (deployment permission issue)
      if (response.body.trim().startsWith('<')) {
        throw Exception(
          'Received HTML instead of JSON. Check Google Apps Script deployment:\n'
          '1. Go to Deploy → Manage deployments\n'
          '2. Ensure "Who has access" is set to "Anyone"\n'
          '3. Redeploy if needed'
        );
      }

      final data = jsonDecode(response.body);
      
      // Check for error in response
      if (data is Map && data.containsKey('error')) {
        throw Exception(data['error']);
      }

      return data;
    } catch (e) {

      rethrow;
    } finally {
      client.close();
    }
  }

  // Public API methods

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
