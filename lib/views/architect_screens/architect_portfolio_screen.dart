import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fyp/views/svg_icon.dart';
import 'edit_portfolio_screen.dart';
import 'package:fyp/models/portfolio_model.dart';
import 'package:provider/provider.dart';
import 'package:fyp/services/portfolio_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  late PortfolioViewModel _viewModel;
  String _userName = "";

  bool _hasPortfolio = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _specialty = "residential";
  File? _profileImage;
  File? _coverImage;
  bool _isToastVisible = false;
  String _toastMessage = "";

  List<CertificationItem> _certifications = [];
  List<ProjectItem> _projects = [];

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<PortfolioViewModel>(context, listen: false);
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // First get user's name from users collection
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(userId)
            .get();

        if (userSnapshot.exists) {
          final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
          setState(() {
            _userName = userData['name'] ?? '';
          });
        }
      }

      // Then load portfolio
      await _viewModel.loadPortfolio();

      // Update UI based on loaded data
      if (_viewModel.hasProfile && _viewModel.profile != null) {
        final profile = _viewModel.profile!;
        setState(() {
          _nameController.text = profile.name;
          _locationController.text = profile.location;
          _bioController.text = profile.bio;
          _specialty = profile.specialty;
          _certifications = profile.certifications;
          _projects = profile.projects;
          // Note: profileImage and coverImage are not loaded from Firebase yet
          // You'll need to implement image loading separately
        });
      } else {
        // Set default name for new portfolio
        setState(() {
          _nameController.text = _userName;
        });
      }
    } catch (e) {
      _showToast("Error loading data: $e");
    }
  }

  void _showToast(String message) {
    setState(() {
      _toastMessage = message;
      _isToastVisible = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isToastVisible = false;
        });
      }
    });
  }

  // In PortfolioPage, modify the edit button action:
  void _editPortfolio() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPortfolioPage(
          profile: _viewModel.hasProfile ? _viewModel.profile! : Profile(
            name: _nameController.text.isEmpty ? _userName : _nameController.text,
            location: _locationController.text,
            bio: _bioController.text,
            specialty: _specialty,
            profileImage: _profileImage,
            coverImage: _coverImage,
            certifications: _certifications,
            projects: _projects,
          ),
          onSave: (updatedProfile) {
            // The data is already saved to Firebase by EditPortfolioPage
            // Just reload to refresh the UI
            _loadUserData();
            _showToast("Portfolio successfully updated");
          },
        ),
      ),
    );
  }

  String _getSpecialtyName(String value) {
    switch (value) {
      case "modern":
        return "Modern Housing";
      case "traditional":
        return "Traditional Design";
      case "interior":
        return "Interior Design";
      case "renovation":
        return "Renovation/Remodelling";
      case "luxury":
        return "Luxury Housing";
      case "vacation":
        return "Vacation Housing";
      case "sustainable":
        return "Sustainable Design";
      case "accessible":
        return "Accessible/Inclusive Design";
      default:
        return "Residential Architecture";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PortfolioViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: _loadUserData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return !viewModel.hasProfile
              ? _buildEmptyState()
              : _buildPortfolioView();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100),
          SizedBox(
            width: 192,
            height: 192,
            child: Image.asset(
              "assets/images/empty_portfolio.png",
              fit: BoxFit.contain,
            ),
          ),
          const Text(
            "No portfolio found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Start building your profile to attract clients",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _editPortfolio();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8E23),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Create Portfolio",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with edit button
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                color: const Color(0xFF6B8E23).withOpacity(0.1),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _coverImage != null
                                ? FileImage(_coverImage!) as ImageProvider
                                : const AssetImage("assets/images/coverImage.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: ElevatedButton.icon(
                  onPressed: _editPortfolio,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Profile info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF6B8E23),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: _profileImage != null
                            ? Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          color: const Color(0xFFEEEEEE),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name and other text content
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSpecialtyName(_specialty),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B8E23),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Location
                          Row(
                            children: [
                              SvgIcon(
                                iconName: 'location',
                                size: 16,
                                color: Color(0xFF666666),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _locationController.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bio
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _bioController.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(color: Colors.grey.shade200, thickness: 8),

          // Certifications
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Certifications & Awards",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _certifications.length,
                  itemBuilder: (context, index) {
                    final certification = _certifications[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: Color(0xFF6B8E23),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  certification.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  certification.year,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Divider
          Divider(color: Colors.grey.shade200, thickness: 8),

          // Projects
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Portfolio Projects",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project Image
                          Container(
                            height: 192,
                            width: double.infinity,
                            child: (project.isLocalImage && project.imageUrl?.isNotEmpty == true)
                                ? Image.file(
                              File(project.imageUrl!),
                              height: 192,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                                : (project.imageUrl != null)
                                ? Image.asset(
                              project.imageUrl!,
                              height: 192,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              // Placeholder for when imageUrl is null
                              color: Colors.grey,
                              child: Center(
                                child: Icon(Icons.image_not_supported, size: 50),
                              ),
                            ),
                          ),

                          // Project Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  project.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    SvgIcon(
                                      iconName: 'calendar',
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      project.completionDate,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}