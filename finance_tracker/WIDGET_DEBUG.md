# Widget Debugging Guide

## Widget Not Working - Troubleshooting Steps

### Step 1: Check if Widget is Added

1. Long-press on home screen
2. Tap "Widgets"
3. Look for "Finance Tracker"
4. If not there, app might not be installed properly

**Fix:** Reinstall app
```bash
flutter clean
flutter run
```

### Step 2: Check Widget Permissions

**Android:**
- Settings → Apps → Finance Tracker → Permissions
- Ensure no permissions are blocked

### Step 3: Check Widget Layout

The widget should show:
```
┌─────────────────────────┐
│ Finance Tracker         │
│ Current Balance         │
│ ₹0.00                  │
│ [↗️ Income] [↙️ Expense]│
│ [+ Add Transaction]     │
└─────────────────────────┘
```

If widget shows but buttons don't work, continue to Step 4.

### Step 4: Test Deep Linking

**Test from command line:**
```bash
adb shell am start -a android.intent.action.VIEW -d "financetracker://addtransaction" com.example.finance_tracker
```

**Expected:** App should open with add transaction modal

**If it doesn't work:**
- Check AndroidManifest.xml has intent-filter
- Verify URL scheme is "financetracker"
- Rebuild app

### Step 5: Check Widget Provider

**View widget logs:**
```bash
adb logcat | grep -i "FinanceWidget"
```

**Look for:**
- Widget update calls
- Button click events
- Intent creation

### Step 6: Manually Update Widget

**From app:**
1. Open Finance Tracker app
2. Add a transaction
3. Check if widget balance updates

**If balance doesn't update:**
- Widget data not being saved
- Check logs for "Error updating widget"

### Step 7: Remove and Re-add Widget

1. Long-press widget
2. Drag to "Remove"
3. Re-add widget from widget picker
4. Test buttons again

### Step 8: Check SharedPreferences

**Test if data is being saved:**
```bash
adb shell run-as com.example.finance_tracker
cd shared_prefs
cat HomeWidgetPreferences.xml
```

**Should see:**
```xml
<string name="balance">1234.56</string>
<int name="transaction_count" value="5" />
```

### Step 9: Test Widget Buttons Individually

**Test Income Button:**
```bash
adb shell am start -a android.intent.action.VIEW -d "financetracker://quickadd?type=income" com.example.finance_tracker
```

**Test Expense Button:**
```bash
adb shell am start -a android.intent.action.VIEW -d "financetracker://quickadd?type=expense" com.example.finance_tracker
```

**Test Add Button:**
```bash
adb shell am start -a android.intent.action.VIEW -d "financetracker://addtransaction" com.example.finance_tracker
```

### Step 10: Check Widget Receiver

**Verify receiver is registered:**
```bash
adb shell dumpsys package com.example.finance_tracker | grep -A 10 "Receiver"
```

**Should see:**
```
Receiver: com.example.finance_tracker.FinanceWidgetProvider
```

---

## Common Widget Issues

### Issue 1: Widget Shows ₹0.00

**Cause:** Widget not initialized or data not saved

**Fix:**
1. Open app
2. Add a transaction
3. Widget should update

### Issue 2: Widget Buttons Do Nothing

**Cause:** Deep linking not working

**Fix:**
1. Check AndroidManifest.xml has:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="financetracker" />
</intent-filter>
```

2. Rebuild app:
```bash
flutter clean
flutter run
```

### Issue 3: Widget Doesn't Update

**Cause:** Widget update not being called

**Fix:**
1. Check logs for "Error updating widget"
2. Verify WidgetService is being called
3. Check SharedPreferences are being saved

### Issue 4: Widget Disappeared

**Cause:** App uninstalled or widget removed

**Fix:**
1. Reinstall app
2. Re-add widget from widget picker

### Issue 5: Widget Shows Old Data

**Cause:** Widget not refreshing

**Fix:**
1. Remove widget
2. Re-add widget
3. Open app once to initialize

---

## Shake Gesture Debugging

### Test Shake Detection

**Check if shake is detected:**
1. Open app
2. Shake phone 2-3 times quickly
3. Check logs for "Shake detected! Opening modal..."

**If no log appears:**
- Shake harder/faster
- Try 3-4 shakes
- Check accelerometer is working

**Test accelerometer:**
```bash
adb shell dumpsys sensorservice | grep -i accel
```

### Adjust Shake Sensitivity

**Make more sensitive:**
```dart
// In lib/screens/home_screen.dart
shakeThresholdGravity: 2.0,  // Lower = more sensitive
```

**Make less sensitive:**
```dart
shakeThresholdGravity: 3.5,  // Higher = less sensitive
```

### Shake Not Opening Modal

**Check logs for:**
```
Shake detected! Opening modal...
```

**If you see this but modal doesn't open:**
- Context might not be mounted
- Modal might be opening behind another screen
- Check if you're on home screen

---

## Widget Testing Checklist

- [ ] Widget appears in widget picker
- [ ] Widget shows on home screen
- [ ] Widget displays balance
- [ ] Income button opens app
- [ ] Expense button opens app
- [ ] Add button opens app
- [ ] Correct modal opens for each button
- [ ] Widget updates after adding transaction
- [ ] Widget persists after app restart
- [ ] Widget works after device restart

---

## Shake Testing Checklist

- [ ] Shake detected in logs
- [ ] Modal opens on shake
- [ ] Shake works from home screen
- [ ] Shake works from history screen
- [ ] Shake works from stats screen
- [ ] Sensitivity is appropriate
- [ ] No false positives

---

## Quick Fixes

### Widget Not Showing:
```bash
flutter clean
flutter run
# Then re-add widget
```

### Buttons Not Working:
```bash
# Test deep linking
adb shell am start -a android.intent.action.VIEW -d "financetracker://addtransaction" com.example.finance_tracker
```

### Shake Not Working:
```bash
# Check logs
flutter logs | grep -i "shake"
```

### Widget Not Updating:
```bash
# Check widget data
adb shell run-as com.example.finance_tracker cat shared_prefs/HomeWidgetPreferences.xml
```

---

## Get Help

If widget still doesn't work after all steps:

1. **Collect logs:**
```bash
flutter logs > app_logs.txt
adb logcat > system_logs.txt
```

2. **Check versions:**
```bash
flutter doctor -v
```

3. **Test on different device:**
- Try emulator vs physical device
- Try different Android version

4. **Verify files exist:**
- `android/app/src/main/kotlin/.../FinanceWidgetProvider.kt`
- `android/app/src/main/res/layout/finance_widget.xml`
- `android/app/src/main/res/xml/finance_widget_info.xml`
