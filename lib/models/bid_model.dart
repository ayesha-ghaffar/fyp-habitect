// lib/models/bid_model.dart
import 'package:flutter/material.dart';

enum BidStatus {
  pending,
  active,
  rejected,
}

class Bid {
  final String id; // This is the ID of the bid document itself
  final String projectId; // <--- This MUST be present for ProjectPostingService to work
  final String architectId; // <--- This MUST be present for ProjectPostingService to work
  final String summary;
  final String approach;
  final String proposedSolution;
  final String timeline;
  final double cost;
  final String? phone;
  final String? email;
  final String? website;
  final String? additionalComments;
  final DateTime submissionDate;
  BidStatus status;

  Bid({
    required this.id,
    required this.projectId, // <--- Required in constructor
    required this.architectId, // <--- Required in constructor
    required this.summary,
    required this.approach,
    required this.proposedSolution,
    required this.timeline,
    required this.cost,
    this.phone,
    this.email,
    this.website,
    this.additionalComments,
    required this.submissionDate,
    this.status = BidStatus.pending,
  });

  // Convert Bid to a Map for storage (excluding 'id' as it's the document key)
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId, // <--- Include projectId in map
      'architectId': architectId, // <--- Include architectId in map
      'summary': summary,
      'approach': approach,
      'proposedSolution': proposedSolution,
      'timeline': timeline,
      'cost': cost,
      'phone': phone,
      'email': email,
      'website': website,
      'additionalComments': additionalComments,
      'submissionDate': submissionDate.millisecondsSinceEpoch,
      'status': status.name,
    };
  }

  // Create a Bid from a Map, accepting the ID separately
  factory Bid.fromMap(Map<String, dynamic> map, String id) {
    return Bid(
      id: id,
      projectId: map['projectId'] ?? '', // <--- Parse projectId from map
      architectId: map['architectId'] ?? '', // <--- Parse architectId from map
      summary: map['summary'] ?? '',
      approach: map['approach'] ?? '',
      proposedSolution: map['proposedSolution'] ?? '',
      timeline: map['timeline'] ?? '',
      cost: (map['cost'] ?? 0.0).toDouble(),
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      additionalComments: map['additionalComments'],
      submissionDate: DateTime.fromMillisecondsSinceEpoch(map['submissionDate'] ?? 0),
      status: _parseStatus(map['status']),
    );
  }
  static BidStatus _parseStatus(dynamic statusValue) {
    if (statusValue == null) return BidStatus.pending;

    // Handle both string and integer values for backward compatibility
    if (statusValue is int) {
      return BidStatus.values[statusValue.clamp(0, BidStatus.values.length - 1)];
    }

    String statusString = statusValue.toString().toLowerCase();
    switch (statusString) {
      case 'active':
        return BidStatus.active;
      case 'rejected':
        return BidStatus.rejected;
      case 'pending':
      default:
        return BidStatus.pending;
    }
  }

  // Helper method to get status color
  Color getStatusColor() {
    switch (status) {
      case BidStatus.pending:
        return Colors.orange;
      case BidStatus.active:
        return Colors.green;
      case BidStatus.rejected:
        return Colors.red;
    }
  }

  // Helper method to get status text
  String getStatusText() {
    switch (status) {
      case BidStatus.pending:
        return 'Pending';
      case BidStatus.active:
        return 'Active';
      case BidStatus.rejected:
        return 'Rejected';
    }
  }

  // Add copyWith for Bid (important for immutability and updates)
  Bid copyWith({
    String? id,
    String? projectId, // <--- Add projectId to copyWith
    String? architectId, // <--- Add architectId to copyWith
    String? summary,
    String? approach,
    String? proposedSolution,
    String? timeline,
    double? cost,
    String? phone,
    String? email,
    String? website,
    String? additionalComments,
    DateTime? submissionDate,
    BidStatus? status,
  }) {
    return Bid(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId, // <--- Assign projectId
      architectId: architectId ?? this.architectId, // <--- Assign architectId
      summary: summary ?? this.summary,
      approach: approach ?? this.approach,
      proposedSolution: proposedSolution ?? this.proposedSolution,
      timeline: timeline ?? this.timeline,
      cost: cost ?? this.cost,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      additionalComments: additionalComments ?? this.additionalComments,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
    );
  }
}