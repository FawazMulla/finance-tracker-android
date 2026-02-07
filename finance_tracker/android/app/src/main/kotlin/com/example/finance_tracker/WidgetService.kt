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
                if (amount != null && amount.isNotEmpty()) {
                    addTransaction(amount.toDoubleOrNull() ?: 0.0, true)
                    Toast.makeText(this, "Income added: ₹$amount", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(this, "Please enter amount", Toast.LENGTH_SHORT).show()
                }
            }
            ACTION_ADD_EXPENSE -> {
                val amount = intent.getStringExtra(EXTRA_AMOUNT)
                if (amount != null && amount.isNotEmpty()) {
                    addTransaction(amount.toDoubleOrNull() ?: 0.0, false)
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

    private fun addTransaction(amount: Double, isIncome: Boolean) {
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
        saveTransactionToStorage(finalAmount, if (isIncome) "Income" else "Expense")

        // Update widget
        refreshWidget()
    }

    private fun saveTransactionToStorage(amount: Double, note: String) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        
        // Create transaction JSON
        val transaction = JSONObject().apply {
            put("id", UUID.randomUUID().toString())
            put("amount", amount)
            put("note", note)
            put("date", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date()))
        }

        // Get existing transactions
        val transactionsJson = prefs.getString("flutter.transactions", "[]") ?: "[]"
        val transactionsList = try {
            org.json.JSONArray(transactionsJson)
        } catch (e: Exception) {
            org.json.JSONArray()
        }

        // Add new transaction
        transactionsList.put(transaction)

        // Save back
        prefs.edit().apply {
            putString("flutter.transactions", transactionsList.toString())
            apply()
        }
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
    }
}
