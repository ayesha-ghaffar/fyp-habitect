enum Gender { male, female, other }

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

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      email: json['email'] ?? false,
      push: json['push'] ?? false,
      sms: json['sms'] ?? false,
      marketing: json['marketing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'push': push,
      'sms': sms,
      'marketing': marketing,
    };
  }
}

class AppUser {
  String uid;
  String name;
  String username;
  String email;
  String phoneNumber;
  DateTime dateOfBirth;
  Gender gender;
  String avatarUrl;
  NotificationPreferences notifications;
  String role;

  AppUser({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.avatarUrl,
    required this.notifications,
    required this.role,
  });

  /// ✅ Converts class instance to Firebase-storable JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'gender': gender.toString().split('.').last,
      'avatarUrl': avatarUrl,
      'notifications': notifications.toJson(),
      'role': role,
    };
  }

  /// ✅ Converts Firebase JSON to AppUser instance
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(json['dateOfBirth']),
      gender: _parseGender(json['gender']),
      avatarUrl: json['avatarUrl'] ?? '',
      notifications: NotificationPreferences.fromJson(json['notifications'] ?? {}),
      role: json['role'] ?? '',
    );
  }

  /// Helper: parse gender from string
  static Gender _parseGender(String? value) {
    switch (value?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.other;
    }
  }
}
