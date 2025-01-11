import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/tender_model.dart';
import '../services/firebase_utility.dart';

class TenderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseUtility _firebaseUtility = FirebaseUtility();

  List<TenderModel> tenders = []; // List of fetched tenders

  //------------------------------------------------------------------------------
  // Create a new tender, with auto-generated ID if missing
  //------------------------------------------------------------------------------
  Future<void> createTender(Map<String, dynamic> tenderData) async {
    try {
      // If no 'procurementId' provided, generate one
      if (!tenderData.containsKey('procurementId')) {
        tenderData['procurementId'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Firestore doc ID and 'id' field both set to 'procurementId'
      final String procurementId = tenderData['procurementId'];
      tenderData['id'] = procurementId; // So that .fromMap(..., data['id']) works

      // OPTIONAL: If you want new tenders to be open by default
      tenderData['isOpen'] ??= true;

      // OPTIONAL: Provide a default title if none is set
      tenderData['title'] ??= 'Untitled Tender';

      // OPTIONAL: Track creation date/time
      tenderData['dateCreated'] ??= DateTime.now();

      // Direct Firestore usage
      final docRef = _firestore.collection('tenders').doc(procurementId);
      await docRef.set(tenderData);

    } catch (e) {
      throw Exception('Failed to create tender: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // Fetch tenders (no filter by default)
  //------------------------------------------------------------------------------
  Stream<List<TenderModel>> fetchTenders() {
    return _firebaseUtility.fetchDocumentStream('tenders').map((docs) {
      debugPrint('Fetched tender docs: $docs'); // Temporarily log the raw data
      return docs.map((data) {
        debugPrint('Tender data: $data');       // Log each doc individually
        return TenderModel.fromMap(data, data['id']);
      }).toList();
    });
  }

  //------------------------------------------------------------------------------
  // Fetch a specific tender by ID
  //------------------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchTenderById(String tenderId) async {
    try {
      final doc = await _firestore.collection('tenders').doc(tenderId).get();
      if (!doc.exists) {
        throw Exception('Tender with ID $tenderId does not exist.');
      }
      return doc.data()!;
    } catch (e) {
      throw Exception('Failed to fetch tender by ID: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // Update tender status (e.g., close an open tender)
  //------------------------------------------------------------------------------
  Future<void> updateTenderStatus(String tenderId, bool isOpen) async {
    try {
      await _firebaseUtility.updateDocument('tenders', tenderId, {'isOpen': isOpen});
    } catch (e) {
      throw Exception('Failed to update tender status: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // Submit a tender (with file upload)
  //------------------------------------------------------------------------------
  Future<void> submitTender(
      String tenderId,
      File file,
      Map<String, dynamic> submissionData,
      ) async {
    try {
      // Upload file to Firebase Storage
      final ref = _storage.ref().child(
        'tender_submissions/$tenderId/${submissionData['vendorId']}.pdf',
      );
      final uploadTask = await ref.putFile(file);
      final fileUrl = await uploadTask.ref.getDownloadURL();

      // Add submission data to Firestore
      submissionData['fileUrl'] = fileUrl;
      await _firestore.collection('tenders/$tenderId/submissions').add(submissionData);
    } catch (e) {
      throw Exception('Failed to submit tender: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // Evaluate and rank submissions for a tender
  //------------------------------------------------------------------------------
  Future<void> evaluateTender(String tenderId) async {
    try {
      final submissions = await _firestore
          .collection('tenders/$tenderId/submissions')
          .get();

      final rankedSubmissions = submissions.docs.map((doc) {
        final data = doc.data();
        data['score'] = calculateScore(data); // Replace with actual scoring logic
        return data;
      }).toList()
        ..sort((a, b) => b['score'].compareTo(a['score']));

      // Notify vendors of the results
      for (int i = 0; i < rankedSubmissions.length; i++) {
        final submission = rankedSubmissions[i];
        await notifyVendor(
          submission['vendorId'],
          i == 0 ? 'Winner' : 'Not Selected',
        );
      }
    } catch (e) {
      throw Exception('Failed to evaluate tender: ${e.toString()}');
    }
  }

  // Example scoring function
  int calculateScore(Map<String, dynamic> submission) {
    // For demonstration only: higher score for lower bid
    if (submission.containsKey('bidAmount')) {
      final bidAmount = submission['bidAmount'];
      if (bidAmount is num) {
        return 1000 - bidAmount.toInt();
      }
    }
    return 0;
  }

  //------------------------------------------------------------------------------
  // Generate a tenders report
  //------------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchTendersReport() async {
    try {
      final snapshot = await _firestore.collection('tenders').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to generate tender report: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // Notify vendor (store a notification in Firestore or similar)
  //------------------------------------------------------------------------------
  Future<void> notifyVendor(String vendorId, String message) async {
    try {
      await _firebaseUtility.addNotification(vendorId, message);
    } catch (e) {
      throw Exception('Failed to notify vendor: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // Fetch notifications for a specific vendor
  //------------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> fetchVendorNotifications(String vendorId) {
    return _firebaseUtility.fetchDocumentStream(
      'notifications',
      field: 'vendorId',
      value: vendorId,
    );
  }

  Future<Map<String, int>> fetchDatabaseStats() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // 1) Count how many user docs
      final usersSnap = await _firestore.collection('users').get();
      final totalUsers = usersSnap.size;

      // 2) Count how many tender docs
      final tendersSnap = await _firestore.collection('tenders').get();
      final totalTenders = tendersSnap.size;

      // 3) Sum up total submissions across all tenders
      int totalSubmissions = 0;
      for (var tenderDoc in tendersSnap.docs) {
        final submissionsSnap = await tenderDoc.reference.collection('submissions').get();
        totalSubmissions += submissionsSnap.size;
      }

      return {
        'users': totalUsers,
        'tenders': totalTenders,
        'submissions': totalSubmissions,
      };
    } catch (e) {
      throw Exception('Failed to fetch DB stats: $e');
    }
  }

}
