import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  DateTime? startDate;
  DateTime? endDate;
  int characterCount = 0;

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
    super.dispose();
  }

  void goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.pop(context);
    }
  }

  void showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            const Text('Project posted successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (widget.onProjectPosted != null) {
      widget.onProjectPosted!();
    }
  }

  void submitProject() {
    // Validate form inputs here if needed
    bool isValid = selectedProjectType != null &&
        budgetController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        startDate != null;

    if (isValid) {
      showSuccessMessage();
      // Reset form
      setState(() {
        selectedProjectType = null;
        selectedLayoutPreferences = [];
        budgetController.clear();
        locationController.clear();
        notesController.clear();
        startDate = null;
        endDate = null;
      });
    } else {
      // Show validation error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
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
          onPressed: goBack,
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
            onPressed: () {
              // Show help info
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

  Widget _buildProjectTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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
            _buildProjectTypeItem('Residential', Icons.home),
            _buildProjectTypeItem('Commercial', Icons.business),
            _buildProjectTypeItem('Interior', Icons.grid_view),
            _buildProjectTypeItem('Landscape', Icons.nature),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectTypeItem(String type, IconData icon) {
    final isSelected = selectedProjectType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProjectType = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
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
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'Enter your budget',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.grey),
            suffixText: 'USD',
            suffixStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
              'Project Timeline',
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
              child: _buildDatePicker(
                isStartDate: true,
                selectedDate: startDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePicker(
                isStartDate: false,
                selectedDate: endDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker({required bool isStartDate, DateTime? selectedDate}) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: isStartDate ? DateTime.now() : (startDate ?? DateTime.now()),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (date != null) {
          setState(() {
            if (isStartDate) {
              startDate = date;
              if (endDate != null && endDate!.isBefore(date)) {
                endDate = null;
              }
            } else {
              endDate = date;
            }
          });
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('MM/dd/yyyy').format(selectedDate)
                    : isStartDate ? 'Start date' : 'End date (Optional)',
                style: TextStyle(
                  fontSize: 13,
                  color: selectedDate != null ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'Enter project location',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutPreferencesSection() {
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
          'Select one or more options',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
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
            _buildLayoutPreferenceItem('Open Plan', Icons.dashboard_customize),
            _buildLayoutPreferenceItem('Minimalist', Icons.grid_view),
            _buildLayoutPreferenceItem('Traditional', Icons.home),
            _buildLayoutPreferenceItem('Modern', Icons.architecture),
          ],
        ),
      ],
    );
  }

  Widget _buildLayoutPreferenceItem(String type, IconData icon) {
    final isSelected = selectedLayoutPreferences.contains(type);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedLayoutPreferences.remove(type);
          } else {
            selectedLayoutPreferences.add(type);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
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
        const SizedBox(height: 8),
        TextFormField(
          controller: notesController,
          maxLength: 500,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'Share more details about your project...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            counterText: '',
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$characterCount/500',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: submitProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Post Project',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}