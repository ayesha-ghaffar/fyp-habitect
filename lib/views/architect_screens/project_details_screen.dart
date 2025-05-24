// lib/views/project_details_page.dart
import 'package:flutter/material.dart';
import 'package:fyp/models/project_model.dart';
import 'package:fyp/views/svg_icon.dart';
import 'package:intl/intl.dart';

class ProjectDetailsPage extends StatelessWidget {
  final Project project;

  const ProjectDetailsPage({
    Key? key,
    required this.project,
  }) : super(key: key);

  String _getProjectImage(String projectType) {
    switch (projectType.toLowerCase()) {
      case 'new construction':
        return "assets/images/Hillside Residence.jpg";
      case 'renovation/remodeling':
        return "assets/images/Boutique.jpg";
      case 'commercial':
        return "assets/images/Nexus Office.jpg";
      default:
        return "assets/images/Hillside Residence.jpg";
    }
  }

  Color _getCategoryColor(String projectType) {
    switch (projectType.toLowerCase()) {
      case 'new construction':
        return const Color(0xFFE2725B);
      case 'renovation/remodeling':
        return Colors.blue;
      case 'commercial':
        return Colors.purple;
      default:
        return const Color(0xFFE2725B);
    }
  }

  String _formatBudget(String budget) {
    if (!budget.toLowerCase().contains('pkr')) {
      return 'PKR $budget';
    }
    return budget;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(project.type);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getProjectImage(project.type)),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Title
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category and Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.type,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: project.status == 'open'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: project.status == 'open' ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Project Details Section
                  _buildDetailSection(
                    title: 'Project Details',
                    children: [
                      _buildDetailRow(
                        icon: 'location',
                        label: 'Location',
                        value: project.location,
                      ),
                      _buildDetailRow(
                        icon: 'money-dollar',
                        label: 'Budget',
                        value: _formatBudget(project.budget),
                      ),
                      _buildDetailRow(
                        icon: 'calendar',
                        label: 'Start Date',
                        value: _formatDate(project.startDate),
                      ),
                      if (project.endDate != null)
                        _buildDetailRow(
                          icon: 'schedule',
                          label: 'End Date',
                          value: _formatDate(project.endDate!),
                        ),
                      _buildDetailRow(
                        icon: 'building',
                        label: 'Project Type',
                        value: project.type,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Layout Preferences Section
                  if (project.layoutPreferences.isNotEmpty)
                    _buildDetailSection(
                      title: 'Layout Preferences',
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: project.layoutPreferences.map((preference) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                preference,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Description Section
                  if (project.notes != null && project.notes!.isNotEmpty)
                    _buildDetailSection(
                      title: 'Description',
                      children: [
                        Text(
                          project.notes!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Project Timeline
                  _buildDetailSection(
                    title: 'Timeline',
                    children: [
                      _buildTimelineItem(
                        'Project Posted',
                        _formatDate(project.createdAt),
                        true,
                      ),
                      if (project.endDate != null)
                        _buildTimelineItem(
                          'Target Completion',
                          _formatDate(project.endDate!),
                          false,
                        ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate to bid form or handle action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E23),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SvgIcon(
            iconName: icon,
            size: 20,
            color: const Color(0xFF6B8E23),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF6B8E23) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}