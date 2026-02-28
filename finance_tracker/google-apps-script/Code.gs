/**
 * Finance Tracker - Google Apps Script Backend
 * 
 * This script provides a REST API for the Finance Tracker Flutter app
 * to perform CRUD operations on Google Sheets.
 * 
 * Setup Instructions:
 * 1. Create a new Google Sheet
 * 2. Name the first sheet "Transactions"
 * 3. Add headers: ID | Date | Amount | Note
 * 4. Go to Extensions > Apps Script
 * 5. Copy this code into Code.gs
 * 6. Update SECRET_TOKEN with your own secure token
 * 7. Deploy as Web App (Execute as: Me, Access: Anyone)
 * 8. Copy the deployment URL to your Flutter app
 */

// ============================================
// CONFIGURATION
// ============================================

// IMPORTANT: Change this to your own secure token
const SECRET_TOKEN = "694ec953e60c832280e4316f7d02b261";

// Sheet name where transactions are stored
const SHEET_NAME = "Transactions";

// ============================================
// MAIN HANDLERS
// ============================================

/**
 * Handles POST requests from the Flutter app
 * Supports actions: fetch, add, update, delete
 */
function doPost(e) {
  try {
    // Log the incoming request for debugging
    console.log('Received POST request:', e);
    
    // Verify authentication token
    const token = e.parameter.token;
    if (token !== SECRET_TOKEN) {
      return jsonResponse({ error: "Unauthorized" });
    }
    
    // Get the requested action
    const action = e.parameter.action;
    console.log('Action:', action);
    
    // Get the Transactions sheet
    const sheet = SpreadsheetApp.getActive().getSheetByName(SHEET_NAME);
    if (!sheet) {
      return jsonResponse({ 
        error: "Sheet not found. Please create a sheet named 'Transactions'" 
      });
    }
    
    // Route to appropriate handler based on action
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
        return jsonResponse({ error: "Invalid action: " + action });
    }
    
  } catch (error) {
    console.error('Error in doPost:', error);
    return jsonResponse({ error: "Server error: " + error.toString() });
  }
}

/**
 * Handles GET requests - used for testing API connectivity
 */
function doGet(e) {
  try {
    // Verify authentication token
    const token = e.parameter.token;
    if (token !== SECRET_TOKEN) {
      return jsonResponse({ error: "Unauthorized" });
    }
    
    // Return API status
    return jsonResponse({ 
      message: "Finance Tracker API is working",
      timestamp: new Date().toISOString(),
      sheetName: SHEET_NAME,
      status: "OK"
    });
    
  } catch (error) {
    console.error('Error in doGet:', error);
    return jsonResponse({ error: error.toString() });
  }
}

// ============================================
// CRUD OPERATIONS
// ============================================

/**
 * Fetch all transactions from the sheet
 * Returns array of transaction objects
 */
function fetchAll(sheet) {
  try {
    const range = sheet.getDataRange();
    const numRows = range.getNumRows();
    
    console.log('Sheet has', numRows, 'rows');
    
    // Check if sheet is empty or has only header
    if (numRows <= 1) {
      return jsonResponse([]);
    }
    
    const rows = range.getValues();
    console.log('Raw rows:', rows);
    
    // Remove header row
    rows.shift();
    
    // Convert rows to transaction objects
    const transactions = rows
      .filter(row => row[0]) // Filter out empty rows
      .map(row => ({
        id: row[0] ? row[0].toString() : '',
        date: row[1] ? row[1].toString() : new Date().toISOString(),
        amount: Number(row[2]) || 0,
        note: row[3] ? row[3].toString() : ''
      }));
    
    console.log('Processed transactions:', transactions);
    return jsonResponse(transactions);
    
  } catch (error) {
    console.error('Error in fetchAll:', error);
    return jsonResponse({ error: "Failed to fetch data: " + error.toString() });
  }
}

/**
 * Add a new transaction to the sheet
 * Params: id, date, amount, note
 */
function addTransaction(sheet, params) {
  try {
    console.log('Adding transaction:', params);
    
    // Prepare row data
    const row = [
      params.id || '',
      params.date || new Date().toISOString(),
      Number(params.amount) || 0,
      params.note || ''
    ];
    
    console.log('Adding row:', row);
    
    // Append to sheet
    sheet.appendRow(row);
    
    return jsonResponse({ 
      success: true, 
      message: "Transaction added" 
    });
    
  } catch (error) {
    console.error('Error in addTransaction:', error);
    return jsonResponse({ 
      error: "Failed to add transaction: " + error.toString() 
    });
  }
}

/**
 * Update an existing transaction
 * Params: id, date, amount, note
 */
function updateTransaction(sheet, params) {
  try {
    console.log('Updating transaction:', params);
    
    const rows = sheet.getDataRange().getValues();
    
    // Find the row with matching ID
    for (let i = 1; i < rows.length; i++) {
      if (rows[i][0] && rows[i][0].toString() === params.id) {
        // Update the row (skip ID column)
        sheet.getRange(i + 1, 2, 1, 3).setValues([[
          params.date || new Date().toISOString(),
          Number(params.amount) || 0,
          params.note || ""
        ]]);
        
        return jsonResponse({ 
          success: true, 
          message: "Transaction updated" 
        });
      }
    }
    
    return jsonResponse({ error: "Transaction not found" });
    
  } catch (error) {
    console.error('Error in updateTransaction:', error);
    return jsonResponse({ 
      error: "Failed to update transaction: " + error.toString() 
    });
  }
}

/**
 * Delete a transaction by ID
 * Params: id
 */
function deleteTransaction(sheet, id) {
  try {
    console.log('Deleting transaction:', id);
    
    const rows = sheet.getDataRange().getValues();
    
    // Find and delete the row with matching ID
    for (let i = 1; i < rows.length; i++) {
      if (rows[i][0] && rows[i][0].toString() === id) {
        sheet.deleteRow(i + 1);
        
        return jsonResponse({ 
          success: true, 
          message: "Transaction deleted" 
        });
      }
    }
    
    return jsonResponse({ error: "Transaction not found" });
    
  } catch (error) {
    console.error('Error in deleteTransaction:', error);
    return jsonResponse({ 
      error: "Failed to delete transaction: " + error.toString() 
    });
  }
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

/**
 * Create a JSON response
 * Properly formats data as JSON with correct MIME type
 */
function jsonResponse(data) {
  const output = ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
  
  return output;
}

// ============================================
// TESTING FUNCTIONS (Optional)
// ============================================

/**
 * Test function to verify sheet setup
 * Run this from Apps Script editor to test
 */
function testSheetSetup() {
  const sheet = SpreadsheetApp.getActive().getSheetByName(SHEET_NAME);
  
  if (!sheet) {
    Logger.log("ERROR: Sheet '" + SHEET_NAME + "' not found!");
    Logger.log("Please create a sheet named 'Transactions'");
    return;
  }
  
  Logger.log("✓ Sheet found: " + SHEET_NAME);
  
  const headers = sheet.getRange(1, 1, 1, 4).getValues()[0];
  Logger.log("Headers: " + headers.join(" | "));
  
  const numRows = sheet.getDataRange().getNumRows();
  Logger.log("Total rows: " + numRows);
  
  if (numRows > 1) {
    Logger.log("Sample data:");
    const sampleData = sheet.getRange(2, 1, Math.min(3, numRows - 1), 4).getValues();
    sampleData.forEach((row, index) => {
      Logger.log("Row " + (index + 2) + ": " + row.join(" | "));
    });
  }
}

/**
 * Test function to add sample transaction
 * Run this from Apps Script editor to test
 */
function testAddTransaction() {
  const sheet = SpreadsheetApp.getActive().getSheetByName(SHEET_NAME);
  
  if (!sheet) {
    Logger.log("ERROR: Sheet not found!");
    return;
  }
  
  const testParams = {
    id: "test-" + new Date().getTime(),
    date: new Date().toISOString(),
    amount: "100.50",
    note: "Test transaction"
  };
  
  Logger.log("Adding test transaction:", testParams);
  
  const result = addTransaction(sheet, testParams);
  Logger.log("Result:", result.getContent());
}
