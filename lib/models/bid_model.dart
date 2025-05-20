import 'package:flutter/material.dart';

enum BidStatus {
  pending,
  active,
  rejected,
}

class Bid {
  final String id;
  final String projectTitle;
  final String projectCategory;
  final String projectBudget;
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
    required this.projectTitle,
    required this.projectCategory,
    required this.projectBudget,
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

  // Convert Bid to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectTitle': projectTitle,
      'projectCategory': projectCategory,
      'projectBudget': projectBudget,
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
      'status': status.index,
    };
  }

  // Create a Bid from a Map
  factory Bid.fromMap(Map<String, dynamic> map) {
    return Bid(
      id: map['id'],
      projectTitle: map['projectTitle'],
      projectCategory: map['projectCategory'],
      projectBudget: map['projectBudget'],
      summary: map['summary'],
      approach: map['approach'],
      proposedSolution: map['proposedSolution'],
      timeline: map['timeline'],
      cost: map['cost'],
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      additionalComments: map['additionalComments'],
      submissionDate: DateTime.fromMillisecondsSinceEpoch(map['submissionDate']),
      status: BidStatus.values[map['status']],
    );
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
}