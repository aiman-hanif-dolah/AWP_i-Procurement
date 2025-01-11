// firebase_utility.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUtility {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Singleton instance
  static final FirebaseUtility _instance = FirebaseUtility._internal();
  factory FirebaseUtility() => _instance;
  FirebaseUtility._internal();

  // Upload a file to Firebase Storage
  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('File upload failed: ${e.toString()}');
    }
  }

  // Add a document to Firestore
// firebase_utility.dart

  Future<DocumentReference> addDocument(
      String collectionPath,
      Map<String, dynamic> data, {
        String? docId,
      }) async {
    try {
      final collectionRef = _firestore.collection(collectionPath);

      // If docId is provided, use that as the Firestore doc ID
      if (docId != null && docId.isNotEmpty) {
        await collectionRef.doc(docId).set(data);
        return collectionRef.doc(docId);
      } else {
        // Otherwise, let Firestore auto-generate an ID
        return await collectionRef.add(data);
      }
    } catch (e) {
      throw Exception('Failed to add document: ${e.toString()}');
    }
  }

  // Fetch documents from Firestore as a list of maps
  Future<List<Map<String, dynamic>>> fetchDocuments(String collectionPath) async {
    try {
      final snapshot = await _firestore.collection(collectionPath).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch documents: ${e.toString()}');
    }
  }

  // Update a document in Firestore
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: ${e.toString()}');
    }
  }

  // Add a notification to Firestore
  Future<void> addNotification(String vendorId, String message) async {
    try {
      await addDocument('notifications', {
        'vendorId': vendorId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add notification: ${e.toString()}');
    }
  }

  // Fetch a stream of documents from Firestore
  Stream<List<Map<String, dynamic>>> fetchDocumentStream(String collectionPath, {String? field, dynamic value}) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);
      if (field != null && value != null) {
        query = query.where(field, isEqualTo: value);
      }
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch document stream: ${e.toString()}');
    }
  }

  Future<String> uploadFileFromBytes(String path, Uint8List fileBytes) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(fileBytes);
      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('File upload failed: ${e.toString()}');
    }
  }

  Future<String> getDownloadUrl(String path) async {
    try {
      return await FirebaseStorage.instance.ref(path).getDownloadURL();
    } catch (e) {
      throw Exception('Failed to generate download URL: $e');
    }
  }

}
