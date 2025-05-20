import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:email_validator/email_validator.dart'; // Import for email validation

import '../models/user_model.dart'; // Make sure this exists.

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  // Helper method to get the currently logged-in user.
  User? get currentUser => _auth.currentUser;

  // Register a new user.
  Future<String?> registerUser(AppUser user, String password) async {
    try {
      print("▶ Register started");
      final emailExists = await checkEmailExists(user.email);
      final usernameExists = await checkUsernameExists(user.username);
      print("▶ Email exists: $emailExists, Username exists: $usernameExists");

      if (emailExists) return "Email already in use";
      if (usernameExists) return "Username already taken";

      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      user.uid = userCred.user!.uid;

      print("▶ Writing to DB at /users/${user.uid}");
      await _dbRef.child(user.uid).set(user.toJson());
      print("✅ Successfully saved user to DB");
      return null; // success
    } on FirebaseAuthException catch (e) {
      print("❌ Register error: ${e.message}");
      return e.message;
    } catch (e) {
      print("❌ Register error: $e");
      return "An unexpected error occurred.";
    }
  }

  // Check if an email exists in the database.
  Future<bool> checkEmailExists(String email) async {
    final snapshot = await _dbRef.orderByChild("email").equalTo(email).once();
    return snapshot.snapshot.value != null;
  }

  // Check if a username exists in the database.
  Future<bool> checkUsernameExists(String username) async {
    final snapshot = await _dbRef.orderByChild("username").equalTo(username).once();
    return snapshot.snapshot.value != null;
  }

  // Login a user.
// Login a user and return their user node on success.
  Future<AppUser?> loginUser(String email, String password) async {
    try {
      // Authenticate using Firebase Auth
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Find the user node by email
      final snapshot = await _dbRef.orderByChild("email").equalTo(email).once();

      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        final firstEntry = data.entries.first;

        final Map<String, dynamic> userJson = Map<String, dynamic>.from(firstEntry.value);
        return AppUser.fromJson(userJson);
      } else {
        print("❌ No user node found for email.");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Login error: ${e.message}");
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
      throw e; // Re-throw the exception to be handled in the UI.
    } catch (e) {
      print("❌ Unexpected error updating email in Auth: $e");
      throw Exception("Failed to update email: An unexpected error occurred.");
    }
  }

  // Update user data in the Realtime Database.
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _dbRef.child(uid).update(data);
      print("✅ User data updated in Realtime Database: $data");
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
      throw e; // Re-throw to be handled in UI
    }  catch (e) {
      print("❌ Unexpected error updating password: $e");
      throw Exception("Failed to update password: An unexpected error occurred.");
    }
  }
}