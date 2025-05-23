// lib/services/user_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:fyp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for current user access in some methods

class UserService {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  final FirebaseAuth _auth = FirebaseAuth.instance; // For getting current UID

  // Helper to get current user's UID (can be null if not logged in)
  String? get currentUserId => _auth.currentUser?.uid;

  // Method to create/update a user profile in Realtime Database
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersRef.child(user.uid).set(user.toMap());
      print('User profile created/updated successfully for UID: ${user.uid}');
    } catch (e) {
      print('Error creating/updating user profile for UID: ${user.uid}: $e');
      rethrow; // Re-throw to propagate the error if needed
    }
  }

  // Method to fetch a user profile from Realtime Database
  Future<UserModel?> getUserProfile(String uid) async {
    DataSnapshot? dataSnapshot; // Declare snapshot outside the try block
    try {
      print('UserService: Attempting to fetch user profile for UID: $uid');
      final event = await _usersRef.child(uid).once(); // Get the DatabaseEvent
      dataSnapshot = event.snapshot; // Assign the snapshot to the outside variable

      if (dataSnapshot.value != null) {
        final userData = Map<String, dynamic>.from(dataSnapshot.value as Map);
        print('UserService: Data retrieved for UID $uid: $userData');
        return UserModel.fromMap(userData, uid);
      } else {
        print('UserService: No user profile found for UID: $uid');
        return null; // User not found
      }
    } catch (e) {
      print('UserService: ❌ Error fetching user profile for UID $uid: $e');
      // Now dataSnapshot is accessible here
      if (e is TypeError && dataSnapshot?.value != null) {
        print('UserService: Data received type: ${dataSnapshot!.value.runtimeType}');
        print('UserService: Data received value: ${dataSnapshot.value}');
      }
      return null;
    }
  }


  // Method to update a user's online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    final uid = currentUserId;
    if (uid == null) {
      print('User not logged in. Cannot update online status.');
      return;
    }
    try {
      await _usersRef.child(uid).update({
        'isOnline': isOnline,
        'lastActive': ServerValue.timestamp,
      });
      print('Online status updated to $isOnline for UID: $uid');
    } catch (e) {
      print('❌ Error updating online status for UID $uid: $e');
    }
  }

  // Method to get a stream of all users (for chat list, etc.)
  Stream<List<UserModel>> getUsersByType(UserType type) {
    return _usersRef
        .orderByChild('userType')
        .equalTo(type.name) // Filter by user type
        .onValue
        .map((event) {
      final List<UserModel> users = [];
      if (event.snapshot.value != null) {
        // Ensure proper casting here as well
        Map<String, dynamic> usersMap = Map<String, dynamic>.from(event.snapshot.value as Map);
        usersMap.forEach((key, value) {
          if (value is Map<String, dynamic>) { // Ensure value is a Map
            users.add(UserModel.fromMap(value, key));
          }
        });
      }
      return users;
    });
  }

  // Method to get a single user's profile stream (for real-time updates on profile screen, etc.)
  Stream<UserModel?> getUserProfileStream(String uid) {
    return _usersRef.child(uid).onValue.map((event) {
      if (event.snapshot.value != null) {
        final userData = Map<String, dynamic>.from(event.snapshot.value as Map);
        return UserModel.fromMap(userData, uid);
      }
      return null;
    });
  }

  // Method to get a specific user's online status stream
  Stream<bool> getUserOnlineStatusStream(String uid) {
    return _usersRef.child(uid).child('isOnline').onValue.map((event) {
      return (event.snapshot.value as bool?) ?? false; // Default to false if not found
    });
  }

  // Method to block a user
  Future<void> blockUser(String currentUid, String targetUid) async {
    try {
      await _usersRef.child(currentUid).child('blockedUsers').update({targetUid: true});
      await _usersRef.child(targetUid).child('blockedBy').update({currentUid: true});
      print('User $targetUid blocked by $currentUid');
    } catch (e) {
      print('Error blocking user $targetUid by $currentUid: $e');
      rethrow;
    }
  }

  // Method to unblock a user
  Future<void> unblockUser(String currentUid, String targetUid) async {
    try {
      await _usersRef.child(currentUid).child('blockedUsers').child(targetUid).remove();
      await _usersRef.child(targetUid).child('blockedBy').child(currentUid).remove();
      print('User $targetUid unblocked by $currentUid');
    } catch (e) {
      print('Error unblocking user $targetUid by $currentUid: $e');
      rethrow;
    }
  }

  // Stream to check if a user is blocked by the current user
  Stream<bool> isBlockedByCurrentUser(String targetUid) {
    final uid = currentUserId;
    if (uid == null) return Stream.value(false); // Not logged in, can't block
    return _usersRef.child(uid).child('blockedUsers').child(targetUid).onValue.map((event) {
      return event.snapshot.value != null;
    });
  }

  // Stream to check if the current user is blocked by another user
  Stream<bool> isCurrentUserBlockedBy(String targetUid) {
    final uid = currentUserId;
    if (uid == null) return Stream.value(false); // Not logged in
    return _usersRef.child(targetUid).child('blockedUsers').child(uid).onValue.map((event) {
      return event.snapshot.value != null;
    });
  }
}