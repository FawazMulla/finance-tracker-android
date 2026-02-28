# Firebase Setup Guide - Complete Instructions

## 🎯 Connect Your App to Firebase

Follow these steps to enable Firebase Cloud Firestore backup in your Flutter app.

---

## Step 1: Install Dependencies

Open terminal in your project folder and run:

```bash
flutter pub get
```

This installs Firebase packages that were already added to your `pubspec.yaml`.

---

## Step 2: Create Firebase Project

1. Go to **https://console.firebase.google.com/**
2. Click **"Add project"**
3. Enter project name: **Finance Tracker**
4. Click **Continue**
5. Disable Google Analytics (optional)
6. Click **Create project**
7. Wait for project creation
8. Click **Continue**

---

## Step 3: Add Android App to Firebase

1. In Firebase Console, click the **Android icon** (or "Add app")
2. Enter Android package name: **`com.example.finance_tracker`**
3. Leave App nickname blank (optional)
4. Leave Debug signing certificate blank (for now)
5. Click **Register app**
6. Click **Download google-services.json**
7. **Important:** Replace the file at `android/app/google-services.json` with the downloaded file
8. Click **Next** → **Next** → **Continue to console**

---

## Step 4: Enable Cloud Firestore

1. In Firebase Console left menu, click **"Firestore Database"**
2. Click **"Create database"**
3. Select **"Start in test mode"** (for development)
4. Click **Next**
5. Choose a location closest to you (e.g., `us-central`, `europe-west`, `asia-south1`)
6. Click **Enable**
7. Wait for database creation (takes ~1 minute)

---

## Step 5: Configure Firestore Security Rules

1. In Firestore Database, click **"Rules"** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /backup_records/{document=**} {
      allow read, write: if true;
    }
  }
}
```

3. Click **Publish**

**Note:** These rules allow anyone to read/write. For production, add authentication.

---

## Step 6: Verify Android Build Configuration

**Good news!** The Android build files are already configured for Firebase. 

The configuration has been fixed to include proper repository definitions.

### `android/build.gradle.kts` ✅
Contains:
```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### `android/app/build.gradle.kts` ✅
Contains:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Firebase plugin
}
```

And at the bottom:
```kotlin
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}
```

**Configuration is complete!**

---

## Step 7: Run the App

Clean and rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

**First run may take longer** as it downloads Firebase dependencies.

---

## Step 8: Test Firebase Backup

### 8.1 Add a Transaction

1. Open the app
2. Tap **"New Transaction"**
3. Enter amount: `100`
4. Enter note: `Test transaction`
5. Tap **Save**

### 8.2 View Backup

1. Tap **"Backup"** tab in bottom navigation
2. You should see your transaction appear instantly
3. This confirms Firebase is working!

### 8.3 Verify in Firebase Console

1. Go to Firebase Console
2. Click **"Firestore Database"**
3. You should see a collection named **`backup_records`**
4. Click it to see your transaction data

---

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] Android app added to Firebase
- [ ] `google-services.json` downloaded and replaced
- [ ] Firestore database enabled
- [ ] Security rules published
- [ ] `flutter pub get` completed
- [ ] App runs without errors
- [ ] Transaction added successfully
- [ ] Backup tab shows transaction
- [ ] Firebase Console shows data in `backup_records`

---

## 🎉 Success!

Your app is now connected to Firebase! Every transaction is automatically backed up to Cloud Firestore.

### What Happens Now:

✅ **Add Transaction** → Saved to Google Sheets → Backed up to Firestore
✅ **Delete Transaction** → Removed from Google Sheets → Removed from Firestore
✅ **View Backups** → Real-time updates from Firestore
✅ **Offline Mode** → App still works, syncs when online

---

## 🔧 Troubleshooting

### Error: "google-services.json not found"

**Solution:** Make sure you replaced the file at `android/app/google-services.json` with the one downloaded from Firebase.

### Error: "FirebaseException: Permission denied"

**Solution:** Check Firestore security rules allow read/write access (Step 5).

### Error: "Failed to initialize Firebase"

**Solution:** 
1. Verify package name in `google-services.json` matches `com.example.finance_tracker`
2. Run `flutter clean && flutter pub get`
3. Rebuild the app

### Backup tab shows "No backup records"

**Solution:**
1. Add a transaction first
2. Check Firebase Console → Firestore Database
3. Look for `backup_records` collection
4. Check debug logs for errors

### App crashes on startup

**Solution:**
1. Check `google-services.json` is valid JSON
2. Verify Firebase project is active
3. Run `flutter clean && flutter pub get`
4. Check Android Studio logcat for specific error

---

## 📱 iOS Setup (Optional)

If you want to run on iOS:

1. In Firebase Console, click **Add app** → **iOS**
2. Enter iOS bundle ID: **`com.example.financeTracker`**
3. Download **`GoogleService-Info.plist`**
4. Replace file at `ios/Runner/GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Drag `GoogleService-Info.plist` into Runner folder
7. Run from Xcode or `flutter run`

---

## 🔒 Production Security (Important!)

Before releasing your app, update Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /backup_records/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Then add Firebase Authentication to your app.

---

## 📊 Monitor Your Backup

### Firebase Console:
- **Firestore Database** → See all backup records
- **Usage** → Monitor reads/writes
- **Rules** → Update security rules

### In App:
- **Backup Tab** → Real-time view of all backups
- **Home Screen** → Sync status indicator

---

## 💡 Key Points

- **Google Sheets** = Primary database (unchanged)
- **Firestore** = Backup database (automatic)
- **Backup is silent** = Failures don't break the app
- **Real-time sync** = Instant updates in Backup tab
- **Offline support** = App works without internet

---

## 🎓 What You've Accomplished

✅ Connected Flutter app to Firebase
✅ Enabled Cloud Firestore database
✅ Automatic backup for all transactions
✅ Real-time backup monitoring
✅ Production-ready architecture

Your app now has enterprise-grade cloud backup! 🚀
