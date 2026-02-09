package com.example.finance_tracker

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.util.Log
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent

class VolumeAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "VolumeGesture"
        private const val GESTURE_WINDOW_MS = 400L // 400ms window for simultaneous press
    }

    private var lastVolumeUpTime: Long = 0
    private var lastVolumeDownTime: Long = 0
    private var gestureTriggered = false

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Not used, but required
    }

    override fun onInterrupt() {
        // Not used, but required
    }

    override fun onKeyEvent(event: KeyEvent): Boolean {
        val keyCode = event.keyCode
        val action = event.action

        if (action == KeyEvent.ACTION_DOWN) {
            val currentTime = System.currentTimeMillis()

            when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    lastVolumeUpTime = currentTime
                    Log.d(TAG, "Volume UP pressed at $currentTime")
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    lastVolumeDownTime = currentTime
                    Log.d(TAG, "Volume DOWN pressed at $currentTime")
                }
            }

            // Check if both interactions happened within the time window
            val timeDiff = Math.abs(lastVolumeUpTime - lastVolumeDownTime)

            if (timeDiff < GESTURE_WINDOW_MS && timeDiff > 0 && !gestureTriggered) {
                Log.d(TAG, "GESTURE TRIGGERED! Diff=$timeDiff ms - Launching Quick Add")
                gestureTriggered = true
                launchQuickAdd()
                return true // Consume the event
            }
        } else if (action == KeyEvent.ACTION_UP) {
            if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                gestureTriggered = false
                Log.d(TAG, "Button released, resetting trigger state.")
            }
        }

        return super.onKeyEvent(event)
    }

    private fun launchQuickAdd() {
        val intent = Intent(this, QuickAddActivity::class.java).apply {
            // Pass "choose" mode so QuickAddActivity shows both options
            putExtra("choose_type", true)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }
}
