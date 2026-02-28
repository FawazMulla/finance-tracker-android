import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import '../services/firestore_backup_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final WidgetService _widgetService = WidgetService();
  final FirestoreBackupService _firestoreBackup = FirestoreBackupService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  String? _syncStatus;
  DateTime? _lastFetchTime;
  bool _isBusy = false; // Guard against overlapping calls
  static const _fetchThrottleInterval = Duration(minutes: 5);

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  String? get syncStatus => _syncStatus;

  double get currentBalance => _transactions.fold(0, (sum, item) => sum + item.amount);

  TransactionProvider() {
    loadInitialData();
  }

  Future<void> _updateWidget() async {
    await _widgetService.updateWidget(
      balance: currentBalance,
      transactionCount: _transactions.length,
    );
  }

  Future<void> loadInitialData({bool forceRemoteFetch = false}) async {
    if (_isBusy) return;
    _isBusy = true;

    // Stage 1: Always load from local cache first (instant response)
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _storageService.loadTransactions();
      _isLoading = false;
      notifyListeners();

      // Check for unsynced transactions (e.g. from volume gesture/widget)
      final unsynced = _transactions.where((tx) => !tx.isSynced).toList();
      
      bool needsRemoteFetch = forceRemoteFetch;
      
      // If we have unsynced items, we MUST sync them
      if (unsynced.isNotEmpty) {
        _syncStatus = 'Syncing new data...';
        notifyListeners();
        
        for (final tx in unsynced) {
          try {
            await _apiService.addTransaction(tx);
            // Mark as synced in local memory
            final idx = _transactions.indexOf(tx);
            if (idx != -1) {
              _transactions[idx] = TransactionModel(
                id: tx.id,
                date: tx.date,
                amount: tx.amount,
                note: tx.note,
                isSynced: true,
              );
            }
          } catch (e) {
             if (kDebugMode) print('Failed to sync widget tx ${tx.id}: $e');
          }
        }
        
        // After syncing, we should update local storage once
        await _storageService.saveTransactions(_transactions);
        _syncStatus = null;
        notifyListeners();
        needsRemoteFetch = true; // Refresh from remote because we just sent new data
      }

      // Stage 2: Only fetch from remote if throttled or forced
      final now = DateTime.now();
      if (!needsRemoteFetch && _lastFetchTime != null) {
        if (now.difference(_lastFetchTime!) < _fetchThrottleInterval) {
          if (kDebugMode) print('[TransactionProvider] Skipping remote fetch (throttled)');
          return;
        }
      }

      // If we got here, we are fetching
      await fetchTransactions();
    } catch (e) {
      if (kDebugMode) print('Error in loadInitialData: $e');
      _isLoading = false;
      notifyListeners();
    } finally {
      _isBusy = false;
    }
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteData = await _apiService.fetchTransactions();
      
      // Preserve local unsynced transactions (from widget/volume gesture)
      final localUnsynced = _transactions.where((tx) => !tx.isSynced).toList();
      
      // Create a map of remote IDs for efficient lookup
      final remoteIds = remoteData.map((tx) => tx.id).toSet();
      
      // Only keep unsynced ones that aren't already in the remote data
      final missingUnsynced = localUnsynced.where((tx) => !remoteIds.contains(tx.id)).toList();
      
      // Merge: Unsynced locally first, then remote data
      _transactions = [...missingUnsynced, ...remoteData];
      
      // Sort by date descending
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      
      _lastFetchTime = DateTime.now();
      await _storageService.saveTransactions(_transactions);
      await _updateWidget();
      
      if (kDebugMode && missingUnsynced.isNotEmpty) {
        print('[TransactionProvider] Preserved ${missingUnsynced.length} unsynced transactions during fetch');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('[TransactionProvider] Error fetching: $e');
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
      
      // Then sync to API (Google Sheets - primary)
      _isSyncing = true;
      await _apiService.addTransaction(newTx);
      
      // Backup to Firestore (silent, non-blocking)
      _firestoreBackup.addBackupRecord(newTx);
      
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
      
      // Backup delete to Firestore (silent, non-blocking)
      _firestoreBackup.deleteBackupRecord(id);
      
      await _updateWidget();
    } catch (e) {
      _error = 'Failed to sync delete: $e';
      // Rollback
      _transactions.insert(index, removedTx);
      notifyListeners();
    }
  }
}
