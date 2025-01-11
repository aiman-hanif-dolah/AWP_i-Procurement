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


  // Register a new vendor with document upload
  Future<void> registerVendor(VendorModel vendor, File document) async {
    try {
      // Use FirebaseUtility to upload the document
      final documentUrl = await _firebaseUtility.uploadFile(
        'vendor_documents/${vendor.email}.pdf',
        document,
      );

      // Use FirebaseUtility to add vendor data
      await _firebaseUtility.addDocument('vendors', {
        ...vendor.toMap(),
        'documentUrl': documentUrl,
        'status': 'Pending', // Default status
      });

      notifyListeners(); // Notify listeners about state changes
    } catch (e) {
      throw Exception('Vendor registration failed: ${e.toString()}');
    }
  }

  // Fetch vendors
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

  // Update vendor status
  Future<void> updateVendorStatus(String vendorId, String status) async {
    try {
      await _firebaseUtility.updateDocument('vendors', vendorId, {'status': status});
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update vendor status: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVendorsReport() async {
    try {
      final snapshot = await _firestore.collection('vendors').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to generate vendor report: ${e.toString()}');
    }
  }

}
