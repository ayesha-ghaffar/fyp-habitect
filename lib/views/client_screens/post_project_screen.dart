import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final ProjectPostingService _projectPostingService = ProjectPostingService();

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
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    if (selectedProjectType == null) {
      showErrorMessage('Please select a project type');
      return;
    }

    if (budgetController.text.isEmpty) {
      showErrorMessage('Please enter your budget');
      return;
    }

    if (locationController.text.isEmpty) {
      showErrorMessage('Please enter project location');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: isSubmitting ? null : goBack,
        ),
        title: const Text(
          'Post Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.grey),
            onPressed: isSubmitting ? null : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Post Project Help'),
                  content: const Text('Fill in the form to find architects for your project. The more details you provide, the better matches you\'ll receive.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
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
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Start Your Dream Project',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fill in the details below to help architects understand your vision better.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: titleController,
          enabled: !isSubmitting,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'Enter project title (optional)',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.title, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Required)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.5,
          children: [
            _buildProjectTypeItem('New Construction', Icons.home),
            _buildProjectTypeItem('Renovation/Remodeling', Icons.business),
            _buildProjectTypeItem('Interior Design', Icons.grid_view),
            _buildProjectTypeItem('Addition/Expansion', Icons.nature),
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
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                ),
                textAlign: TextAlign.center,
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Required)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: budgetController,
          enabled: !isSubmitting,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'e.g., \$50,000 - \$100,000',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Start date required)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Start Date',
                value: startDate,
                onTap: () => _selectDate(context, true),
                isRequired: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'End Date (Optional)',
                value: endDate,
                onTap: () => _selectDate(context, false),
                isRequired: false,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: isSubmitting ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('MMM dd, yyyy').format(value)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 13,
                      color: value != null ? Colors.black : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Required)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: locationController,
          enabled: !isSubmitting,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'Enter city, state, or full address',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  preference,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: notesController,
          enabled: !isSubmitting,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'Tell us more about your project...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            counterText: '$characterCount/500',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : submitProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Post Project',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}