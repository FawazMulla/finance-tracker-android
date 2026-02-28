import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

/// Firebase Firestore Backup Service
/// Acts as secondary backup storage - does NOT replace Google Sheets
/// All operations are silent and non-blocking
class FirestoreBackupService {
  static const String _collectionName = 'backup_records';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Add backup record to Firestore
  /// Silent operation - failures do not affect app functionality
  Future<void> addBackupRecord(TransactionModel transaction) async {
    try {
      await _firestore.collection(_collectionName).doc(transaction.id).set({
        'id': transaction.id,
        'date': transaction.date.toIso8601String(),
        'amount': transaction.amount,
        'note': transaction.note,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) {
        print('[FirestoreBackup] Added record: ${transaction.id}');
      }
    } catch (e) {
      // Silent failure - backup is optional
      if (kDebugMode) {
        print('[FirestoreBackup] Failed to add record: $e');
      }
    }
  }
  
  /// Update backup record in Firestore
  /// Silent operation - failures do not affect app functionality
  Future<void> updateBackupRecord(String docId, TransactionModel transaction) async {
    try {
      await _firestore.collection(_collectionName).doc(docId).update({
        'date': transaction.date.toIso8601String(),
        'amount': transaction.amount,
        'note': transaction.note,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) {
        print('[FirestoreBackup] Updated record: $docId');
      }
    } catch (e) {
      // Silent failure - backup is optional
      if (kDebugMode) {
        print('[FirestoreBackup] Failed to update record: $e');
      }
    }
  }
  
  /// Delete backup record from Firestore
  /// Silent operation - failures do not affect app functionality
  Future<void> deleteBackupRecord(String docId) async {
    try {
      await _firestore.collection(_collectionName).doc(docId).delete();
      
      if (kDebugMode) {
        print('[FirestoreBackup] Deleted record: $docId');
      }
    } catch (e) {
      // Silent failure - backup is optional
      if (kDebugMode) {
        print('[FirestoreBackup] Failed to delete record: $e');
      }
    }
  }
  
  /// Get real-time stream of backup records
  /// Returns empty stream on error
  Stream<QuerySnapshot> getBackupRecords() {
    try {
      return _firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      if (kDebugMode) {
        print('[FirestoreBackup] Failed to get backup stream: $e');
      }
      // Return empty stream on error
      return const Stream.empty();
    }
  }
  
  /// Get all backup records as list
  Future<List<Map<String, dynamic>>> getAllBackupRecords() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'docId': doc.id,
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('[FirestoreBackup] Failed to get all records: $e');
      }
      return [];
    }
  }
}
