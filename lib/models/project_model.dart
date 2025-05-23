// lib/models/project_model.dart
// import 'package:flutter/foundation.dart'; // No longer strictly needed unless you use @required
import 'package:fyp/models/bid_model.dart'; // Import the Bid model

class Project {
  final String? id;
  final String clientId;
  final String title;
  final String type;
  final String budget;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final List<String> layoutPreferences;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final Map<String, Bid>? bids;

  Project({
    this.id,
    required this.clientId,
    required this.title,
    required this.type,
    required this.budget,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.layoutPreferences,
    this.notes,
    this.status = 'open',
    required this.createdAt,
    this.bids,
  });

  // Convert Project to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'title': title,
      'type': type,
      'budget': budget,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'layoutPreferences': layoutPreferences,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      // Iterate through bids to convert each Bid object to its map representation
      'bids': bids?.map((key, value) => MapEntry(key, value.toMap())) ?? {},
    };
  }

  // Create Project from Map (Firebase data)
  factory Project.fromMap(Map<String, dynamic> map, String id) {
    Map<String, Bid>? parsedBids;
    if (map['bids'] != null && map['bids'] is Map) {
      parsedBids = {};
      // Iterate over the raw bids map to parse each bid
      (map['bids'] as Map).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          // Pass the key (which is the bid ID) and the value (bid data map)
          parsedBids![key.toString()] = Bid.fromMap(value, key.toString());
        }
      });
    }

    return Project(
      id: id,
      clientId: map['clientId'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      budget: map['budget'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      location: map['location'] ?? '',
      layoutPreferences: List<String>.from(map['layoutPreferences'] ?? []),
      notes: map['notes'],
      status: map['status'] ?? 'open',
      createdAt: DateTime.parse(map['createdAt']),
      bids: parsedBids, // Assign the correctly parsed bids
    );
  }

  // Create a copy with updated fields
  Project copyWith({
    String? id,
    String? clientId,
    String? title,
    String? type,
    String? budget,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    List<String>? layoutPreferences,
    String? notes,
    String? status,
    DateTime? createdAt,
    Map<String, Bid>? bids,
  }) {
    return Project(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      title: title ?? this.title,
      type: type ?? this.type,
      budget: budget ?? this.budget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      layoutPreferences: layoutPreferences ?? this.layoutPreferences,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      bids: bids ?? this.bids,
    );
  }
}