import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<void> register(String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'role': role, // e.g., 'vendor' or 'admin'
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentUser = userCredential.user;
      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<void> assignRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({'role': role});
    } catch (e) {
      throw Exception('Failed to assign role: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      } else {
        return null; // User data does not exist
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }
}
