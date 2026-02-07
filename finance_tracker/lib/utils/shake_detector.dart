import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final VoidCallback onShake;
  final double shakeThresholdGravity;
  final int shakeSlopTimeMS;
  final int shakeCountResetTime;
  final int minimumShakeCount;

  StreamSubscription<AccelerometerEvent>? _streamSubscription;
  int _shakeCount = 0;
  int _lastShakeTime = 0;

  ShakeDetector({
    required this.onShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
    this.minimumShakeCount = 2,
  });

  void startListening() {
    _streamSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      double gX = x / 9.80665;
      double gY = y / 9.80665;
      double gZ = z / 9.80665;

      // Calculate total acceleration
      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > shakeThresholdGravity) {
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Ignore shake events too close together
        if (_lastShakeTime + shakeSlopTimeMS > now) {
          return;
        }

        // Reset shake count if too much time has passed
        if (_lastShakeTime + shakeCountResetTime < now) {
          _shakeCount = 0;
        }

        _lastShakeTime = now;
        _shakeCount++;

        if (_shakeCount >= minimumShakeCount) {
          _shakeCount = 0;
          onShake();
        }
      }
    });
  }

  void stopListening() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  static ShakeDetector autoStart({
    required VoidCallback onPhoneShake,
    double shakeThresholdGravity = 2.7,
    int shakeSlopTimeMS = 500,
    int shakeCountResetTime = 3000,
    int minimumShakeCount = 2,
  }) {
    final detector = ShakeDetector(
      onShake: onPhoneShake,
      shakeThresholdGravity: shakeThresholdGravity,
      shakeSlopTimeMS: shakeSlopTimeMS,
      shakeCountResetTime: shakeCountResetTime,
      minimumShakeCount: minimumShakeCount,
    );
    detector.startListening();
    return detector;
  }
}
