// lib/services/auth_service.dart
import 'dart:io';
import 'package:flutter/material.dart'; // Keep if you use widgets like ImagePicker, though usually not in a service.
import 'package:image_picker/image_picker.dart'; // Keep if used for profile pic uploads within auth service.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:email_validator/email_validator.dart'; // Keep if used for validation here.

import 'package:fyp/models/user_model.dart'; // <<< UPDATED IMPORT, ensure 'fyp' matches your project name

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  // Helper method to get the currently logged-in user.
  User? get currentUser => _auth.currentUser;

  // Register a new user. Now expects UserModel
  // Registration method
  // This method should only handle Firebase Authentication, not database writes.
  Future<String?> registerUser(UserModel userModel, String password) async {
    try {
      // Create user with email and password in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      // Optionally, you can send email verification here
      // await userCredential.user!.sendEmailVerification();

      // Return null on success, indicating no error.
      // The UID is now available via _auth.currentUser?.uid in RegisterScreen.
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else {
        return e.message;
      }
    } catch (e) {
      print("Register error in AuthService: $e"); // Log for debugging
      return e.toString();
    }
  }

  // Check if an email exists in the database.
  Future<bool> checkEmailExists(String email) async {
    final snapshot = await _dbRef.orderByChild("email").equalTo(email).once();
    // snapshot.snapshot.value will be a Map if exists, otherwise null
    return snapshot.snapshot.value != null;
  }

  // Check if a username exists in the database.
  Future<bool> checkUsernameExists(String username) async {
    final snapshot = await _dbRef.orderByChild("username").equalTo(username).once();
    // snapshot.snapshot.value will be a Map if exists, otherwise null
    return snapshot.snapshot.value != null;
  }

  // Login a user and return their UserModel on success.
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      print("▶ Login started for email: $email");

      // Try to authenticate first
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ Authentication successful for UID: ${userCred.user!.uid}");

      // Directly fetch user data using UID
      final uidSnapshot = await _dbRef.child(userCred.user!.uid).once();

      if (uidSnapshot.snapshot.value == null) {
        print("❌ User authenticated but no database record found for UID: ${userCred.user!.uid}");
        return null;
      }

      try {
        final userData = Map<String, dynamic>.from(uidSnapshot.snapshot.value as Map);
        print("✅ User data retrieved successfully for UID: ${userCred.user!.uid}");
        return UserModel.fromMap(userData, userCred.user!.uid); // Use UserModel.fromMap
      } catch (e) {
        print("❌ Error parsing user data: $e");
        print("Data received type: ${uidSnapshot.snapshot.value.runtimeType}");
        print("Data received value: ${uidSnapshot.snapshot.value}");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Login authentication error: ${e.message}");
      // You might want to return a specific error message based on e.code
      return null;
    } catch (e) {
      print("❌ Unexpected error during login: $e");
      return null;
    }
  }

  // Update user email in Firebase Authentication.
  Future<void> updateUserEmail(String newEmail) async {
    try {
      await currentUser!.updateEmail(newEmail);
      print("✅ Email updated in Firebase Authentication to: $newEmail");
    } on FirebaseAuthException catch (e) {
      print("❌ Error updating email in Auth: ${e.message}");
      rethrow; // Re-throw the exception to be handled in the UI.
    } catch (e) {
      print("❌ Unexpected error updating email in Auth: $e");
      throw Exception("Failed to update email: An unexpected error occurred.");
    }
  }

  // Update user data in the Realtime Database. Now expects UserModel (or a map)
  // I'll keep the Map<String, dynamic> parameter for flexibility as you might update subsets
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      // Add updatedAt timestamp automatically
      data['updatedAt'] = ServerValue.timestamp; // Use ServerValue.timestamp

      await _dbRef.child(uid).update(data);
      print("✅ User data updated in Realtime Database for UID: $uid with data: $data");
    } catch (e) {
      print("❌ Error updating user data in Database: $e");
      throw Exception("Failed to update user data: $e");
    }
  }

  // Change User Password
  Future<void> changeUserPassword(String newPassword) async {
    try {
      await currentUser!.updatePassword(newPassword);
      print("✅ Password updated successfully.");
    } on FirebaseAuthException catch (e) {
      print("❌ Failed to update password: ${e.message}");
      rethrow; // Re-throw to be handled in UI
    } catch (e) {
      print("❌ Unexpected error updating password: $e");
      throw Exception("Failed to update password: An unexpected error occurred.");
    }
  }

  // Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("✅ User signed out.");
    } catch (e) {
      print("❌ Error signing out: $e");
      rethrow;
    }
  }
}