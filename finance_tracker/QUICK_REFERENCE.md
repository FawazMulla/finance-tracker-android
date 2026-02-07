# Quick Reference Card

## 🚀 Getting Started (3 Steps)

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run

# 3. Add widget to home screen (see below)
```

## 📱 Add Widget to Home Screen

### Android
Long-press home screen → Widgets → Finance Tracker → Drag to screen

### iOS
Long-press home screen → + button → Search "Finance Tracker" → Add

## 🤳 Use Shake Gesture

1. Open the app
2. Shake phone 2-3 times quickly
3. Add transaction modal appears!

**Note:** Only works on physical devices (not emulators)

## 🔧 Quick Fixes

### Widget not showing balance?
→ Open the app once to initialize

### Shake too sensitive/not sensitive enough?
→ Edit `lib/screens/home_screen.dart` line ~45:
```dart
shakeThresholdGravity: 2.7,  // Lower = more sensitive
```

### Build error on Windows?
→ Enable Developer Mode: `start ms-settings:developers`

## 📂 Important Files

| File | Purpose |
|------|---------|
| `lib/utils/shake_detector.dart` | Shake detection logic |
| `lib/services/widget_service.dart` | Widget updates |
| `lib/screens/home_screen.dart` | Shake integration |
| `android/app/src/main/res/layout/finance_widget.xml` | Android widget UI |
| `ios/FinanceWidget/FinanceWidget.swift` | iOS widget |

## 🎯 Features at a Glance

✅ Home screen widget with balance  
✅ Quick Income/Expense buttons on widget  
✅ Full add transaction button  
✅ Shake to add transaction  
✅ Auto-updates on changes  
✅ Works on Android & iOS  

## 💡 Widget Usage

**Quick Add (No app opening needed!):**
- Tap "↗️ Income" → Enter amount → Done
- Tap "↙️ Expense" → Enter amount → Done

**Full Add:**
- Tap "+ Add Transaction" → Choose type → Enter details  

## 📖 Full Documentation

- **QUICK_START.md** - User guide
- **WIDGET_SETUP.md** - Detailed setup
- **FEATURES.md** - Feature details
- **IMPLEMENTATION_SUMMARY.md** - Technical overview

## 💡 Tips

- Widget updates automatically when you add/delete transactions
- Shake works from any screen in the app
- Widget button opens app even when closed
- No special permissions needed
- Test shake on real device, not emulator

## 🆘 Need Help?

Check `WIDGET_SETUP.md` for troubleshooting section
