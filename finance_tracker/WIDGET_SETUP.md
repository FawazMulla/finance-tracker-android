# Home Screen Widget & Shake Gesture Setup

## Features Added

### 1. Home Screen Widget
A home screen widget that displays:
- Current balance
- Quick "Add Transaction" button
- Auto-updates when transactions change

### 2. Shake Gesture
Shake your phone to instantly open the add transaction modal for quick access.

## Setup Instructions

### Install Dependencies
Run the following command to install the new packages:
```bash
flutter pub get
```

**Note for Windows users:** If you see a symlink warning, you can either:
- Enable Developer Mode: Run `start ms-settings:developers` and toggle Developer Mode ON
- Or ignore it - the app will still work fine

### Android Setup

1. The widget is already configured in the Android manifest
2. Build and install the app:
   ```bash
   flutter run
   # Or for release build:
   flutter build apk --release
   ```
3. Long-press on your home screen
4. Select "Widgets"
5. Find "Finance Tracker" widget
6. Drag it to your home screen

### Shake Gesture Permissions

The shake feature uses the device's accelerometer. No special permissions are needed - it works automatically!

### iOS Setup

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Add Widget Extension:
   - File → New → Target
   - Select "Widget Extension"
   - Name it "FinanceWidget"
   - Uncheck "Include Configuration Intent"
   - Click Finish

3. Replace the generated FinanceWidget.swift with the one in `ios/FinanceWidget/FinanceWidget.swift`

4. Add App Group:
   - Select Runner target → Signing & Capabilities
   - Click "+ Capability" → App Groups
   - Add group: `group.com.example.finance_tracker`
   - Repeat for FinanceWidget target

5. Build and run:
   ```bash
   flutter build ios
   ```

6. On your iOS device:
   - Long-press home screen
   - Tap "+" in top-left
   - Search "Finance Tracker"
   - Add the widget

## Usage

### Widget
- Tap the "Add Transaction" button on the widget to open the app and add a transaction
- The widget automatically updates when you add/delete transactions

### Shake Gesture
- Shake your phone while the app is open
- The add transaction modal will appear instantly
- Works from any screen in the app

## Customization

### Adjust Shake Sensitivity
In `lib/utils/shake_detector.dart` or when creating the detector in `lib/screens/home_screen.dart`, modify these parameters:
```dart
ShakeDetector.autoStart(
  minimumShakeCount: 2,        // Number of shakes required
  shakeSlopTimeMS: 500,        // Time window for shakes
  shakeThresholdGravity: 2.7,  // Sensitivity (lower = more sensitive)
);
```

### Widget Update Frequency
Android: Edit `android/app/src/main/res/xml/finance_widget_info.xml`
```xml
android:updatePeriodMillis="1800000"  <!-- 30 minutes in milliseconds -->
```

## Troubleshooting

### Widget not updating
- Make sure the app has been opened at least once
- Check that permissions are granted
- Try removing and re-adding the widget

### Shake not working
- The shake feature uses the accelerometer sensor
- Make sure you're testing on a physical device (won't work in emulator)
- Try adjusting the sensitivity parameters in `lib/utils/shake_detector.dart`
- Shake the phone 2-3 times quickly

### Deep linking not working
- Verify the URL scheme is registered in AndroidManifest.xml and Info.plist
- Check that the scheme is `financetracker://addtransaction`
