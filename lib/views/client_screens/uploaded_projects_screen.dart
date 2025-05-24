// lib/screens/uploaded_projects_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/models/project_model.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/views/client_screens/project_details_screen.dart';
import 'package:fyp/views/client_screens/project_bids_screen.dart';
import 'package:fyp/views/svg_icon.dart';

class UploadedProjectsScreen extends StatefulWidget {
  const UploadedProjectsScreen({Key? key}) : super(key: key);

  @override
  State<UploadedProjectsScreen> createState() => _UploadedProjectsScreenState();
}

class _UploadedProjectsScreenState extends State<UploadedProjectsScreen> {
  late Future<List<Project>> _uploadedProjectsFuture;
  String? _currentClientId;
  List<Project> allProjects = [];
  List<Project> filteredProjects = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('UploadedProjectsScreen initState called');
    _loadClientIdAndProjects();
  }

  void _loadClientIdAndProjects() async {
    print('Loading client ID and projects...');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User found: ${user.uid}');
      setState(() {
        _currentClientId = user.uid;
        _uploadedProjectsFuture = _fetchUploadedProjects(user.uid);
      });
    } else {
      print('No user logged in');
      setState(() {
        _currentClientId = null;
        _uploadedProjectsFuture = Future.value([]);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to view your projects.')),
          );
        }
      });
    }
  }

  Future<List<Project>> _fetchUploadedProjects(String clientId) async {
    try {
      setState(() {
        isLoading = true;
      });

      print('Fetching projects for client: $clientId');
      final projects = await ProjectPostingService().getProjectsByClient(clientId);
      print('Found ${projects.length} projects');

      setState(() {
        allProjects = projects;
        filteredProjects = projects;
        isLoading = false;
      });

      return projects;
    } catch (e) {
      print('Error fetching projects: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load projects: $e')),
        );
      }
      return [];
    }
  }

  void _filterProjects() {
    setState(() {
      filteredProjects = allProjects.where((project) {
        final matchesSearch = searchQuery.isEmpty ||
            project.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            project.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
            project.type.toLowerCase().contains(searchQuery.toLowerCase()) ||
            project.status.toLowerCase().contains(searchQuery.toLowerCase());

        return matchesSearch;
      }).toList();
    });
  }

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
        return Theme.of(context).colorScheme.secondary;
      case 'renovation/remodeling':
        return Theme.of(context).colorScheme.primary;
      case 'commercial':
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Theme.of(context).colorScheme.tertiary;
      case 'in progress':
        return Theme.of(context).colorScheme.tertiaryFixedDim;
      case 'completed':
        return Theme.of(context).colorScheme.primary;
      case 'cancelled':
        return Theme.of(context).colorScheme.secondary;
      default:
        return Colors.grey;
    }
  }

  String _formatBudget(String budget) {
    if (!budget.toLowerCase().contains('pkr')) {
      return 'PKR $budget';
    }
    return budget;
  }

  String _formatDeadline(DateTime? endDate) {
    if (endDate == null) {
      return 'No deadline specified';
    }

    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;

    if (difference < 0) {
      return 'Deadline passed';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference < 30) {
      return 'Due in $difference days';
    } else {
      final months = (difference / 30).round();
      return 'Due in $months month${months > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('UploadedProjectsScreen build called');

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: _currentClientId == null
          ? _buildNotLoggedInView()
          : Column(
        children: [
          // Search Section (sticky)
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  _filterProjects();
                },
                decoration: InputDecoration(
                  hintText: 'Search your projects...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                    child: SvgIcon(
                      iconName: 'search',
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Projects List
          Expanded(
            child: FutureBuilder<List<Project>>(
              future: _uploadedProjectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
                  return _buildLoadingView();
                } else if (snapshot.hasError) {
                  return _buildErrorView(snapshot.error.toString());
                } else if (!snapshot.hasData || filteredProjects.isEmpty) {
                  return _buildEmptyView();
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await _fetchUploadedProjects(_currentClientId!);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildProjectCard(project),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'You need to be logged in to view your projects.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              print('Navigate to Login Screen');
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Log In', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your projects...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadClientIdAndProjects();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No projects uploaded yet.'
                : 'No projects match your search.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () {
                print('Navigate to Create New Project Screen');
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Upload New Project', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final categoryColor = _getCategoryColor(project.type);
    final statusColor = _getStatusColor(project.status);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project image
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              image: DecorationImage(
                image: AssetImage(_getProjectImage(project.type)),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    project.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Project details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Location row
                Row(
                  children: [
                    SvgIcon(
                      iconName: 'location',
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category and budget
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        project.type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: categoryColor,
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
                        _formatBudget(project.budget),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.tertiaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),

                // Deadline
                if (project.endDate != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        SvgIcon(
                          iconName: 'schedule',
                          size: 16,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Deadline: ${_formatDeadline(project.endDate)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bids count
                if (project.bids != null && project.bids!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.business_center,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${project.bids!.length} bid${project.bids!.length != 1 ? 's' : ''} received",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Description
                if (project.notes != null && project.notes!.isNotEmpty)
                  Text(
                    project.notes!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailsScreen(projectId: project.id!),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectBidsScreen(
                                projectId: project.id!,
                                projectTitle: project.title,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('View Bids (${project.bids?.length ?? 0})'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}