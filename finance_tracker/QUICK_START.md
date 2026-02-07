# Quick Start Guide

## What's New? 🎉

Your Finance Tracker app now has three awesome accessibility features:

### 1. 📱 Home Screen Widget
Add a widget to your home screen that shows:
- Your current balance at a glance
- Quick "Income" and "Expense" buttons for instant logging
- "Add Transaction" button for detailed entries
- Auto-updates when you add/delete transactions

### 2. 🤳 Shake to Add
Simply shake your phone while the app is open to instantly bring up the add transaction screen!

### 3. ⚡ Quick Add from Widget
Tap "Income" or "Expense" buttons directly on the widget to log transactions without opening the full app!

## Getting Started

### Step 1: Install the App
```bash
# For Android
flutter run

# For iOS
flutter build ios
# Then run from Xcode
```

### Step 2: Add the Widget

**Android:**
1. Long-press on your home screen
2. Tap "Widgets"
3. Find "Finance Tracker"
4. Drag it to your home screen

**iOS:**
1. Long-press on your home screen
2. Tap the "+" button (top-left)
3. Search for "Finance Tracker"
4. Select widget size and add

### Step 3: Use Quick Add Buttons
1. From the widget, tap "↗️ Income" or "↙️ Expense"
2. Enter the amount
3. Add optional description
4. Done! Widget updates automatically

### Step 4: Try the Shake Feature
1. Open the app
2. Shake your phone (2-3 quick shakes)
3. The add transaction modal appears!

## Widget Features

### Three Ways to Add Transactions:

1. **Quick Income** (↗️ button): Opens pre-filled income form
2. **Quick Expense** (↙️ button): Opens pre-filled expense form  
3. **Add Transaction** (+ button): Opens full form to choose type

## Tips

- **Widget not updating?** Open the app once to initialize it
- **Shake too sensitive?** Adjust sensitivity in `lib/screens/home_screen.dart`
- **Widget button not working?** Make sure deep linking is configured (see WIDGET_SETUP.md)

## Need Help?

Check out `WIDGET_SETUP.md` for detailed setup instructions and troubleshooting.
