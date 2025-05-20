import 'package:flutter/material.dart';

class BidFormValidator {
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validateCost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your proposed cost';
    }

    // Remove commas if present (for formatting)
    final cleanValue = value.replaceAll(',', '');

    // Check if it's a valid number
    if (double.tryParse(cleanValue) == null) {
      return 'Please enter a valid amount';
    }

    // Check if it's positive
    if (double.parse(cleanValue) <= 0) {
      return 'Amount must be greater than zero';
    }

    return null;
  }

  /// Validates phone number (optional)
  String? validatePhone(String? value) {
    // If empty, it's optional so return null (valid)
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Pakistani phone format validation
    // Allowing formats like +92xxxxxxxxxx, 0092xxxxxxxxxx, 03xxxxxxxxx
    final phoneRegExp = RegExp(
      r'^(?:\+92|0092|0)([0-9]{9,10})$',
    );

    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates email (optional)
  String? validateEmail(String? value) {
    // If empty, it's optional so return null (valid)
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Simple email validation
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates URL (optional)
  String? validateUrl(String? value) {
    // If empty, it's optional so return null (valid)
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // URL validation (simplified)
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates the timeline (ensures it mentions timeframe or milestones)
  String? validateTimeline(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please outline your project timeline';
    }

    // Check if timeline mentions days, weeks, months or milestones
    final timeKeywords = RegExp(
      r'day|week|month|milestone|phase|stage|timeline|deadline|schedule',
      caseSensitive: false,
    );

    if (!timeKeywords.hasMatch(value)) {
      return 'Please include specific timeframes or milestones';
    }

    return null;
  }

  /// Validates that terms are accepted
  String? validateTermsAccepted(bool? value) {
    if (value != true) {
      return 'You must accept the terms and conditions';
    }
    return null;
  }
}