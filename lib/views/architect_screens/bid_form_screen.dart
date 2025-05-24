import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/views/svg_icon.dart';
import 'package:fyp/services/bid_form_validation.dart';
import 'package:fyp/models/bid_model.dart';

class SubmitBidForm extends StatefulWidget {
  final String? projectId; // Add projectId parameter
  final String projectTitle;
  final String projectCategory;
  final String projectBudget;
  final Bid? existingBid;

  const SubmitBidForm({
    Key? key,
    required this.projectId, // Make projectId required
    required this.projectTitle,
    required this.projectCategory,
    required this.projectBudget,
    this.existingBid,
  }) : super(key: key);

  @override
  State<SubmitBidForm> createState() => _SubmitBidFormState();
}

class _SubmitBidFormState extends State<SubmitBidForm> {
  final _formKey = GlobalKey<FormState>();
  final BidFormValidator _validator = BidFormValidator();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form controllers
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _approachController = TextEditingController();
  final TextEditingController _proposalController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _termsController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  bool _termsAccepted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    if (widget.existingBid != null) {
      final bid = widget.existingBid!;
      _summaryController.text = bid.summary;
      _approachController.text = bid.approach;
      _proposalController.text = bid.proposedSolution;
      _timelineController.text = bid.timeline;
      _costController.text = bid.cost.toString();
      _phoneController.text = bid.phone ?? '';
      _emailController.text = bid.email ?? '';
      _websiteController.text = bid.website ?? '';
      _commentsController.text = bid.additionalComments ?? '';
      _termsAccepted = true; // Auto-accept terms for existing bids
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _approachController.dispose();
    _proposalController.dispose();
    _timelineController.dispose();
    _costController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _termsController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgIcon(iconName: 'close', color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.existingBid != null ? 'Edit Bid' : 'Submit Bid',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE0E0E0),
            height: 0.25,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Project Header Info
            _buildProjectHeader(),
            const SizedBox(height: 24),

            // Brief Proposal / Summary
            _buildSectionHeader('Brief Proposal Summary', true),
            _buildTextFormField(
              controller: _summaryController,
              hintText: 'Provide a brief overview of your proposal...',
              maxLines: 3,
              validator: _validator.validateRequired,
            ),
            const SizedBox(height: 24),

            // Detailed Proposal Section
            _buildSectionHeader('Detailed Proposal', true),

            // Approach
            _buildSubsectionHeader('Approach'),
            _buildTextFormField(
              controller: _approachController,
              hintText: 'Describe your approach to this project...',
              maxLines: 4,
              validator: _validator.validateRequired,
            ),
            const SizedBox(height: 16),

            // Proposed Solution
            _buildSubsectionHeader('Proposed Solution'),
            _buildTextFormField(
              controller: _proposalController,
              hintText: 'Detail your proposed solution...',
              maxLines: 4,
              validator: _validator.validateRequired,
            ),
            const SizedBox(height: 16),

            // Timeline
            _buildSubsectionHeader('Project Timeline'),
            _buildTextFormField(
              controller: _timelineController,
              hintText: 'Outline key milestones and timeline...',
              maxLines: 4,
              validator: _validator.validateRequired,
            ),
            const SizedBox(height: 16),

            // Cost
            _buildSubsectionHeader('Proposed Cost'),
            _buildTextFormField(
              controller: _costController,
              hintText: 'Your proposed budget (PKR)...',
              keyboardType: TextInputType.number,
              validator: _validator.validateCost,
            ),
            const SizedBox(height: 24),

            // Contact Information
            _buildSectionHeader('Contact Information (Optional)', false),

            // Phone
            _buildSubsectionHeader('Phone'),
            _buildTextFormField(
              controller: _phoneController,
              hintText: 'Your contact number',
              keyboardType: TextInputType.phone,
              validator: _validator.validatePhone,
            ),
            const SizedBox(height: 16),

            // Email
            _buildSubsectionHeader('Email'),
            _buildTextFormField(
              controller: _emailController,
              hintText: 'Your email address',
              keyboardType: TextInputType.emailAddress,
              validator: _validator.validateEmail,
            ),
            const SizedBox(height: 16),

            // Website
            _buildSubsectionHeader('Website'),
            _buildTextFormField(
              controller: _websiteController,
              hintText: 'Your website URL',
              keyboardType: TextInputType.url,
              validator: _validator.validateUrl,
            ),
            const SizedBox(height: 24),

            // Terms and Conditions
            _buildSectionHeader('Terms and Conditions', true),
            _buildTermsAndConditions(),
            const SizedBox(height: 24),

            // Additional Comments
            _buildSectionHeader('Additional Comments', false),
            _buildTextFormField(
              controller: _commentsController,
              hintText: 'Any additional information you want to share...',
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E23),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  widget.existingBid != null ? 'Update Bid' : 'Submit Bid',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.projectTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2725B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  widget.projectCategory,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE2725B),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  widget.projectBudget,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E897B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubsectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Text(
            'By submitting this bid, you agree to the terms and conditions of Habitect. This includes your commitment to complete the project as described in your proposal if selected, maintaining professional conduct, ensuring compliance with all relevant laws and regulations, and adhering to the project timeline.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _termsAccepted,
              activeColor: const Color(0xFF6B8E23),
              onChanged: (value) {
                setState(() {
                  _termsAccepted = value ?? false;
                });
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _termsAccepted = !_termsAccepted;
                  });
                },
                child: const Text(
                  'I agree to the terms and conditions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_termsAccepted)
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 4.0),
            child: Text(
              'You must accept the terms and conditions',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Bid _constructBidFromForm(String bidId, String architectId, int submissionDate) {
    return Bid(
      id: bidId,
      projectId: widget.projectId!,
      architectId: architectId,
      summary: _summaryController.text.trim(),
      approach: _approachController.text.trim(),
      proposedSolution: _proposalController.text.trim(),
      timeline: _timelineController.text.trim(),
      cost: double.tryParse(_costController.text.replaceAll(',', '').replaceAll('PKR', '').trim()) ?? 0.0,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      additionalComments: _commentsController.text.trim().isEmpty ? null : _commentsController.text.trim(),
      submissionDate: DateTime.fromMillisecondsSinceEpoch(submissionDate),
      status: widget.existingBid?.status ?? BidStatus.pending,
    );
  }

  Future<void> _submitBid() async {
    if (!_termsAccepted) {
      setState(() {});
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a bid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Debug cost parsing
      print('Raw cost text: "${_costController.text}"');
      print('Cost text after removing commas: "${_costController.text.replaceAll(',', '')}"');

      final double cost = double.tryParse(_costController.text.replaceAll(',', '').replaceAll('PKR', '').trim()) ?? 0.0;
      print('Parsed cost: $cost');

      // Use existing bid ID if editing, otherwise generate new one
      final String bidId = widget.existingBid?.id ?? _database.child('bids').push().key!;

      // Handle submission date properly
      int submissionDate;
      if (widget.existingBid != null) {
        // For existing bids, preserve the original submission date
        try {
          submissionDate = widget.existingBid!.submissionDate.millisecondsSinceEpoch;
          print('Using existing submission date: $submissionDate');
        } catch (e) {
          print('Error handling submission date: $e');
          submissionDate = DateTime.now().millisecondsSinceEpoch;
        }
      } else {
        // For new bids, use current timestamp
        submissionDate = DateTime.now().millisecondsSinceEpoch;
        print('Using new submission date: $submissionDate');
      }

      final Map<String, dynamic> bidData = {
        'projectId': widget.projectId,
        'architectId': currentUser.uid,
        'summary': _summaryController.text.trim(),
        'approach': _approachController.text.trim(),
        'proposedSolution': _proposalController.text.trim(),
        'timeline': _timelineController.text.trim(),
        'cost': cost,
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'website': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        'additionalComments': _commentsController.text.trim().isEmpty ? null : _commentsController.text.trim(),
        'submissionDate': submissionDate,
        'status': widget.existingBid?.status.name ?? 'pending',
        'lastModified': DateTime.now().millisecondsSinceEpoch,
      };

      // Debug: Print the update data
      print('=== BID UPDATE DEBUG ===');
      print('Bid ID: $bidId');
      print('Project ID: ${widget.projectId}');
      print('User ID: ${currentUser.uid}');
      print('Is Edit: ${widget.existingBid != null}');
      print('Updating bid with data: $bidData');

      // Try updating each path separately to identify which one fails
      try {
        // First, update the main bid data
        await _database.child('bids').child(bidId).set(bidData);
        print('✅ Main bid data updated successfully');

        // Then update the project's bid reference
        final projectBidData = {
          'architectId': currentUser.uid,
          'cost': cost,
          'timeline': _timelineController.text.trim(),
          'status': widget.existingBid?.status.name ?? 'pending',
          'submissionDate': submissionDate,
          'lastModified': DateTime.now().millisecondsSinceEpoch,
        };

        await _database.child('projects').child(widget.projectId!).child('bids').child(bidId).set(projectBidData);
        print('✅ Project bid reference updated successfully');

        // Verify the data was actually written
        final verifySnapshot = await _database.child('bids').child(bidId).get();
        if (verifySnapshot.exists) {
          final verifyData = verifySnapshot.value as Map<dynamic, dynamic>;
          print('✅ Verification - Data exists in database:');
          print('   Cost in DB: ${verifyData['cost']}');
          print('   Summary in DB: ${verifyData['summary']?.toString().substring(0, 50)}...');
          print('   Last Modified: ${verifyData['lastModified']}');
        } else {
          print('❌ Verification failed - Data not found in database');
        }

      } catch (updateError) {
        print('❌ Detailed update error: $updateError');
        throw updateError;
      }

      // Construct the updated Bid object
      final updatedBid = _constructBidFromForm(bidId, currentUser.uid, submissionDate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingBid != null ? 'Bid updated successfully!' : 'Bid submitted successfully!'),
            backgroundColor: const Color(0xFF6B8E23),
            duration: const Duration(seconds: 3),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop(updatedBid); // Return the updated Bid object
          }
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error updating/submitting bid: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${widget.existingBid != null ? 'updating' : 'submitting'} bid: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}