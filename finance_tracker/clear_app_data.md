# Clear App Data (Troubleshooting)

If you're experiencing widget crashes due to old cached data, follow these steps:

## Method 1: Clear App Data (Recommended)

### Android
```bash
# Clear app data and cache
adb shell pm clear com.example.finance_tracker

# Then reinstall
flutter run
```

### Manual Method (Android)
1. Go to Settings → Apps
2. Find "Finance Tracker"
3. Tap "Storage"
4. Tap "Clear Data" and "Clear Cache"
5. Reopen the app

## Method 2: Uninstall and Reinstall

### Android
```bash
# Uninstall
adb uninstall com.example.finance_tracker

# Reinstall
flutter run
```

### Manual Method
1. Long-press app icon
2. Tap "Uninstall"
3. Run `flutter run` to reinstall

## Method 3: Remove Widget First

If widget is causing crashes:
1. Remove widget from home screen
2. Clear app data (Method 1)
3. Reopen app
4. Add widget again

## Why This Happens

The widget stores data in SharedPreferences. If you're upgrading from an older version:
- Old version stored balance as `Float` or `Long`
- New version stores balance as `String`
- Android can't automatically convert between types

The updated code now handles all data types, but clearing old data ensures a clean start.

## After Clearing Data

1. Open the app
2. App will initialize with default values
3. Add a transaction to test
4. Widget should update correctly
5. Add widget to home screen

## Verify It's Working

```bash
# Check if app is running
adb shell ps | grep finance_tracker

# Check SharedPreferences (requires root or debuggable app)
adb shell run-as com.example.finance_tracker cat shared_prefs/HomeWidgetPreferences.xml
```

## Prevention

The new code handles type mismatches automatically, so this should only be needed once during the upgrade.
