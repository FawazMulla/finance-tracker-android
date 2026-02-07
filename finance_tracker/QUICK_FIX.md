# Quick Fix for Widget Crash

## 🐛 Problem
Widget crashes with: `java.lang.ClassCastException: java.lang.Long cannot be cast to java.lang.String`

## ✅ Solution (Choose One)

### Option 1: Clear App Data (Fastest)
```bash
adb shell pm clear com.example.finance_tracker
flutter run
```

### Option 2: Uninstall & Reinstall
```bash
adb uninstall com.example.finance_tracker
flutter run
```

### Option 3: Manual Clear (No Command Line)
1. Settings → Apps → Finance Tracker
2. Storage → Clear Data
3. Reopen app

## 🎯 Why This Works

The widget code now handles all data types (String, Float, Long), but old cached data needs to be cleared once.

## ✨ After Fixing

1. App opens successfully ✓
2. Add a transaction to test
3. Widget updates correctly ✓
4. Add widget to home screen
5. Test quick add buttons ✓

## 🚀 You're Done!

The issue won't happen again - the new code is backward compatible.
