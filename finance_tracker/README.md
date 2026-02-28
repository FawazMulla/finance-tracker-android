# 💰 Finance Tracker

A modern, feature-rich Flutter application for tracking personal finances with dual database architecture - Google Sheets as primary storage and Firebase Cloud Firestore as automatic backup.

![Flutter](https://img.shields.io/badge/Flutter-3.10.7-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.7-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-Private-red)

---

## 📱 Overview

Finance Tracker is a comprehensive personal finance management application built with Flutter. It combines the simplicity of Google Sheets with the power of Firebase Cloud Firestore to provide a robust, reliable, and user-friendly expense tracking solution.

### Key Highlights

- 📊 **Dual Database Architecture**: Google Sheets (primary) + Firebase Firestore (backup)
- 🔄 **Real-time Synchronization**: Instant updates across all platforms
- 📈 **Visual Analytics**: Beautiful charts and statistics
- 🏠 **Home Widget**: Quick access from your home screen
- 🎨 **Modern UI**: Material Design 3 with dark theme
- 💾 **Offline Support**: Works without internet, syncs when online
- 🔒 **Data Safety**: Automatic cloud backup for all transactions

---

## ✨ Features

### Core Features

#### 1. Transaction Management
- ✅ Add income and expense transactions
- ✅ Edit transaction details
- ✅ Delete transactions with swipe gesture
- ✅ Add notes to transactions
- ✅ Automatic date/time tracking
- ✅ Real-time balance calculation

#### 2. Dual Database System
- 📝 **Google Sheets** - Primary database
  - Direct API integration
  - Full CRUD operations
  - Accessible via web browser
  - Easy data export
  
- ☁️ **Firebase Firestore** - Backup database
  - Automatic silent backup
  - Real-time synchronization
  - Cloud-based storage
  - Independent backup view

#### 3. Home Widget
- 📱 Quick balance view on home screen
- 🔢 Transaction count display
- ➕ Quick add transaction button
- 🔄 Auto-updates on data changes
- 🎯 Deep linking to app

#### 4. Statistics & Analytics
- 📊 Income vs Expense charts
- 📈 Monthly spending trends
- 💹 Category-wise breakdown
- 📉 Visual data representation
- 🎨 Interactive FL Chart graphs

#### 5. Transaction History
- 📜 Complete transaction list
- 🔍 Search and filter
- 📅 Date-wise organization
- 💰 Amount sorting
- 📝 Note preview

#### 6. Backup Management
- ☁️ Real-time backup view
- 🔄 Live data streaming
- 👁️ Backup record details
- 🗑️ Individual backup deletion
- ✅ Sync status indicators

---

## 🏗️ Architecture

### Project Structure

```
finance_tracker/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── models/
│   │   └── transaction.dart               # Transaction data model
│   ├── providers/
│   │   └── transaction_provider.dart      # State management
│   ├── screens/
│   │   ├── home_screen.dart              # Main dashboard
│   │   ├── history_screen.dart           # Transaction history
│   │   ├── stats_screen.dart             # Analytics & charts
│   │   └── backup_screen.dart            # Firebase backup view
│   ├── services/
│   │   ├── api_service.dart              # Google Sheets API
│   │   ├── storage_service.dart          # Local storage
│   │   ├── widget_service.dart           # Home widget
│   │   └── firestore_backup_service.dart # Firebase backup
│   ├── widgets/
│   │   ├── add_transaction_modal.dart    # Add transaction UI
│   │   ├── quick_add_transaction_modal.dart
│   │   └── transaction_item.dart         # Transaction list item
│   └── utils/                            # Utility functions
├── android/                              # Android native code
│   ├── app/
│   │   ├── src/main/kotlin/             # Widget provider
│   │   └── google-services.json         # Firebase config
│   └── build.gradle.kts                 # Build configuration
├── ios/                                  # iOS native code
├── assets/                               # App assets
└── pubspec.yaml                          # Dependencies
```

### Technology Stack

**Frontend:**
- Flutter 3.10.7
- Dart 3.10.7
- Material Design 3

**State Management:**
- Provider pattern

**Backend/Storage:**
- Google Sheets API (Primary)
- Firebase Cloud Firestore (Backup)
- SharedPreferences (Local cache)

**Charts & Visualization:**
- FL Chart

**Native Features:**
- Home Widget (Android)
- App Shortcuts (Android)

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.10.7 or higher)
  ```bash
  flutter --version
  ```

- **Dart SDK** (3.10.7 or higher)
  ```bash
  dart --version
  ```

- **Android Studio** or **VS Code** with Flutter extensions

- **Git** for version control

- **Google Account** for Sheets API

- **Firebase Account** for Firestore

### Installation

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd finance_tracker
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Configure Google Sheets API

1. Create a Google Apps Script web app
2. Deploy as web app with "Anyone" access
3. Copy the deployment URL
4. Update `lib/services/api_service.dart`:
   ```dart
   static const String apiUrl = "YOUR_GOOGLE_APPS_SCRIPT_URL";
   static const String apiToken = "YOUR_API_TOKEN";
   ```

#### 4. Configure Firebase

Follow the detailed guide in `FIREBASE_SETUP_GUIDE.md`:

1. Create Firebase project
2. Add Android app
3. Download `google-services.json`
4. Place in `android/app/`
5. Enable Cloud Firestore
6. Update security rules

#### 5. Run the App

```bash
flutter run
```

For release build:
```bash
flutter build apk --release
```

---

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.5+1
  
  # Networking
  http: ^1.6.0
  
  # Local Storage
  shared_preferences: ^2.5.4
  
  # Firebase
  firebase_core: ^3.8.1
  cloud_firestore: ^5.6.1
  
  # Charts
  fl_chart: ^1.1.1
  
  # Utilities
  intl: ^0.20.2
  uuid: ^4.5.2
  
  # Home Widget
  home_widget: ^0.7.0
  
  # UI
  cupertino_icons: ^1.0.8
```

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.13.1
```

---

## 🎨 Features in Detail

### 1. Home Screen

The main dashboard provides:
- Current balance display with animation
- Income/Expense summary cards
- Recent transactions list (last 5)
- Quick add transaction button
- Pull-to-refresh functionality
- Sync status indicator
- Bottom navigation

### 2. Transaction Management

**Add Transaction:**
- Amount input with validation
- Note/description field
- Automatic date/time
- Income/Expense toggle
- Instant local save
- Background sync to cloud

**Edit Transaction:**
- Modify amount
- Update notes
- Change date
- Sync changes

**Delete Transaction:**
- Swipe-to-delete gesture
- Confirmation dialog
- Undo option
- Sync deletion

### 3. Statistics Screen

Visual analytics including:
- Income vs Expense pie chart
- Monthly trend line chart
- Category breakdown
- Total income/expense
- Average transaction value
- Transaction count

### 4. History Screen

Complete transaction history with:
- Chronological list
- Search functionality
- Filter by date range
- Sort by amount/date
- Detailed view
- Bulk operations

### 5. Backup Screen

Firebase backup management:
- Real-time data stream
- Live updates
- Backup record details
- Individual deletion
- Sync status
- Error handling

### 6. Home Widget

Android home screen widget featuring:
- Current balance display
- Transaction count
- Quick add button
- Auto-refresh
- Deep linking
- Material You design

---

## 🔧 Configuration

### Google Sheets Setup

The app uses Google Apps Script as a backend API for Google Sheets.

**Quick Setup:**

1. Create a new Google Sheet named "Finance Tracker"
2. Add sheet named "Transactions" with headers: `ID | Date | Amount | Note`
3. Go to **Extensions** → **Apps Script**
4. Copy code from `google-apps-script/Code.gs`
5. Update `SECRET_TOKEN` with your own secure token
6. Deploy as Web App (Execute as: Me, Access: Anyone)
7. Copy deployment URL
8. Update `lib/services/api_service.dart`:

```dart
static const String apiUrl = "YOUR_WEB_APP_URL";
static const String apiToken = "YOUR_SECRET_TOKEN";
```

**Detailed Instructions:** See `google-apps-script/README.md`

**Complete Script:** Available in `google-apps-script/Code.gs`

**API Endpoints:**
- `fetch` - Get all transactions
- `add` - Add new transaction
- `update` - Update existing transaction
- `delete` - Delete transaction

**Example Apps Script:**

```javascript
function doPost(e) {
  try {
    const token = e.parameter.token;
    if (token !== SECRET_TOKEN) {
      return jsonResponse({ error: "Unauthorized" });
    }
    
    const action = e.parameter.action;
    const sheet = SpreadsheetApp.getActive().getSheetByName(SHEET_NAME);
    
    switch (action) {
      case "fetch":
        return fetchAll(sheet);
      case "add":
        return addTransaction(sheet, e.parameter);
      case "update":
        return updateTransaction(sheet, e.parameter);
      case "delete":
        return deleteTransaction(sheet, e.parameter.id);
      default:
        return jsonResponse({ error: "Invalid action" });
    }
  } catch (error) {
    return jsonResponse({ error: error.toString() });
  }
}

function jsonResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
```

See the complete implementation in `google-apps-script/Code.gs`.

### Firebase Setup

See `FIREBASE_SETUP_GUIDE.md` for complete instructions.

**Quick Setup:**
1. Create project at https://console.firebase.google.com/
2. Add Android app
3. Download `google-services.json`
4. Enable Firestore
5. Set security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /backup_records/{document=**} {
      allow read, write: if true; // Development
      // For production: if request.auth != null;
    }
  }
}
```

---

## 🎯 Usage

### Adding a Transaction

1. Tap **"New Transaction"** button
2. Enter amount (positive for income, negative for expense)
3. Add optional note
4. Tap **"Save"**
5. Transaction syncs to Google Sheets
6. Automatic backup to Firebase

### Viewing Statistics

1. Navigate to **"Stats"** tab
2. View income/expense charts
3. Analyze spending patterns
4. Check monthly trends

### Managing Backups

1. Navigate to **"Backup"** tab
2. View all backup records
3. Tap record for details
4. Delete individual backups if needed

### Using Home Widget

1. Long-press home screen
2. Add **"Finance Tracker"** widget
3. View balance at a glance
4. Tap to open app
5. Use quick add button

---

## 🔒 Security & Privacy

### Data Storage

- **Local**: Encrypted SharedPreferences
- **Google Sheets**: Secured with API token
- **Firebase**: Firestore security rules

### Best Practices

1. **Never commit** `google-services.json` to public repos
2. **Use environment variables** for API keys
3. **Enable Firebase Authentication** for production
4. **Update security rules** before release
5. **Implement user authentication**

### Production Security

Update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /backup_records/{document=**} {
      allow read, write: if request.auth != null 
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 🐛 Troubleshooting

### Common Issues

**1. Build Failed - Google Services**
```
Error: google-services.json not found
```
**Solution:** Download from Firebase Console and place in `android/app/`

**2. Firebase Permission Denied**
```
Error: PERMISSION_DENIED
```
**Solution:** Update Firestore security rules to allow access

**3. Google Sheets Sync Failed**
```
Error: Invalid token
```
**Solution:** Verify API token in `api_service.dart` matches script

**4. Widget Not Updating**
```
Widget shows old data
```
**Solution:** Check widget service initialization in `main.dart`

### Debug Mode

Enable debug logging:
```dart
// In main.dart
void main() {
  debugPrint('Debug mode enabled');
  // ... rest of initialization
}
```

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | API 21+ |
| iOS | ⚠️ Partial | Firebase config needed |
| Web | ❌ Not Supported | Native features required |
| Windows | ❌ Not Supported | Mobile-first design |
| macOS | ❌ Not Supported | Mobile-first design |
| Linux | ❌ Not Supported | Mobile-first design |

---

## 🚧 Roadmap

### Planned Features

- [ ] User authentication (Firebase Auth)
- [ ] Multi-currency support
- [ ] Budget planning
- [ ] Recurring transactions
- [ ] Category management
- [ ] Export to PDF/CSV
- [ ] Biometric authentication
- [ ] Cloud sync settings
- [ ] Dark/Light theme toggle
- [ ] Multiple accounts
- [ ] Bill reminders
- [ ] Receipt scanning

### Future Enhancements

- [ ] iOS widget support
- [ ] Web dashboard
- [ ] Desktop apps
- [ ] Shared accounts
- [ ] Financial insights AI
- [ ] Investment tracking

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for new features

---

## 📄 License

This project is private and proprietary. All rights reserved.

---

## 👨‍💻 Author

**Finance Tracker Team**

---

## 📞 Support

For issues and questions:
- Check `FIREBASE_SETUP_GUIDE.md` for Firebase setup
- Review `TROUBLESHOOTING.md` for common issues
- Open an issue on GitHub

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for cloud infrastructure
- Google Sheets for flexible data storage
- FL Chart for beautiful visualizations
- Material Design for UI guidelines

---

## 📊 Project Stats

- **Lines of Code:** ~3,000+
- **Screens:** 4 main screens
- **Services:** 4 backend services
- **Widgets:** 3 custom widgets
- **Dependencies:** 12 packages
- **Platforms:** Android (primary)

---

## 🔄 Version History

### v1.0.0 (Current)
- ✅ Initial release
- ✅ Google Sheets integration
- ✅ Firebase Firestore backup
- ✅ Home widget support
- ✅ Statistics & charts
- ✅ Transaction management
- ✅ Offline support

---

## 📚 Documentation

- `FIREBASE_SETUP_GUIDE.md` - Firebase configuration
- `FEATURES.md` - Detailed feature list
- `CHANGELOG.md` - Version history
- `TROUBLESHOOTING.md` - Common issues

---

**Made with ❤️ using Flutter**
