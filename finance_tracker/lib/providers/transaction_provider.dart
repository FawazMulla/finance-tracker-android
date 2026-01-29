import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get currentBalance => _transactions.fold(0, (sum, item) => sum + item.amount);

  TransactionProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load cache first for speed
      _transactions = await _storageService.loadTransactions();
      notifyListeners();

      // Then fetch from API
      await fetchTransactions();
    } catch (e) {
      // If API fails, we rely on cache and show error locally
      print('Initial load error: $e');
    } finally {
      if (_transactions.isEmpty) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteData = await _apiService.fetchTransactions();
      _transactions = remoteData;
      // Sort by date descending
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      await _storageService.saveTransactions(_transactions);
    } catch (e) {
      _error = e.toString();
      print('Fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(double amount, String note) async {
    final newTx = TransactionModel(
      id: const Uuid().v4(),
      date: DateTime.now(),
      amount: amount,
      note: note,
    );

    // Optimistic UI update
    _transactions.insert(0, newTx);
    notifyListeners();

    try {
      await _storageService.saveTransactions(_transactions);
      await _apiService.addTransaction(newTx);
    } catch (e) {
      _error = 'Failed to sync add: $e';
      // Rollback or queue for later (Queue not implemented yet in minimal plan)
      // For now, keep local change but warn
      print('Add error: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index == -1) return;

    final removedTx = _transactions[index];
    _transactions.removeAt(index);
    notifyListeners();

    try {
      await _storageService.saveTransactions(_transactions);
      await _apiService.deleteTransaction(id);
    } catch (e) {
      _error = 'Failed to sync delete: $e';
      // Rollback
      _transactions.insert(index, removedTx);
      notifyListeners();
      print('Delete error: $e');
    }
  }
}
