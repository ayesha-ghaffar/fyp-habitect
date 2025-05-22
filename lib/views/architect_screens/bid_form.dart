import 'package:flutter/material.dart';
import 'package:fyp/screens/svg_icon.dart';
import 'package:fyp/services/bid_form_validation.dart';

class SubmitBidForm extends StatefulWidget {
  final String projectTitle;
  final String projectCategory;
  final String projectBudget;

  const SubmitBidForm({
    Key? key,
    required this.projectTitle,
    required this.projectCategory,
    required this.projectBudget,
  }) : super(key: key);

  @override
  State<SubmitBidForm> createState() => _SubmitBidFormState();
}

class _SubmitBidFormState extends State<SubmitBidForm> {
  final _formKey = GlobalKey<FormState>();
  final BidFormValidator _validator = BidFormValidator();

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
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgIcon(iconName: 'close', color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Submit Bid',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
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
                onPressed: _submitBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E23),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Bid',
                  style: TextStyle(
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

  void _submitBid() {
    // First check terms acceptance
    if (!_termsAccepted) {
      setState(() {}); // Trigger rebuild to show error message
      return;
    }

    // Then validate the form
    if (_formKey.currentState!.validate()) {
      // Show success dialog/message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bid submitted successfully!'),
          backgroundColor: Color(0xFF6B8E23),
        ),
      );

      // Close the form after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    } else {
      // Scroll to the first error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before submitting'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}