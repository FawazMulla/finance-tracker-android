# API Testing Guide

## Test if Google Sheets API is Working

### Method 1: Test from Browser

1. Open this URL in your browser (replace with your actual URL):
```
https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec?token=YOUR_TOKEN&action=fetch
```

2. You should see JSON response like:
```json
[
  {"id": "...", "date": "...", "amount": 123, "note": "..."},
  ...
]
```

### Method 2: Test from Command Line

```bash
# Test fetch
curl -X POST "YOUR_API_URL" \
  -d "token=YOUR_TOKEN" \
  -d "action=fetch"

# Test add transaction
curl -X POST "YOUR_API_URL" \
  -d "token=YOUR_TOKEN" \
  -d "action=add" \
  -d "id=test-123" \
  -d "date=2024-01-01T12:00:00.000Z" \
  -d "amount=100" \
  -d "note=Test transaction"
```

### Method 3: Test from Flutter App

Add this debug button to your home screen temporarily:

```dart
ElevatedButton(
  onPressed: () async {
    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      await provider.fetchTransactions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${provider.transactions.length} transactions')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  },
  child: Text('Test API'),
)
```

## Common Issues

### 1. "Received HTML instead of JSON"
**Problem:** Google Apps Script deployment permissions
**Solution:**
1. Open your Google Apps Script
2. Deploy → Manage deployments
3. Click edit (pencil icon)
4. Change "Who has access" to "Anyone"
5. Deploy new version

### 2. "No internet connection"
**Problem:** Device/emulator can't reach internet
**Solution:**
- Check WiFi/mobile data
- Test: `adb shell ping -c 3 google.com`
- Restart emulator if needed

### 3. "Request timed out"
**Problem:** Slow network or Google Sheets taking too long
**Solution:**
- Check internet speed
- Try again with better connection
- Reduce number of transactions in sheet

### 4. Transactions save locally but not to sheets
**Problem:** API call failing silently
**Solution:**
1. Check Flutter logs: `flutter logs | grep -i "api"`
2. Look for error messages
3. Verify API URL and token are correct

## Enable Debug Logging

The app already has debug logging enabled. Check console for:

```
API Request: add
Response status: 302
Redirect response status: 200
```

If you see errors, they'll show as:
```
Network error: SocketException: ...
API error: Exception: ...
```

## Verify Widget Transactions

To test if widget transactions are uploading:

1. Add transaction from widget
2. Check Flutter logs immediately
3. Look for "API Request: add"
4. Check Google Sheets for new row

If no API request appears, the transaction is only saved locally.

## Force Sync

To manually sync local transactions to Google Sheets:

1. Open the app
2. Pull down to refresh on home screen
3. This will fetch from API and show any sync issues

## Check Local Storage

Transactions are always saved locally first. To verify:

1. Add transaction
2. Close app completely
3. Reopen app
4. Transaction should still be there (from local storage)

This proves local storage works even if API sync fails.
