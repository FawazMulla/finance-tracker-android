import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final WidgetService _widgetService = WidgetService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  String? _syncStatus;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  String? get syncStatus => _syncStatus;

  double get currentBalance => _transactions.fold(0, (sum, item) => sum + item.amount);

  TransactionProvider() {
    _loadInitialData();
  }

  Future<void> _updateWidget() async {
    await _widgetService.updateWidget(
      balance: currentBalance,
      transactionCount: _transactions.length,
    );
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
      await _updateWidget();
    } catch (e) {
      _error = e.toString();

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
    _syncStatus = 'Saving...';
    notifyListeners();

    try {
      // Save locally first
      await _storageService.saveTransactions(_transactions);
      _syncStatus = 'Syncing to cloud...';
      notifyListeners();
      
      // Then sync to API
      _isSyncing = true;
      await _apiService.addTransaction(newTx);
      _syncStatus = 'Synced ✓';
      await _updateWidget();
      
      // Clear status after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _syncStatus = null;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to sync: $e';
      _syncStatus = 'Saved locally (offline)';
      if (kDebugMode) {
        print('Error syncing transaction: $e');
      }
      
      // Clear status after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _syncStatus = null;
        notifyListeners();
      });
    } finally {
      _isSyncing = false;
      notifyListeners();
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
      await _updateWidget();
    } catch (e) {
      _error = 'Failed to sync delete: $e';
      // Rollback
      _transactions.insert(index, removedTx);
      notifyListeners();
    }
  }
}
