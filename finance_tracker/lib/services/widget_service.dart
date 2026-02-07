import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

class WidgetService {
  static const String _androidWidgetName = 'FinanceWidgetProvider';
  static const String _iOSWidgetName = 'FinanceWidget';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.com.example.finance_tracker');
    
    // Clear any old cached data to prevent type casting issues
    try {
      final prefs = await HomeWidget.getWidgetData<String>('balance');
      if (prefs == null) {
        // Initialize with default values
        await updateWidget(balance: 0.0, transactionCount: 0);
      }
    } catch (e) {
      // If there's any error reading old data, reset it
      await updateWidget(balance: 0.0, transactionCount: 0);
    }
  }

  Future<void> updateWidget({
    required double balance,
    required int transactionCount,
  }) async {
    try {
      // Store as string to avoid type casting issues
      await HomeWidget.saveWidgetData<String>('balance', balance.toString());
      await HomeWidget.saveWidgetData<int>('transaction_count', transactionCount);
      await HomeWidget.saveWidgetData<String>(
        'last_update',
        DateTime.now().toIso8601String(),
      );
      
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating widget: $e');
      }
    }
  }

  Future<void> registerBackgroundCallback() async {
    await HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  static void backgroundCallback(Uri? uri) {
    if (uri != null && (uri.host == 'addtransaction' || uri.host == 'quickadd')) {
      // Handle widget tap - this will be caught by the app
    }
  }
}

