package com.example.finance_tracker

import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.IBinder
import android.os.PowerManager
import kotlin.math.sqrt

class ShakeService : Service(), SensorEventListener {
    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var wakeLock: PowerManager.WakeLock? = null
    
    private var lastShakeTime: Long = 0
    private var shakeCount = 0
    
    companion object {
        private const val SHAKE_THRESHOLD = 2.7
        private const val SHAKE_SLOP_TIME_MS = 500
        private const val SHAKE_COUNT_RESET_TIME_MS = 3000
        private const val MIN_SHAKE_COUNT = 2
    }

    override fun onCreate() {
        super.onCreate()
        
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        
        // Acquire wake lock to keep service running
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "FinanceTracker::ShakeWakeLock"
        )
        wakeLock?.acquire(10*60*1000L /*10 minutes*/)
        
        // Register sensor listener
        accelerometer?.let {
            sensorManager?.registerListener(
                this,
                it,
                SensorManager.SENSOR_DELAY_UI
            )
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onSensorChanged(event: SensorEvent?) {
        event?.let {
            if (it.sensor.type == Sensor.TYPE_ACCELEROMETER) {
                val x = it.values[0] / 9.80665
                val y = it.values[1] / 9.80665
                val z = it.values[2] / 9.80665
                
                val gForce = sqrt(x * x + y * y + z * z)
                
                if (gForce > SHAKE_THRESHOLD) {
                    val now = System.currentTimeMillis()
                    
                    // Ignore shake events too close together
                    if (lastShakeTime + SHAKE_SLOP_TIME_MS > now) {
                        return
                    }
                    
                    // Reset shake count if too much time has passed
                    if (lastShakeTime + SHAKE_COUNT_RESET_TIME_MS < now) {
                        shakeCount = 0
                    }
                    
                    lastShakeTime = now
                    shakeCount++
                    
                    if (shakeCount >= MIN_SHAKE_COUNT) {
                        shakeCount = 0
                        onShakeDetected()
                    }
                }
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not needed
    }

    private fun onShakeDetected() {
        // Open app with quick add intent
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = android.net.Uri.parse("financetracker://addtransaction")
            setPackage(packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager?.unregisterListener(this)
        wakeLock?.release()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
