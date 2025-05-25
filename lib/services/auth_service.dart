import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fyp/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  User? get currentUser => _auth.currentUser;

  Future<String?> registerUser(UserModel userModel, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();
      print("Verification email sent to: ${userCredential.user!.email}");

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
      print("----Register error in AuthService: $e");
      return e.toString();
    }
  }

  // Method to resend verification email
  Future<String?> resendVerificationEmail() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
        return null; // Success
      } else {
        return "No unverified user found or email already verified.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Method to Check if an email exists in the database.
  Future<bool> checkEmailExists(String email) async {
    final snapshot = await _dbRef.orderByChild("email").equalTo(email).once();
    return snapshot.snapshot.value != null;
  }

  // Method to Check if a username exists in the database.
  Future<bool> checkUsernameExists(String username) async {
    final snapshot = await _dbRef.orderByChild("username").equalTo(username).once();
    return snapshot.snapshot.value != null;
  }

  // Method to Login a user and return their UserModel on success.
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      print("-----Login started for email: $email");
      // Authenticate first
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("-----Authentication successful for UID: ${userCred.user!.uid}");
      // Directly fetch user data using UID
      final uidSnapshot = await _dbRef.child(userCred.user!.uid).once();
      if (uidSnapshot.snapshot.value == null) {
        print("User authenticated but no database record found for UID: ${userCred.user!.uid}");
        return null;
      }
      try {
        final userData = Map<String, dynamic>.from(uidSnapshot.snapshot.value as Map);
        print("-----User data retrieved successfully for UID: ${userCred.user!.uid}");
        return UserModel.fromMap(userData, userCred.user!.uid);
      }
      catch (e) {
        print("-----Error parsing user data: $e");
        print("-----Data received type: ${uidSnapshot.snapshot.value.runtimeType}");
        print("-----Data received value: ${uidSnapshot.snapshot.value}");
        return null;
      }
    }
    on FirebaseAuthException catch (e) {
      print("-----Login authentication error: ${e.message}");
      return null;
    }
    catch (e) {
      print("-----Unexpected error during login: $e");
      return null;
    }
  }

  // Method to Update user email in Firebase Authentication.
  Future<void> updateUserEmail(String newEmail) async {
    try {
      await currentUser!.updateEmail(newEmail);
      print("-----Email updated in Firebase Authentication to: $newEmail");
    } on FirebaseAuthException catch (e) {
      print("-----Error updating email in Auth: ${e.message}");
      rethrow;
    } catch (e) {
      print("-----Unexpected error updating email in Auth: $e");
      throw Exception("Failed to update email: An unexpected error occurred.");
    }
  }

  //Method to update userdata in DataBase
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = ServerValue.timestamp;

      await _dbRef.child(uid).update(data);
      print("-----User data updated in Realtime Database for UID: $uid with data: $data");
    }
    catch (e) {
      print("-----Error updating user data in Database: $e");
      throw Exception("Failed to update user data: $e");
    }
  }

  // Method to Change User Password
  Future<void> changeUserPassword(String newPassword) async {
    try {
      await currentUser!.updatePassword(newPassword);
      print("-----Password updated successfully.");
    } on FirebaseAuthException catch (e) {
      print("-----Failed to update password: ${e.message}");
      rethrow;
    } catch (e) {
      print("-----Unexpected error updating password: $e");
      throw Exception("Failed to update password: An unexpected error occurred.");
    }
  }

  //Method to Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("-----User signed out.");
    } catch (e) {
      print("-----Error signing out: $e");
      rethrow;
    }
  }
}