package com.example.finance_tracker

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.EditText
import android.widget.Toast

class QuickAddActivity : Activity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val isIncome = intent.getBooleanExtra("is_income", false)
        val title = if (isIncome) "Add Income" else "Add Expense"
        
        val input = EditText(this).apply {
            hint = "Enter amount"
            inputType = android.text.InputType.TYPE_CLASS_NUMBER or android.text.InputType.TYPE_NUMBER_FLAG_DECIMAL
        }
        
        AlertDialog.Builder(this)
            .setTitle(title)
            .setView(input)
            .setPositiveButton("Add") { _, _ ->
                val amount = input.text.toString()
                if (amount.isNotEmpty()) {
                    addTransaction(amount, isIncome)
                } else {
                    Toast.makeText(this, "Please enter amount", Toast.LENGTH_SHORT).show()
                }
                finish()
            }
            .setNegativeButton("Cancel") { _, _ ->
                finish()
            }
            .setOnCancelListener {
                finish()
            }
            .show()
    }
    
    private fun addTransaction(amount: String, isIncome: Boolean) {
        val serviceIntent = Intent(this, WidgetService::class.java).apply {
            action = if (isIncome) WidgetService.ACTION_ADD_INCOME else WidgetService.ACTION_ADD_EXPENSE
            putExtra(WidgetService.EXTRA_AMOUNT, amount)
        }
        startService(serviceIntent)
    }
}
