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
      'bids': bids?.map((key, value) => MapEntry(key, value.toMap())) ?? {},
    };
  }

  // Create Project from Map (Firebase data)
  factory Project.fromMap(Map<String, dynamic> map, String id) {
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
      bids: map['bids'] != null
          ? Map<String, Bid>.from(
          map['bids'].map((key, value) => MapEntry(key, Bid.fromMap(value, key)))
      )
          : null,
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

class Bid {
  final String? id;
  final String projectId;
  final String architectId;
  final double cost;
  final String timeline;
  final String status;
  final DateTime createdAt;

  Bid({
    this.id,
    required this.projectId,
    required this.architectId,
    required this.cost,
    required this.timeline,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'architectId': architectId,
      'cost': cost,
      'timeline': timeline,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bid.fromMap(Map<String, dynamic> map, String id) {
    return Bid(
      id: id,
      projectId: map['projectId'] ?? '',
      architectId: map['architectId'] ?? '',
      cost: (map['cost'] ?? 0).toDouble(),
      timeline: map['timeline'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Added missing copyWith method
  Bid copyWith({
    String? id,
    String? projectId,
    String? architectId,
    double? cost,
    String? timeline,
    String? status,
    DateTime? createdAt,
  }) {
    return Bid(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      architectId: architectId ?? this.architectId,
      cost: cost ?? this.cost,
      timeline: timeline ?? this.timeline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}