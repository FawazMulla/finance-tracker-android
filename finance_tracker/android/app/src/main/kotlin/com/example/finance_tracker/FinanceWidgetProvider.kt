package com.example.finance_tracker

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.app.PendingIntent

class FinanceWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            
            // Read balance as string to avoid type casting issues
            val balanceStr = prefs.getString("balance", "0.0") ?: "0.0"
            val balance = balanceStr.toDoubleOrNull() ?: 0.0
            
            val transactionCount = prefs.getInt("transaction_count", 0)

            val views = RemoteViews(context.packageName, R.layout.finance_widget)
            views.setTextViewText(R.id.widget_balance, "₹${String.format("%.2f", balance)}")

            // Set up quick add button for income
            val incomeIntent = Intent(context, QuickAddActivity::class.java).apply {
                putExtra("is_income", true)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val incomePendingIntent = PendingIntent.getActivity(
                context,
                1,
                incomeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_add_income, incomePendingIntent)

            // Set up quick add button for expense
            val expenseIntent = Intent(context, QuickAddActivity::class.java).apply {
                putExtra("is_income", false)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val expensePendingIntent = PendingIntent.getActivity(
                context,
                2,
                expenseIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_add_expense, expensePendingIntent)

            // Set up refresh button
            val refreshIntent = Intent(context, WidgetService::class.java).apply {
                action = WidgetService.ACTION_REFRESH
            }
            val refreshPendingIntent = PendingIntent.getService(
                context,
                3,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_refresh, refreshPendingIntent)

            // Set up click on widget body to open the app
            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openAppPendingIntent = PendingIntent.getActivity(
                context,
                4,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_balance, openAppPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_balance_label, openAppPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_title, openAppPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
