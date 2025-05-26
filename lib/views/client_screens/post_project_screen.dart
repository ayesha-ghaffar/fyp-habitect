import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/models/project_model.dart';

class PostProject extends StatefulWidget {
  final Function()? onProjectPosted;
  final Function()? onBack;

  const PostProject({
    Key? key,
    this.onProjectPosted,
    this.onBack,
  }) : super(key: key);

  @override
  State<PostProject> createState() => _PostProjectState();
}

class _PostProjectState extends State<PostProject> {
  String? selectedProjectType;
  List<String> selectedLayoutPreferences = [];
  final budgetController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();
  final titleController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  int characterCount = 0;
  bool isSubmitting = false;

  // Add a GlobalKey for the form
  final _formKey = GlobalKey<FormState>();

  final ProjectPostingService _projectPostingService = ProjectPostingService();

  // Green theme colors matching the UI with custom dark green
  static const Color primaryGreen = Color(0xFF7CB342);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color darkGreen = Color(0xFF6B8E23); // Updated to your specified color
  static const Color backgroundGreen = Color(0xFFF1F8E9);
  static const Color accentGreen = Color(0xFFCDDC39);

  @override
  void initState() {
    super.initState();
    notesController.addListener(() {
      setState(() {
        characterCount = notesController.text.length;
      });
    });
  }

  @override
  void dispose() {
    budgetController.dispose();
    locationController.dispose();
    notesController.dispose();
    titleController.dispose();
    super.dispose();
  }

  void goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.pop(context);
    }
  }

  void showSuccessMessage(String projectId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Project posted successfully! ID: ${projectId.substring(0, 8)}...'),
            ),
          ],
        ),
        backgroundColor: darkGreen, // Using dark green for success messages
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (widget.onProjectPosted != null) {
      widget.onProjectPosted!();
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String generateProjectTitle() {
    if (selectedProjectType == null || locationController.text.isEmpty) {
      return 'New Project';
    }

    String typeMap = {
      'New Construction': 'New Construction',
      'Renovation/Remodeling': 'Renovation',
      'Interior Design': 'Interior Design',
      'Addition/Expansion': 'Expansion',
    }[selectedProjectType!] ?? selectedProjectType!;

    return '$typeMap Project in ${locationController.text}';
  }

  Future<void> submitProject() async {
    // Validate form inputs
    if (!_formKey.currentState!.validate()) {
      // If the form is invalid, show an error message for missing required fields
      if (selectedProjectType == null) {
        showErrorMessage('Please select a project type');
      }
      if (startDate == null) {
        showErrorMessage('Please select a start date');
      }
      return;
    }

    // Additional validation for project type and start date
    if (selectedProjectType == null) {
      showErrorMessage('Please select a project type');
      return;
    }

    if (startDate == null) {
      showErrorMessage('Please select a start date');
      return;
    }

    // Check if user is authenticated
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      showErrorMessage('Please log in to post a project');
      return;
    }

    // Check if user can post projects (only clients)
    final canPost = await _projectPostingService.canUserPostProject(currentUser.uid);
    if (!canPost) {
      showErrorMessage('Only clients can post projects');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Create project object
      final project = Project(
        clientId: currentUser.uid,
        title: titleController.text.isNotEmpty
            ? titleController.text
            : generateProjectTitle(),
        type: selectedProjectType!,
        budget: budgetController.text,
        startDate: startDate!,
        endDate: endDate,
        location: locationController.text,
        layoutPreferences: selectedLayoutPreferences,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        createdAt: DateTime.now(),
      );

      // Save to Firebase
      final projectId = await _projectPostingService.createProject(project);

      // Show success message
      showSuccessMessage(projectId);

      // Reset form
      setState(() {
        selectedProjectType = null;
        selectedLayoutPreferences = [];
        budgetController.clear();
        locationController.clear();
        notesController.clear();
        titleController.clear();
        startDate = null;
        endDate = null;
        isSubmitting = false;
      });

    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      showErrorMessage('Failed to post project: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: isSubmitting ? null : goBack,
        ),
        title: const Text(
          'Post Project',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: darkGreen), // Using dark green for info icon
            onPressed: isSubmitting ? null : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Post Project Help'),
                  content: const Text('Fill in the details below to help architects understand your vision better. The more details you provide, the better matches you\'ll receive.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: darkGreen), // Using dark green for dialog button
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form( // Wrap with Form widget
            key: _formKey, // Assign the form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildProjectTitleSection(),
                const SizedBox(height: 24),
                _buildProjectTypeSection(),
                const SizedBox(height: 24),
                _buildBudgetSection(),
                const SizedBox(height: 24),
                _buildTimelineSection(),
                const SizedBox(height: 24),
                _buildLocationSection(),
                const SizedBox(height: 24),
                _buildLayoutPreferencesSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkGreen, primaryGreen], // Using dark green as starting color
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.3), // Using dark green for shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Ready to See Your Ideas Take Shape? Begin Here!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fill in the details below to help architects understand your vision better.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional - Auto-generated if left empty',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: titleController,
          enabled: !isSubmitting,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter project title (optional)',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: darkGreen, width: 2), // Using dark green for focused border
            ),
            prefixIcon: Icon(Icons.title, color: darkGreen), // Using dark green for icon
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Project Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Required)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // No direct validator for GridView, validation will be handled in submitProject
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildProjectTypeItem('New Construction', Icons.home_work),
            _buildProjectTypeItem('Renovation/Remodeling', Icons.build),
            _buildProjectTypeItem('Interior Design', Icons.design_services),
            _buildProjectTypeItem('Addition/Expansion', Icons.add_home),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectTypeItem(String type, IconData icon) {
    final isSelected = selectedProjectType == type;

    return GestureDetector(
      onTap: isSubmitting ? null : () {
        setState(() {
          selectedProjectType = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? darkGreen : Colors.grey.shade300, // Using dark green for selected border
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? darkGreen.withOpacity(0.1) : Colors.white, // Using dark green for selected background
          boxShadow: isSelected ? [
            BoxShadow(
              color: darkGreen.withOpacity(0.2), // Using dark green for shadow
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? darkGreen : Colors.grey.shade600, // Using dark green for selected icon
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? darkGreen : Colors.black87, // Using dark green for selected text
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Budget Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Required)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: budgetController,
          enabled: !isSubmitting,
          keyboardType: TextInputType.number, // Set keyboard type to number
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Allow only digits
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'e.g., 50000-100000 (numeric only)',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: darkGreen, width: 2), // Using dark green for focused border
            ),
            prefixIcon: Icon(Icons.attach_money, color: darkGreen), // Using dark green for icon
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your budget';
            }
            // Optional: Add more complex budget validation (e.g., numeric range, format)
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Start date required)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Start Date',
                value: startDate,
                onTap: () => _selectDate(context, true),
                isRequired: true,
                errorText: startDate == null ? 'Please select a start date' : null, // Pass error text
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'End Date (Optional)',
                value: endDate,
                onTap: () => _selectDate(context, false),
                isRequired: false,
                errorText: null, // No error text for optional end date
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required bool isRequired,
    String? errorText, // Added errorText parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isSubmitting ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null ? Colors.red.shade600 : Colors.grey.shade300, // Show red border on error
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: darkGreen), // Using dark green for calendar icon
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('MMM dd, yyyy').format(value)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) // Display error text if present
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: darkGreen, // Using dark green for date picker primary color
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          // Clear end date if it's before start date
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        } else {
          // Only allow end date if start date is selected and end date is after start date
          if (startDate != null && picked.isAfter(startDate!)) {
            endDate = picked;
          } else if (startDate == null) {
            showErrorMessage('Please select a start date first');
          } else {
            showErrorMessage('End date must be after start date');
          }
        }
      });
    }
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Project Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Required)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: locationController,
          enabled: !isSubmitting,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter city, state, or full address',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: darkGreen, width: 2), // Using dark green for focused border
            ),
            prefixIcon: Icon(Icons.location_on, color: darkGreen), // Using dark green for location icon
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter project location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLayoutPreferencesSection() {
    final preferences = [
      'Open Floor Plan',
      'Traditional Layout',
      'Modern Style',
      'Eco-Friendly',
      'Family-Friendly',
      'Minimalist',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layout Preferences',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional - Select all that apply',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: preferences.map((preference) {
            final isSelected = selectedLayoutPreferences.contains(preference);
            return GestureDetector(
              onTap: isSubmitting ? null : () {
                setState(() {
                  if (isSelected) {
                    selectedLayoutPreferences.remove(preference);
                  } else {
                    selectedLayoutPreferences.add(preference);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? darkGreen : Colors.white, // Using dark green for selected preference
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? darkGreen : Colors.grey.shade300, // Using dark green for selected border
                    width: 2,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: darkGreen.withOpacity(0.3), // Using dark green for shadow
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  preference,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional - Describe your vision, specific requirements, or any other details',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: notesController,
          enabled: !isSubmitting,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Tell us more about your project...',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: darkGreen, width: 2), // Using dark green for focused border
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkGreen, primaryGreen], // Using dark green as starting color in gradient
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.4), // Using dark green for button shadow
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : submitProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Post Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}