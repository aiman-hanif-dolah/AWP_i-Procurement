import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/tender_model.dart';
import '../models/submission_model.dart';
import '../services/file_validation_service.dart';
import '../services/firebase_utility.dart';

class SubmissionProvider extends ChangeNotifier {
  final FirebaseUtility _firebaseUtility = FirebaseUtility();
  final FileValidationService _fileValidator = FileValidationService();

  List<TenderModel> tenders = []; // Declare the tenders list

  // Create a new tender
  Future<void> createTender(Map<String, dynamic> tenderData) async {
    try {
      await _firebaseUtility.addDocument('tenders', tenderData);
    } catch (e) {
      throw Exception('Failed to create tender: ${e.toString()}');
    }
  }

  // Fetch tenders as a stream
  Stream<List<TenderModel>> fetchTenders() {
    return _firebaseUtility.fetchDocumentStream('tenders').map((snapshot) {
      tenders = snapshot.map((doc) {
        return TenderModel.fromMap(doc, doc['id']);
      }).toList();
      notifyListeners();
      return tenders;
    });
  }

  // Update tender status
  Future<void> updateTenderStatus(String id, bool isOpen) async {
    try {
      await _firebaseUtility.updateDocument('tenders', id, {'isOpen': isOpen});
    } catch (e) {
      throw Exception('Failed to update tender status: ${e.toString()}');
    }
  }

  // Submit a tender
  Future<void> submitTender(String tenderId, File file, Map<String, dynamic> submissionData) async {
    if (!_fileValidator.validateFile(file, 'pdf')) {
      throw Exception('Invalid file format. Only PDFs are allowed.');
    }

    try {
      // Use FirebaseUtility to upload the file
      final fileUrl = await _firebaseUtility.uploadFile(
        'tender_submissions/$tenderId/${submissionData['vendorId']}.pdf',
        file,
      );

      // Add submission data to Firestore
      submissionData['fileUrl'] = fileUrl;
      await _firebaseUtility.addDocument('tenders/$tenderId/submissions', submissionData);
    } catch (e) {
      throw Exception('Failed to submit tender: ${e.toString()}');
    }
  }

  // Fetch submissions as a stream
  Stream<List<SubmissionModel>> fetchSubmissions(String tenderId) {
    return _firebaseUtility.fetchDocumentStream('tenders/$tenderId/submissions').map((snapshot) {
      return snapshot.map((doc) {
        return SubmissionModel.fromMap(doc, doc['id']);
      }).toList();
    });
  }

  // Evaluate and rank submissions
  Future<void> evaluateSubmissions(String tenderId) async {
    try {
      final submissions = await _firebaseUtility.fetchDocuments('tenders/$tenderId/submissions');

      final rankedSubmissions = submissions.map((doc) {
        final data = doc;
        data['score'] = calculateScore(data); // Replace with actual scoring logic
        return data;
      }).toList()
        ..sort((a, b) => b['score'].compareTo(a['score']));

      // Notify vendors of the results
      for (int i = 0; i < rankedSubmissions.length; i++) {
        final submission = rankedSubmissions[i];
        await _firebaseUtility.addNotification(
          submission['vendorId'],
          i == 0 ? 'Winner' : 'Not Selected',
        );
      }
    } catch (e) {
      throw Exception('Failed to evaluate submissions: ${e.toString()}');
    }
  }

  // Helper methods
  int calculateScore(Map<String, dynamic> submission) {
    if (submission.containsKey('bidAmount')) {
      final bidAmount = submission['bidAmount'];
      if (bidAmount is num) {
        return 1000 - bidAmount.toInt();
      }
    }
    return 0;
  }

  Future<void> rejectSubmission(String submissionId) async {
    try {
      await _firebaseUtility.updateDocument('submissions', submissionId, {'status': 'Rejected'});
    } catch (e) {
      throw Exception('Failed to reject submission: ${e.toString()}');
    }
  }

  Future<void> evaluateSubmission(String submissionId, String fileUrl, double score) async {
    try {
      await _firebaseUtility.updateDocument('tenders/submissions', submissionId, {
        'score': score,
        'status': 'Evaluated',
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to evaluate submission: ${e.toString()}');
    }
  }
}
