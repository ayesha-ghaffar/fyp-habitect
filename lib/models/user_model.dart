import 'package:firebase_database/firebase_database.dart'; // For ServerValue.timestamp

// Define the UserType enum
enum UserType { client, architect, admin, unknown }

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final Gender gender;
  final String avatarUrl;
  final NotificationPreferences notifications;
  final UserType userType;
  final dynamic createdAt;
  final dynamic updatedAt;
  final dynamic lastActive;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.avatarUrl,
    required this.notifications,
    required this.userType,
    this.createdAt,
    this.updatedAt,
    this.lastActive,
    this.isOnline = false,
  });

  // Factory constructor to create a UserModel from a Map (e.g., from Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    // Debug print for UserModel.fromMap entry
    print('UserModel.fromMap: Processing map for UID $uid: $map');

    // Safe parsing for dateOfBirth with proper error handling
    DateTime parsedDateOfBirth;
    try {
      if (map['dateOfBirth'] is int) {
        parsedDateOfBirth = DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth']);
      } else if (map['dateOfBirth'] is String) {
        // Try parsing as ISO 8601 string
        parsedDateOfBirth = DateTime.parse(map['dateOfBirth']);
      } else if (map['dateOfBirth'] != null) {
        // Handle case where it might be a different type
        print('Unexpected dateOfBirth type: ${map['dateOfBirth'].runtimeType}');
        parsedDateOfBirth = DateTime.now(); // Default fallback
      } else {
        // Handle null case
        parsedDateOfBirth = DateTime.now(); // Default if null
      }
    } catch (e) {
      print('Error parsing dateOfBirth: $e');
      print('dateOfBirth value: ${map['dateOfBirth']}');
      print('dateOfBirth type: ${map['dateOfBirth'].runtimeType}');
      // Use a default date or current date as fallback
      parsedDateOfBirth = DateTime.now();
    }

    // Ensure notifications map is correctly cast before passing to NotificationPreferences.fromMap
    Map<String, dynamic> notificationsMap = {};
    try {
      if (map['notifications'] != null && map['notifications'] is Map) {
        notificationsMap = Map<String, dynamic>.from(map['notifications'] as Map);
      }
    } catch (e) {
      print('Error parsing notifications: $e');
      // Use empty map as fallback
      notificationsMap = {};
    }

    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      dateOfBirth: parsedDateOfBirth,
      gender: (map['gender'] as String?)?.toGenderEnum() ?? Gender.unknown,
      avatarUrl: map['avatarUrl'] ?? '',
      notifications: NotificationPreferences.fromMap(notificationsMap),
      userType: (map['userType'] as String?)?.toUserTypeEnum() ?? UserType.unknown,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      lastActive: map['lastActive'],
      isOnline: map['isOnline'] ?? false,
    );
  }

  // Convert UserModel to a Map (for storing in Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch, // Store as millisecondsSinceEpoch
      'gender': gender.name,
      'avatarUrl': avatarUrl,
      'notifications': notifications.toMap(),
      'userType': userType.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastActive': lastActive,
      'isOnline': isOnline,
    };
  }

  // copyWith method for immutability and easy updates
  UserModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Gender? gender,
    String? avatarUrl,
    NotificationPreferences? notifications,
    UserType? userType,
    dynamic createdAt,
    dynamic updatedAt,
    dynamic lastActive,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notifications: notifications ?? this.notifications,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

// Helper extension for Gender enum conversion
extension GenderExtension on String {
  Gender toGenderEnum() {
    switch (this) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.unknown;
    }
  }
}

// Define the Gender enum
enum Gender { male, female, other, unknown }

class NotificationPreferences {
  bool email;
  bool push;
  bool sms;
  bool marketing;

  NotificationPreferences({
    required this.email,
    required this.push,
    required this.sms,
    required this.marketing,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    // This factory should now receive an already correctly typed Map<String, dynamic>
    return NotificationPreferences(
      email: map['email'] ?? false,
      push: map['push'] ?? false,
      sms: map['sms'] ?? false,
      marketing: map['marketing'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'push': push,
      'sms': sms,
      'marketing': marketing,
    };
  }
}

// Helper extension for UserType enum conversion
extension UserTypeExtension on String {
  UserType toUserTypeEnum() {
    switch (this) {
      case 'client':
        return UserType.client;
      case 'architect':
        return UserType.architect;
      case 'admin':
        return UserType.admin;
      default:
        return UserType.unknown;
    }
  }
}