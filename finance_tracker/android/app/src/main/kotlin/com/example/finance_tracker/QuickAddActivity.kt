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
        
        val chooseType = intent.getBooleanExtra("choose_type", false)
        
        if (chooseType) {
            // Show choice dialog first
            showTypeChoiceDialog()
        } else {
            // Direct call with type already specified
            val isIncome = intent.getBooleanExtra("is_income", false)
            showAmountDialog(isIncome)
        }
    }
    
    private fun showTypeChoiceDialog() {
        AlertDialog.Builder(this)
            .setTitle("Quick Transaction")
            .setItems(arrayOf("➕ Add Income", "➖ Add Expense")) { _, which ->
                val isIncome = (which == 0)
                showAmountDialog(isIncome)
            }
            .setNegativeButton("Cancel") { _, _ ->
                finish()
            }
            .setOnCancelListener {
                finish()
            }
            .show()
    }
    
    private fun showAmountDialog(isIncome: Boolean) {
        val title = if (isIncome) "Add Income" else "Add Expense"
        
        val layout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setPadding(50, 40, 50, 10)
        }

        val inputAmount = EditText(this).apply {
            hint = "Enter amount"
            inputType = android.text.InputType.TYPE_CLASS_NUMBER or android.text.InputType.TYPE_NUMBER_FLAG_DECIMAL
        }
        
        val inputNote = EditText(this).apply {
            hint = "Note (optional)"
            inputType = android.text.InputType.TYPE_CLASS_TEXT
        }

        layout.addView(inputAmount)
        layout.addView(inputNote)
        
        AlertDialog.Builder(this)
            .setTitle(title)
            .setView(layout)
            .setPositiveButton("Add") { _, _ ->
                val amount = inputAmount.text.toString()
                val note = inputNote.text.toString()
                if (amount.isNotEmpty()) {
                    addTransaction(amount, note, isIncome)
                    val typeText = if (isIncome) "Income" else "Expense"
                    Toast.makeText(this, "$typeText added: ₹$amount", Toast.LENGTH_SHORT).show()
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
    
    private fun addTransaction(amount: String, note: String, isIncome: Boolean) {
        val serviceIntent = Intent(this, WidgetService::class.java).apply {
            action = if (isIncome) WidgetService.ACTION_ADD_INCOME else WidgetService.ACTION_ADD_EXPENSE
            putExtra(WidgetService.EXTRA_AMOUNT, amount)
            putExtra(WidgetService.EXTRA_NOTE, note)
        }
        startService(serviceIntent)
    }
}
