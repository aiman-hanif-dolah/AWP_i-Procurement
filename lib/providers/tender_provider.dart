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

  List<TenderModel> tenders = []; // Declare the tenders list

  // Create a new tender
  Future<void> createTender(Map<String, dynamic> tenderData) async {
    try {
      await _firebaseUtility.addDocument('tenders', tenderData);
    } catch (e) {
      throw Exception('Failed to create tender: ${e.toString()}');
    }
  }

  // Fetch tenders
  Stream<List<TenderModel>> fetchTenders() {
    return _firebaseUtility.fetchDocumentStream('tenders').map((docs) {
      return docs.map((data) => TenderModel.fromMap(data, data['id'])).toList();
    });
  }

  // Update tender status
  Future<void> updateTenderStatus(String tenderId, bool isOpen) async {
    try {
      await _firebaseUtility.updateDocument('tenders', tenderId, {'isOpen': isOpen});
    } catch (e) {
      throw Exception('Failed to update tender status: ${e.toString()}');
    }
  }
  // Submit a tender
  Future<void> submitTender(String tenderId, File file, Map<String, dynamic> submissionData) async {
    try {
      // Upload tender file to Firebase Storage
      final ref = _storage.ref().child('tender_submissions/$tenderId/${submissionData['vendorId']}.pdf');
      final uploadTask = await ref.putFile(file);
      final fileUrl = await uploadTask.ref.getDownloadURL();

      // Add submission data to Firestore
      submissionData['fileUrl'] = fileUrl;
      await _firestore.collection('tenders/$tenderId/submissions').add(submissionData);
    } catch (e) {
      throw Exception('Failed to submit tender: ${e.toString()}');
    }
  }

  // Evaluate and rank submissions
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

  int calculateScore(Map<String, dynamic> submission) {
    // Example: Score based on bid amount (lower is better)
    // Replace with your actual scoring logic
    if (submission.containsKey('bidAmount')) {
      final bidAmount = submission['bidAmount'];
      if (bidAmount is num) {
        return 1000 - bidAmount.toInt(); // Example: Higher score for lower bid
      }
    }
    return 0; // Default score if no criteria match
  }

  Future<List<Map<String, dynamic>>> fetchTendersReport() async {
    try {
      final snapshot = await _firestore.collection('tenders').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to generate tender report: ${e.toString()}');
    }
  }
  // Add a notification related to tenders
  Future<void> notifyVendor(String vendorId, String message) async {
    try {
      await _firebaseUtility.addNotification(vendorId, message);
    } catch (e) {
      throw Exception('Failed to notify vendor: ${e.toString()}');
    }
  }

  // Fetch notifications for a specific vendor
  Stream<List<Map<String, dynamic>>> fetchVendorNotifications(String vendorId) {
    return _firebaseUtility.fetchDocumentStream(
      'notifications',
      field: 'vendorId',
      value: vendorId,
    );
  }
}
