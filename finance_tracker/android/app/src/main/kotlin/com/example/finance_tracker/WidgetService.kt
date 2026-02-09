package com.example.finance_tracker

import android.app.Service
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.widget.Toast
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class WidgetService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_ADD_INCOME -> {
                val amount = intent.getStringExtra(EXTRA_AMOUNT)
                val note = intent.getStringExtra(EXTRA_NOTE) ?: "Income"
                if (amount != null && amount.isNotEmpty()) {
                    addTransaction(amount.toDoubleOrNull() ?: 0.0, note.ifEmpty { "Income" }, true)
                    Toast.makeText(this, "Income added: ₹$amount", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(this, "Please enter amount", Toast.LENGTH_SHORT).show()
                }
            }
            ACTION_ADD_EXPENSE -> {
                val amount = intent.getStringExtra(EXTRA_AMOUNT)
                val note = intent.getStringExtra(EXTRA_NOTE) ?: "Expense"
                if (amount != null && amount.isNotEmpty()) {
                    addTransaction(amount.toDoubleOrNull() ?: 0.0, note.ifEmpty { "Expense" }, false)
                    Toast.makeText(this, "Expense added: ₹$amount", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(this, "Please enter amount", Toast.LENGTH_SHORT).show()
                }
            }
            ACTION_REFRESH -> {
                refreshWidget()
                Toast.makeText(this, "Widget refreshed", Toast.LENGTH_SHORT).show()
            }
        }
        
        stopSelf(startId)
        return START_NOT_STICKY
    }

    private fun addTransaction(amount: Double, note: String, isIncome: Boolean) {
        if (amount <= 0) return

        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val currentBalanceStr = prefs.getString("balance", "0.0") ?: "0.0"
        val currentBalance = currentBalanceStr.toDoubleOrNull() ?: 0.0
        
        val finalAmount = if (isIncome) amount else -amount
        val newBalance = currentBalance + finalAmount

        // Save new balance
        prefs.edit().apply {
            putString("balance", newBalance.toString())
            putInt("transaction_count", prefs.getInt("transaction_count", 0) + 1)
            putString("last_update", System.currentTimeMillis().toString())
            apply()
        }

        // Save transaction to local storage
        saveTransactionToStorage(finalAmount, note)

        // Update widget
        refreshWidget()
    }

    private fun saveTransactionToStorage(amount: Double, note: String) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        
        // Create transaction JSON matching Flutter's TransactionModel
        val transaction = JSONObject().apply {
            put("id", UUID.randomUUID().toString())
            put("amount", amount)
            put("note", note)
            put("date", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date()))
            put("isSynced", false)
        }

        // Flutter uses "flutter." prefix for SharedPreferences keys
        val transactionsJson = prefs.getString("flutter.transactions_cache", null)
        val transactionsList = if (transactionsJson != null) {
            try {
                org.json.JSONArray(transactionsJson)
            } catch (e: Exception) {
                org.json.JSONArray()
            }
        } else {
            org.json.JSONArray()
        }

        // Add new transaction at the beginning (most recent first)
        val newList = org.json.JSONArray()
        newList.put(transaction)
        for (i in 0 until transactionsList.length()) {
            newList.put(transactionsList.get(i))
        }

        // Save back with flutter. prefix - use commit() for immediate visibility in Flutter
        val success = prefs.edit().putString("flutter.transactions_cache", newList.toString()).commit()
        
        android.util.Log.d("WidgetService", "SUCCESS: $success")
        android.util.Log.d("WidgetService", "SAVED JSON: ${transaction.toString()}")
        android.util.Log.d("WidgetService", "TOTAL CACHE SIZE: ${newList.length()}")
    }

    private fun refreshWidget() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val widgetComponent = ComponentName(this, FinanceWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(widgetComponent)
        
        for (appWidgetId in appWidgetIds) {
            FinanceWidgetProvider.updateAppWidget(this, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        const val ACTION_ADD_INCOME = "com.example.finance_tracker.ADD_INCOME"
        const val ACTION_ADD_EXPENSE = "com.example.finance_tracker.ADD_EXPENSE"
        const val ACTION_REFRESH = "com.example.finance_tracker.REFRESH"
        const val EXTRA_AMOUNT = "amount"
        const val EXTRA_NOTE = "note"
    }
}
