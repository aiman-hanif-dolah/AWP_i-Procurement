import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  // Getter for the current user.
  User? get currentUser => _currentUser;

  // New getter to retrieve vendorId (which is the current user's email).
  String? get vendorId => _currentUser?.email;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _currentUser = user;
      if (user != null) {
        await _fetchAndNotifyUserData(user.uid);
      }
      notifyListeners();
    });
  }

  Future<void> register(String email, String password) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore (default isAWP: false)
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'isAWP': false, // Default role
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentUser = userCredential.user;
      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<String> login(String email, String password) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = userCredential.user;

      // Fetch the user's role from Firestore
      final role = await _fetchUserRole(_currentUser!.uid);
      notifyListeners();
      return role;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<void> assignRole(String userId, bool isAWP) async {
    try {
      await _firestore.collection('users').doc(userId).update({'isAWP': isAWP});
    } catch (e) {
      throw Exception('Failed to assign role: ${e.toString()}');
    }
  }

  Future<String> _fetchUserRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['isAWP'] == true ? 'AWP' : 'vendor';
      } else {
        throw Exception('User role not found for user ID: $userId');
      }
    } catch (e) {
      throw Exception('Failed to fetch user role: ${e.toString()}');
    }
  }

  Future<void> _fetchAndNotifyUserData(String userId) async {
    try {
      final userData = await getUserData(userId);
      if (userData != null) {
        // Additional logic if needed
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // Method to fetch user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data(); // Return user data as a Map
      } else {
        return null; // User data does not exist
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }
}
