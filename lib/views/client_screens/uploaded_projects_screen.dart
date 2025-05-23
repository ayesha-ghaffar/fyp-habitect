// lib/screens/uploaded_projects_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:fyp/models/project_model.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/views/client_screens/project_details_screen.dart'; // Import the new details screen
import 'package:fyp/views/client_screens/project_bids_screen.dart'; // Import the new bids screen

class UploadedProjectsScreen extends StatefulWidget {
  const UploadedProjectsScreen({Key? key}) : super(key: key); // No clientId passed in constructor

  @override
  State<UploadedProjectsScreen> createState() => _UploadedProjectsScreenState();
}

class _UploadedProjectsScreenState extends State<UploadedProjectsScreen> {
  late Future<List<Project>> _uploadedProjectsFuture;
  String? _currentClientId; // To store the client ID

  @override
  void initState() {
    super.initState();
    _loadClientIdAndProjects();
  }

  void _loadClientIdAndProjects() async {
    // Get the current user's UID (which is our clientId in this context)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentClientId = user.uid;
        _uploadedProjectsFuture = _fetchUploadedProjects(user.uid);
      });
    } else {
      // Handle the case where no user is logged in
      setState(() {
        _currentClientId = null;
        _uploadedProjectsFuture = Future.value([]); // No projects if no user
      });
      // Optionally show a message to log in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your projects.')),
        );
      });
    }
  }

  Future<List<Project>> _fetchUploadedProjects(String clientId) async {
    try {
      return await ProjectPostingService().getProjectsByClient(clientId);
    } catch (e) {
      print('Error fetching projects: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load projects: $e')),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Uploaded Projects',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C3E50), // Dark blue/grey for app bar
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      body: _currentClientId == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'You need to be logged in to view your projects.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to login screen
                // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                print('Navigate to Login Screen');
              },
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text('Log In', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      )
          : FutureBuilder<List<Project>>(
        future: _uploadedProjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: const Color(0xFF3498DB)));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No projects uploaded yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to the screen where a client can create a new project
                      // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CreateProjectScreen()));
                      print('Navigate to Create New Project Screen');
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text('Upload New Project', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final project = snapshot.data![index];
                return ProjectTile(project: project);
              },
            );
          }
        },
      ),
    );
  }
}

class ProjectTile extends StatelessWidget {
  final Project project;

  const ProjectTile({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50), // Dark blue/grey
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${project.type}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Budget: ${project.budget}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Status: ${project.status.toUpperCase()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: project.status == 'open' ? const Color(0xFF2ECC71) : Colors.orange, // Green for open, orange for others
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      side: const BorderSide(color: Color(0xFF3498DB)), // Accent blue border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Color(0xFF3498DB), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectBidsScreen(projectId: project.id!, projectTitle: project.title),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB), // Accent blue background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'View Bids (${project.bids?.length ?? 0})', // Display bid count
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}