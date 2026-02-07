# Troubleshooting Guide

## 🔧 Common Issues and Solutions

### 1. Google Fonts Error (fonts.gstatic.com)

**Error Message:**
```
Failed to load font with url https://fonts.gstatic.com/...
SocketException: Failed host lookup: 'fonts.gstatic.com'
```

**Why This Happens:**
- Emulator/device doesn't have internet access
- Network restrictions blocking Google Fonts
- DNS resolution issues

**Solution:**
✅ **Already Fixed!** The app now:
- Disables runtime font fetching (`GoogleFonts.config.allowRuntimeFetching = false`)
- Falls back to system fonts if Google Fonts fail
- Handles errors gracefully without crashing

**What You'll See:**
- App uses system default font instead of Inter
- No more error messages
- UI still looks good, just slightly different font

---

### 2. Transactions Not Fetching from Google Sheets

**Symptoms:**
- App shows "No transactions yet"
- Refresh doesn't load data
- Network errors in console

**Possible Causes & Solutions:**

#### A. No Internet Connection
**Check:**
```bash
# On emulator, check if internet works
adb shell ping -c 3 google.com
```

**Fix for Emulator:**
1. Restart emulator
2. Check host machine internet
3. Try cold boot: AVD Manager → Cold Boot Now

**Fix for Physical Device:**
1. Enable WiFi/Mobile Data
2. Check airplane mode is off
3. Try different network

#### B. Google Apps Script Not Deployed
**Check:**
1. Open your Google Apps Script
2. Go to Deploy → Manage deployments
3. Verify deployment exists

**Fix:**
1. Click "New deployment"
2. Type: Web app
3. Execute as: Me
4. Who has access: **Anyone**
5. Click Deploy
6. Copy new URL and update in `lib/services/api_service.dart`

#### C. Wrong API URL or Token
**Check:**
```dart
// In lib/services/api_service.dart
static const String apiUrl = "YOUR_DEPLOYMENT_URL";
static const String apiToken = "YOUR_TOKEN";
```

**Fix:**
1. Get correct URL from Google Apps Script deployment
2. Update `apiUrl` in api_service.dart
3. Ensure token matches your script

#### D. Network Timeout
**Symptoms:**
- "Request timed out" error
- Takes 30+ seconds

**Fix:**
1. Check internet speed
2. Try again with better connection
3. Increase timeout in api_service.dart if needed

---

### 3. UI Looks Different on Emulator vs Phone

**Why This Happens:**
1. **Font Loading**: Emulator might not load Google Fonts, phone might
2. **Screen Density**: Different DPI settings
3. **Android Version**: Different Material Design implementations
4. **Network**: Emulator might not have internet for fonts

**Solutions:**

#### Make UI Consistent:
✅ **Already Fixed!** The app now:
- Uses fallback fonts when Google Fonts unavailable
- Handles font loading errors gracefully
- Maintains consistent layout regardless of font

#### If Still Different:
1. **Check both have internet** - Fonts load differently
2. **Use same Android version** - Material 3 varies by version
3. **Check DPI settings** - Emulator settings → Advanced → Scale

---

### 4. Widget Not Updating

**Symptoms:**
- Widget shows old balance
- Widget shows ₹0.00

**Solutions:**

#### A. App Not Opened Yet
**Fix:** Open the app once to initialize widget

#### B. Widget Data Not Saved
**Check logs for:**
```
Error updating widget: ...
```

**Fix:**
1. Open app
2. Add a transaction
3. Check widget updates

#### C. Widget Needs Refresh
**Fix:**
1. Remove widget from home screen
2. Re-add widget
3. Open app once

---

### 5. Shake Gesture Not Working

**Symptoms:**
- Shaking phone does nothing
- No modal appears

**Solutions:**

#### A. Testing on Emulator
**Problem:** Emulators don't have accelerometer simulation
**Fix:** Test on physical device only

#### B. Shake Not Detected
**Fix:** Shake harder/faster (2-3 quick shakes)

#### C. Sensitivity Too High
**Fix:** Adjust in `lib/screens/home_screen.dart`:
```dart
shakeThresholdGravity: 2.7,  // Lower = more sensitive (try 2.0)
```

---

### 6. App Crashes on Launch

**Check Logs:**
```bash
flutter logs
```

**Common Causes:**

#### A. Missing Dependencies
**Fix:**
```bash
flutter clean
flutter pub get
flutter run
```

#### B. Build Issues
**Fix:**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

#### C. Widget Provider Error
**Check:** AndroidManifest.xml has widget receiver
**Fix:** Ensure FinanceWidgetProvider.kt exists

---

### 7. Deep Linking Not Working

**Symptoms:**
- Widget buttons don't open app
- Tapping widget does nothing

**Solutions:**

#### A. URL Scheme Not Registered
**Check:** AndroidManifest.xml has:
```xml
<data android:scheme="financetracker" />
```

**Fix:** Already in manifest, rebuild app

#### B. App Not Installed
**Fix:** Install app first, then add widget

#### C. Wrong Package Name
**Check:** Intent uses correct package
**Fix:** Verify in FinanceWidgetProvider.kt

---

## 🔍 Debugging Tips

### Enable Debug Logging

**Already enabled!** Check console for:
- `API Request: fetch`
- `Response status: 200`
- `Network error: ...`
- `Error fetching transactions: ...`

### Check Network Connectivity

```bash
# Test from device
adb shell ping -c 3 script.google.com

# Check if app has internet permission
adb shell dumpsys package com.example.finance_tracker | grep permission
```

### View App Logs

```bash
# Real-time logs
flutter logs

# Filter for errors
flutter logs | grep -i error

# Filter for API calls
flutter logs | grep -i "api"
```

### Test API Manually

```bash
# Test Google Apps Script
curl -X POST "YOUR_API_URL" \
  -d "token=YOUR_TOKEN" \
  -d "action=fetch"
```

---

## 📱 Platform-Specific Issues

### Android Emulator

**Internet Not Working:**
1. Restart emulator
2. Check DNS: Settings → Network → Private DNS → Off
3. Try different emulator image

**Slow Performance:**
1. Increase RAM in AVD settings
2. Enable hardware acceleration
3. Use x86_64 image

### Physical Device

**USB Debugging:**
1. Enable Developer Options
2. Enable USB Debugging
3. Trust computer

**Network Issues:**
1. Check WiFi/Mobile Data
2. Disable VPN if active
3. Check firewall settings

---

## 🆘 Still Having Issues?

### Collect Information

1. **Flutter Doctor:**
```bash
flutter doctor -v
```

2. **App Logs:**
```bash
flutter logs > app_logs.txt
```

3. **Device Info:**
- Android version
- Device model
- Emulator or physical device

### Quick Fixes to Try

1. **Clean Build:**
```bash
flutter clean
flutter pub get
flutter run
```

2. **Restart Everything:**
- Close emulator/disconnect device
- Restart Android Studio/VS Code
- Restart computer if needed

3. **Check Basics:**
- Internet connection working?
- Google Sheets accessible in browser?
- App has internet permission?

---

## ✅ Verification Checklist

After fixing issues, verify:

- [ ] App launches without errors
- [ ] UI looks correct (fonts loaded or fallback working)
- [ ] Can add transactions
- [ ] Transactions save locally
- [ ] Widget displays on home screen
- [ ] Widget shows correct balance
- [ ] Widget buttons open app
- [ ] Shake gesture works (on physical device)
- [ ] Transactions sync to Google Sheets (if internet available)
- [ ] App works offline with local storage

---

## 📚 Related Documentation

- **QUICK_START.md** - Getting started guide
- **WIDGET_SETUP.md** - Widget configuration
- **WIDGET_GUIDE.md** - Widget usage instructions
- **CHANGELOG.md** - Recent changes and fixes
