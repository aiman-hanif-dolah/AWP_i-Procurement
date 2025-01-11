import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/vendor_model.dart';
import '../services/firebase_utility.dart';

class VendorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseUtility _firebaseUtility = FirebaseUtility();

  // Store fetched vendors in memory for state management
  List<Map<String, dynamic>> _vendors = [];
  List<Map<String, dynamic>> get vendors => _vendors;

  //--------------------------------------------------------------------------------
  // Register a new vendor with document upload
  //--------------------------------------------------------------------------------
  Future<void> registerVendor(VendorModel vendor, File document) async {
    try {
      // 1. Upload vendor's document (PDF, etc.) to Firebase Storage
      final documentUrl = await _firebaseUtility.uploadFile(
        'vendor_documents/${vendor.email}.pdf', // or vendor.id
        document,
      );

      // 2. Prepare the vendor data map
      final vendorData = {
        ...vendor.toMap(),
        'documentUrl': documentUrl,
        'status': 'Pending',        // Default status
        'dateCreated': DateTime.now(), // Track creation date/time
      };

      // 3. Use vendor.email (or vendor.id) as the Firestore doc ID if you want
      // This ensures no duplicates if user re-registers with same email
      // Otherwise, remove docId param for auto-generated IDs
      final docId = vendor.email; // or vendor.id, if unique
      await _firebaseUtility.addDocument('vendors', vendorData, docId: docId);

      notifyListeners(); // Notify listeners about state changes
    } catch (e) {
      throw Exception('Vendor registration failed: ${e.toString()}');
    }
  }

  //--------------------------------------------------------------------------------
  // Fetch vendors
  //--------------------------------------------------------------------------------
  Future<void> fetchVendors() async {
    try {
      final vendors = await _firebaseUtility.fetchDocuments('vendors');
      // Update internal state
      _vendors = vendors;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch vendors: ${e.toString()}');
    }
  }

  //--------------------------------------------------------------------------------
  // Update vendor status
  //--------------------------------------------------------------------------------
  Future<void> updateVendorStatus(String vendorId, String status) async {
    try {
      // e.g., vendorId = vendor.email or docId assigned in registerVendor
      await _firebaseUtility.updateDocument('vendors', vendorId, {
        'status': status,
        'dateUpdated': DateTime.now(), // optional: track update time
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update vendor status: ${e.toString()}');
    }
  }

  //--------------------------------------------------------------------------------
  // Generate a vendors report
  //--------------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchVendorsReport() async {
    try {
      final snapshot = await _firestore.collection('vendors').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to generate vendor report: ${e.toString()}');
    }
  }
}
