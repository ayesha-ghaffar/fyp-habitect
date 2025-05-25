import 'package:flutter/material.dart';
import 'package:fyp/models/project_model.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/views/client_screens/project_bids_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late Future<Project?> _projectDetailsFuture;

  @override
  void initState() {
    super.initState();
    _projectDetailsFuture = _fetchProjectDetails();
  }

  Future<Project?> _fetchProjectDetails() async {
    try {
      return await ProjectPostingService().getProject(widget.projectId);
    } catch (e) {
      print('Error fetching project details: $e');
      // You might want to show a more user-friendly error here, e.g., a SnackBar
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary color based on the provided green
    const Color primaryGreen = Color(0xFF6B8E23);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen, // Applied new green color
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      body: FutureBuilder<Project?>(
        future: _projectDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryGreen)); // Applied new green color
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Project details not found.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          } else {
            final project = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50), // Keeping this as a dark text color
                        ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      _buildDetailRow(
                        icon: Icons.category,
                        label: 'Project Type',
                        value: project.type,
                      ),
                      _buildDetailRow(
                        icon: Icons.attach_money,
                        label: 'Budget',
                        value: project.budget,
                      ),
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Start Date',
                        value: '${project.startDate.day}/${project.startDate.month}/${project.startDate.year}',
                      ),
                      if (project.endDate != null)
                        _buildDetailRow(
                          icon: Icons.event_busy,
                          label: 'End Date',
                          value: '${project.endDate!.day}/${project.endDate!.month}/${project.endDate!.year}',
                        ),
                      _buildDetailRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: project.location,
                      ),
                      _buildDetailRow(
                        icon: Icons.info_outline,
                        label: 'Status',
                        value: project.status.toUpperCase(),
                        valueColor: project.status == 'open' ? primaryGreen : Colors.orange, // Status color adjusted
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Layout Preferences:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: project.layoutPreferences.map((pref) => Chip(
                          label: Text(pref),
                          backgroundColor: Colors.grey[200],
                        )).toList(),
                      ),
                      if (project.notes != null && project.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Notes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.notes!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectBidsScreen(projectId: project.id!, projectTitle: project.title),
                              ),
                            );
                          },
                          icon: const Icon(Icons.gavel, color: Colors.white),
                          label: Text(
                            'View Bids (${project.bids?.length ?? 0})',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen, // Applied new green color
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black87,
  }) {
    // Define the primary color based on the provided green
    const Color primaryGreen = Color(0xFF6B8E23);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryGreen, size: 20), // Applied new green color
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
