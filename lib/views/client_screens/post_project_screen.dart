import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/models/project_model.dart';
import '../svg_icon.dart';

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

  // Green theme colors matching the bid form
  static const Color primaryGreen = Color(0xFF6B8E23);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color darkGreen = Color(0xFF6B8E23);

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
        content: Text('Project posted successfully! ID: ${projectId.substring(0, 8)}...'),
        backgroundColor: primaryGreen,
        duration: const Duration(seconds: 4),
      ),
    );

    if (widget.onProjectPosted != null) {
      widget.onProjectPosted!();
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
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
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: isSubmitting ? null : goBack,
        ),
        title: const Text(
          'Post Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE0E0E0),
            height: 0.25,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProjectHeader(),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to See Your Ideas Take Shape?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in the details below to help architects understand your vision better.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFF4EBD0),
            ),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    int? maxLength,
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
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: validator,
        enabled: !isSubmitting,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: prefixIcon,
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          counterStyle: maxLength != null ? TextStyle(color: Colors.grey.shade600) : null,
        ),
      ),
    );
  }

  Widget _buildProjectTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Project Title (Optional)', false),
        _buildTextFormField(
          controller: titleController,
          hintText: 'Enter project title (auto-generated if left empty)',
          prefixIcon: Icon(Icons.title_rounded, color: primaryGreen),
        ),
      ],
    );
  }

  Widget _buildProjectTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Project Type', true),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildProjectTypeItem('New Construction', Icons.home_work_rounded),
            _buildProjectTypeItem('Renovation/Remodeling', Icons.build_rounded),
            _buildProjectTypeItem('Interior Design', Icons.design_services_rounded),
            _buildProjectTypeItem('Addition/Expansion', Icons.add_home_rounded),
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
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? primaryGreen.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? primaryGreen : Colors.grey.shade600,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? primaryGreen : Colors.grey.shade600,
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
        _buildSectionHeader('Budget Range', true),
        _buildTextFormField(
          controller: budgetController,
          hintText: 'e.g., PKR 50,000 - 100,000',
          prefixIcon: Icon(Icons.attach_money_rounded, color: primaryGreen),
        ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Timeline', true),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Start Date *',
                value: startDate,
                onTap: () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'End Date (Optional)',
                value: endDate,
                onTap: () => _selectDate(context, false),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isSubmitting ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 18, color: primaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('MMM dd, yyyy').format(value)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null ? Colors.black87 : Colors.grey.shade400,
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryGreen,
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
        _buildSectionHeader('Project Location', true),
        _buildTextFormField(
          controller: locationController,
          hintText: 'Enter city, state, or full address',
          prefixIcon: Icon(Icons.location_on_rounded, color: primaryGreen),
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
        _buildSectionHeader('Layout Preferences (Optional)', false),
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
                  color: isSelected ? primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? primaryGreen : Colors.grey.shade300,
                    width: 2,
                  ),
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
        _buildSectionHeader('Additional Notes (Optional)', false),
        _buildTextFormField(
          controller: notesController,
          hintText: 'Describe your vision, specific requirements, or any other details...',
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : submitProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Post Project',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}