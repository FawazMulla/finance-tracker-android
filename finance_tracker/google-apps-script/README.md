# Google Apps Script Setup Guide

This guide will help you set up the Google Apps Script backend for the Finance Tracker app.

---

## 📋 Prerequisites

- Google Account
- Access to Google Sheets
- Access to Google Apps Script

---

## 🚀 Setup Instructions

### Step 1: Create Google Sheet

1. Go to [Google Sheets](https://sheets.google.com)
2. Click **"Blank"** to create a new spreadsheet
3. Name it **"Finance Tracker"**
4. Rename the first sheet to **"Transactions"**

### Step 2: Add Headers

In the first row, add these headers:

| A | B | C | D |
|---|---|---|---|
| ID | Date | Amount | Note |

### Step 3: Open Apps Script Editor

1. In your Google Sheet, click **Extensions** → **Apps Script**
2. Delete any existing code in the editor
3. Copy the entire content from `Code.gs` file
4. Paste it into the Apps Script editor

### Step 4: Configure Security Token

1. In the code, find this line:
   ```javascript
   const SECRET_TOKEN = "694ec953e60c832280e4316f7d02b261";
   ```

2. **IMPORTANT:** Change this to your own secure token
   - Use a random string generator
   - Make it at least 32 characters
   - Keep it secret!

3. Example:
   ```javascript
   const SECRET_TOKEN = "your-super-secret-token-here-12345";
   ```

### Step 5: Save the Script

1. Click the **disk icon** or press `Ctrl+S` (Windows) / `Cmd+S` (Mac)
2. Name your project: **"Finance Tracker API"**
3. Click **OK**

### Step 6: Test the Script (Optional)

1. In the Apps Script editor, select `testSheetSetup` from the function dropdown
2. Click **Run** (▶️ button)
3. Authorize the script when prompted
4. Check the **Execution log** for results

### Step 7: Deploy as Web App

1. Click **Deploy** → **New deployment**
2. Click the gear icon ⚙️ next to "Select type"
3. Choose **Web app**
4. Configure deployment:
   - **Description:** Finance Tracker API v1
   - **Execute as:** Me (your email)
   - **Who has access:** Anyone
5. Click **Deploy**
6. Click **Authorize access**
7. Choose your Google account
8. Click **Advanced** → **Go to Finance Tracker API (unsafe)**
9. Click **Allow**
10. **Copy the Web App URL** (you'll need this!)

### Step 8: Update Flutter App

1. Open your Flutter project
2. Go to `lib/services/api_service.dart`
3. Update these constants:

```dart
static const String apiUrl = "YOUR_WEB_APP_URL_HERE";
static const String apiToken = "YOUR_SECRET_TOKEN_HERE";
```

4. Replace:
   - `YOUR_WEB_APP_URL_HERE` with the URL from Step 7
   - `YOUR_SECRET_TOKEN_HERE` with the token from Step 4

### Step 9: Test the Connection

1. Run your Flutter app
2. Try adding a transaction
3. Check your Google Sheet - the transaction should appear!

---

## 🧪 Testing

### Test API Connectivity

Open this URL in your browser (replace with your values):

```
YOUR_WEB_APP_URL?token=YOUR_SECRET_TOKEN
```

You should see:
```json
{
  "message": "Finance Tracker API is working",
  "timestamp": "2024-02-20T10:30:00.000Z",
  "sheetName": "Transactions",
  "status": "OK"
}
```

### Test from Apps Script Editor

Run these test functions:

1. **testSheetSetup** - Verifies sheet configuration
2. **testAddTransaction** - Adds a sample transaction

---

## 📊 Sheet Structure

Your Google Sheet should look like this:

| ID | Date | Amount | Note |
|----|------|--------|------|
| uuid-1234 | 2024-02-20T10:30:00.000Z | 100.50 | Grocery shopping |
| uuid-5678 | 2024-02-20T15:45:00.000Z | -50.00 | Coffee |

**Column Details:**
- **ID:** Unique identifier (UUID from Flutter app)
- **Date:** ISO 8601 format timestamp
- **Amount:** Positive for income, negative for expense
- **Note:** Transaction description

---

## 🔧 API Reference

### Endpoints

The script supports these actions via POST requests:

#### 1. Fetch All Transactions
```
POST YOUR_WEB_APP_URL
Body: token=YOUR_TOKEN&action=fetch
```

Response:
```json
[
  {
    "id": "uuid-1234",
    "date": "2024-02-20T10:30:00.000Z",
    "amount": 100.50,
    "note": "Grocery shopping"
  }
]
```

#### 2. Add Transaction
```
POST YOUR_WEB_APP_URL
Body: token=YOUR_TOKEN&action=add&id=uuid-1234&date=2024-02-20T10:30:00.000Z&amount=100.50&note=Grocery
```

Response:
```json
{
  "success": true,
  "message": "Transaction added"
}
```

#### 3. Update Transaction
```
POST YOUR_WEB_APP_URL
Body: token=YOUR_TOKEN&action=update&id=uuid-1234&date=2024-02-20T10:30:00.000Z&amount=150.00&note=Updated
```

Response:
```json
{
  "success": true,
  "message": "Transaction updated"
}
```

#### 4. Delete Transaction
```
POST YOUR_WEB_APP_URL
Body: token=YOUR_TOKEN&action=delete&id=uuid-1234
```

Response:
```json
{
  "success": true,
  "message": "Transaction deleted"
}
```

---

## 🔒 Security

### Best Practices

1. **Never share your SECRET_TOKEN**
2. **Don't commit the token to public repositories**
3. **Use environment variables in production**
4. **Regularly rotate your token**
5. **Monitor your Google Sheet for unauthorized access**

### Token Security

Generate a secure token:
```javascript
// Use a random string generator
// Example: https://www.random.org/strings/
const SECRET_TOKEN = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6";
```

---

## 🐛 Troubleshooting

### Error: "Unauthorized"
**Cause:** Token mismatch
**Solution:** Verify token in both Apps Script and Flutter app match exactly

### Error: "Sheet not found"
**Cause:** Sheet name doesn't match
**Solution:** Ensure sheet is named exactly "Transactions"

### Error: "Script has not been published"
**Cause:** Deployment not completed
**Solution:** Complete Step 7 (Deploy as Web App)

### Error: "Permission denied"
**Cause:** Script not authorized
**Solution:** Re-authorize in Step 7

### Transactions not appearing
**Cause:** Wrong Web App URL
**Solution:** Copy the correct URL from deployment

---

## 🔄 Updating the Script

If you need to update the script:

1. Make changes in Apps Script editor
2. Save the changes
3. Click **Deploy** → **Manage deployments**
4. Click **Edit** (pencil icon)
5. Change **Version** to "New version"
6. Add description of changes
7. Click **Deploy**
8. **URL remains the same** - no need to update Flutter app

---

## 📈 Monitoring

### View Execution Logs

1. In Apps Script editor, click **Executions** (clock icon)
2. View all API calls and errors
3. Click on any execution to see details

### Check Sheet Activity

1. In Google Sheet, click **File** → **Version history**
2. See all changes made by the script

---

## 💡 Tips

- Keep your Google Sheet organized
- Don't manually edit the ID column
- Use the Flutter app for all CRUD operations
- Backup your sheet regularly
- Monitor API usage in Apps Script dashboard

---

## 🎓 Advanced Features

### Add Data Validation

Protect your sheet from manual errors:

1. Select column A (ID)
2. **Data** → **Data validation**
3. Criteria: **Text contains** "uuid"

### Add Conditional Formatting

Highlight income/expenses:

1. Select column C (Amount)
2. **Format** → **Conditional formatting**
3. Format cells if: **Greater than** 0 → Green
4. Add another rule: **Less than** 0 → Red

### Create Backup Sheet

Automatically backup data:

1. Add this function to Code.gs:
```javascript
function createDailyBackup() {
  const ss = SpreadsheetApp.getActive();
  const sheet = ss.getSheetByName(SHEET_NAME);
  const backup = sheet.copyTo(ss);
  backup.setName("Backup_" + new Date().toISOString().split('T')[0]);
}
```

2. Set up a daily trigger:
   - **Triggers** → **Add Trigger**
   - Function: `createDailyBackup`
   - Event: Time-driven, Day timer

---

## 📞 Support

If you encounter issues:
1. Check the Troubleshooting section
2. Review execution logs in Apps Script
3. Verify sheet structure matches requirements
4. Test API connectivity with browser

---

**Your Google Apps Script backend is now ready!** 🎉
