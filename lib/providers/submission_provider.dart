import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/tender_model.dart';
import '../models/submission_model.dart';
import '../services/file_validation_service.dart';
import '../services/firebase_utility.dart';

class SubmissionProvider extends ChangeNotifier {
  final FirebaseUtility _firebaseUtility = FirebaseUtility();
  final FileValidationService _fileValidator = FileValidationService();

  List<TenderModel> tenders = []; // Store tenders

  // Submit a tender file (desktop and mobile)
  Future<void> submitTender(String tenderId, File file, Map<String, dynamic> submissionData) async {
    if (!_fileValidator.validateFile(file, 'excel')) {
      throw Exception('Invalid file format. Only Excel files with correct template allowed.');
    }
    try {
      // 1) Upload file to Firebase Storage
      final fileUrl = await _firebaseUtility.uploadFile(
        'tender_submissions/$tenderId/${file.path.split('/').last}',
        file,
      );

      // 2) Add the fileUrl to your submissionData
      submissionData['fileUrl'] = fileUrl;

      // 3) Actually create the doc with a real Firestore ID
      await addTenderSubmission(tenderId, submissionData);

    } catch (e) {
      throw Exception('Failed to submit tender: ${e.toString()}');
    }
  }

  // Submit a tender file (web)
  // Same approach for web-based submissions:
  Future<void> submitTenderWeb(String tenderId, Uint8List fileBytes, String fileName, Map<String, dynamic> submissionData) async {
    try {
      final fileUrl = await _firebaseUtility.uploadFileFromBytes(
        'tender_submissions/$tenderId/$fileName',
        fileBytes,
      );
      submissionData['fileUrl'] = fileUrl;
      await addTenderSubmission(tenderId, submissionData);
    } catch (e) {
      throw Exception('Failed to submit tender: ${e.toString()}');
    }
  }

  Future<String> addTenderSubmission(String tenderId, Map<String, dynamic> submissionData) async {
    // Get a doc reference with an auto-generated ID
    final docRef = FirebaseFirestore.instance
        .collection('tenders')
        .doc(tenderId)
        .collection('submissions')
        .doc();

    // Add any required fields, set default status, etc.
    submissionData['status'] = 'PENDING';
    submissionData['tenderId'] = tenderId;

    // Create the doc
    await docRef.set(submissionData);

    // docRef.id is the actual ID Firestore generated
    final generatedId = docRef.id;
    // Store that ID into the doc itself
    await docRef.update({'submissionId': generatedId});

    return generatedId;
  }

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
        return TenderModel.fromMap(doc, doc['submissionId']);
      }).toList();
      notifyListeners();
      return tenders;
    });
  }

  // Update tender status
  Future<void> updateTenderStatus(String submissionId, bool isOpen) async {
    try {
      await _firebaseUtility.updateDocument('tenders', submissionId, {'isOpen': isOpen});
    } catch (e) {
      throw Exception('Failed to update tender status: ${e.toString()}');
    }
  }

  // Fetch submissions as a stream
  Stream<List<SubmissionModel>> fetchSubmissions(String tenderId) {
    return _firebaseUtility.fetchDocumentStream('tenders/$tenderId/submissions').map((snapshot) {
      for (var doc in snapshot) {
        print('Raw submission data: $doc');
      }
      return snapshot.map((doc) {
        return SubmissionModel.fromMap(doc, doc['submissionId'] ?? '');
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

  // Helper method to calculate submission score
  int calculateScore(Map<String, dynamic> submission) {
    if (submission.containsKey('bidAmount')) {
      final bidAmount = submission['bidAmount'];
      if (bidAmount is num) {
        return 1000 - bidAmount.toInt();
      }
    }
    return 0;
  }

  // Reject a submission
  Future<void> rejectSubmission(String submissionId) async {
    try {
      await _firebaseUtility.updateDocument('submissions', submissionId, {'status': 'Rejected'});
    } catch (e) {
      throw Exception('Failed to reject submission: ${e.toString()}');
    }
  }

  // Evaluate a single submission
  Future<void> evaluateSubmission(BuildContext context, SubmissionModel submission) async {
    try {
      final response = await http.get(Uri.parse(submission.fileUrl));

      if (response.statusCode == 200) {
        final score = calculateScore({'fileContent': response.bodyBytes});
        await _firebaseUtility.updateDocument(
            'tenders/${submission.tenderId}/submissions',
            submission.submissionId,
            {'score': score}
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission evaluated successfully.')),
          );
        }
      } else {
        throw Exception('Failed to fetch file. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error evaluating submission: $e')),
        );
      }
    }
  }
}
