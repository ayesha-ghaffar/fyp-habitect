import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp/services/cloudinary_service.dart';
import 'package:fyp/services/project_posting_service.dart';
import 'package:fyp/models/project_model.dart';
import 'package:fyp/views/svg_icon.dart';
import 'architect_dashboard_screen.dart';
import 'availability_screen.dart';
import 'project_details_screen.dart';
import '../client_screens/profile_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onRefreshNeeded;

  const HomeScreen({super.key, this.onRefreshNeeded});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAvailable = true;

  String userName = "User";
  String? _currentAvatarUrl;
  List<Project> newProjectMatches = [];
  List<Map<String, dynamic>> portfolioProjects = [];
  bool isLoadingProjects = true;
  bool isLoadingPortfolio = true;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ProjectPostingService _projectService = ProjectPostingService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNewProjectMatches();
    _loadPortfolioProjects();
    _loadUserAvatar();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userSnapshot = await _database.child('users').child(userId).get();

        if (userSnapshot.exists) {
          final userData = _convertToStringMap(userSnapshot.value);
          setState(() {
            userName = userData['username']?.toString() ?? 'User';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadUserAvatar() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await _database.child('users/$userId').get();
      if (snapshot.exists) {
        final data = _convertToStringMap(snapshot.value);
        setState(() {
          _currentAvatarUrl = data['avatarUrl']?.toString();
        });
      }
    } catch (e) {
      print('Error loading user avatar: $e');
    }
  }

  Future<void> _loadNewProjectMatches() async {
    try {
      setState(() {
        isLoadingProjects = true;
      });

      // Get recent open projects (limit to 5 for home screen)
      final allProjects = await _projectService.getAllProjects(status: 'open');

      setState(() {
        newProjectMatches = allProjects.take(2).toList();
        isLoadingProjects = false;
      });
    } catch (e) {
      setState(() {
        isLoadingProjects = false;
      });
      print('Error loading project matches: $e');
    }
  }

  Future<void> _loadPortfolioProjects() async {
    try {
      setState(() {
        isLoadingPortfolio = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Load from the same structure as PortfolioPage
        final portfolioSnapshot = await _database
            .child('portfolios')
            .child(userId)
            .get();

        if (portfolioSnapshot.exists) {
          final portfolioData = _convertToStringMap(portfolioSnapshot.value);
          List<Map<String, dynamic>> projects = [];

          // Check if there are projects in the portfolio
          if (portfolioData.containsKey('projects')) {
            final projectsData = portfolioData['projects'];

            if (projectsData is List) {
              // Handle as List
              for (int i = 0; i < projectsData.length; i++) {
                final projectData = _convertToStringMap(projectsData[i]);
                if (projectData.isNotEmpty) {
                  projects.add({
                    'title': projectData['title']?.toString() ?? 'Untitled Project',
                    'subtitle': projectData['completionDate']?.toString() ?? 'Unknown Date',
                    'image': projectData['imageUrl']?.toString() ?? 'assets/images/placeholder.jpg',
                    'description': projectData['description']?.toString() ?? '',
                  });
                }
              }
            } else if (projectsData is Map) {
              // Handle as Map (if stored as key-value pairs)
              final projectsMap = _convertToStringMap(projectsData);
              projectsMap.forEach((key, value) {
                final projectData = _convertToStringMap(value);
                projects.add({
                  'title': projectData['title']?.toString() ?? 'Untitled Project',
                  'subtitle': projectData['completionDate']?.toString() ?? 'Unknown Date',
                  'image': projectData['imageUrl']?.toString() ?? 'assets/images/placeholder.jpg',
                  'description': projectData['description']?.toString() ?? '',
                });
              });
            }
          }

          setState(() {
            portfolioProjects = projects;
            isLoadingPortfolio = false;
          });
        } else {
          setState(() {
            portfolioProjects = [];
            isLoadingPortfolio = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoadingPortfolio = false;
      });
      print('Error loading portfolio projects: $e');
    }
  }

  Future<void> _refreshAllData() async {
    await Future.wait([
      _loadUserData(),
      _loadUserAvatar(),
      _loadPortfolioProjects(),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshAllData();
  }

  Map<String, dynamic> _convertToStringMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  String _getProjectImage(String projectType) {
    switch (projectType.toLowerCase()) {
      case 'new construction':
        return "assets/images/Modern Villa.jpg";
      case 'renovation':
      case 'renovation/remodeling':
        return "assets/images/Urban Cafe.jpg";
      case 'interior design':
        return "assets/images/Boutique.jpg";
      case 'commercial':
        return "assets/images/Nexus Office.jpg";
      default:
        return "assets/images/Modern Villa.jpg";
    }
  }

  String _formatBudget(String budget) {
    if (!budget.toLowerCase().contains('pkr') && !budget.contains('\$')) {
      return '\$$budget';
    }
    return budget;
  }

  String _calculateTimeline(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return '6-8 months'; // Default
    }

    final months = endDate.difference(startDate).inDays / 30;
    return '${months.round()} months';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 0.25, // Adjust border width as needed
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                imageUrl: _cloudinaryService.getOptimizedImageUrl(
                                  _currentAvatarUrl!,
                                  width: 112,
                                  height: 112,
                                ),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B8E23)),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, $userName',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${DateTime.now().day} ${_getMonthName(DateTime.now().month)}, ${DateTime.now().year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          ),
                        ],
                      ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        children: [
                          Switch(
                            value: isAvailable,
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (value) {
                              setState(() {
                                isAvailable = value;
                              });
                            },
                          ),
                          const Text(
                            'Available',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Status Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.0,
                    children: [
                      _buildStatusCard(
                        context: context,
                        isProgress: true,
                        progressValue: 0.75,
                        title: 'Portfolio',
                        subtitle: 'Completion',
                        onTap: () {
                          final navState = NavigationStateWidget.of(context);
                          if (navState != null) {
                            navState.updateSelectedIndex(4);
                          }
                        }

                      ),
                      _buildStatusCard(
                        context: context,
                        icon: 'file-list',
                        iconColor: Theme.of(context).colorScheme.secondary,
                        title: '4 Bids',
                        subtitle: 'Active',
                        onTap: () {
                          Navigator.pushNamed(context, '/bid-list');
                        }
                      ),
                      _buildStatusCard(
                        context: context,
                        icon: 'message',
                        iconColor: Theme.of(context).colorScheme.primary,
                        title: '7 New',
                        subtitle: 'Messages',
                        onTap: () {
                          final navState = NavigationStateWidget.of(context);
                          if (navState != null) {
                            navState.updateSelectedIndex(3);
                          }
                        }
                      ),
                      _buildStatusCard(
                        context: context,
                        icon: 'active',
                        iconColor: Theme.of(context).colorScheme.secondary,
                        title: '3 Active',
                        subtitle: 'Projects',
                        onTap: () {
                          final navState = NavigationStateWidget.of(context);
                          if (navState != null) {
                          navState.updateSelectedIndex(3);
                          }
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Quick Access
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.3,
                    children: [
                      _buildQuickAccessButton(
                          buttonColor: Theme.of(context).colorScheme.secondaryFixed,
                          context: context,
                          icon: 'gallery',
                          label: 'Portfolio',
                          onPressed: () {
                            // Stay on home screen (index 0)
                            final navState = NavigationStateWidget.of(context);
                            if (navState != null) {
                              navState.updateSelectedIndex(4);
                            }
                          }
                      ),
                      _buildQuickAccessButton(
                          buttonColor: Theme.of(context).colorScheme.tertiary,
                          context: context,
                          icon: 'search',
                          label: 'Find Projects',
                          onPressed: () {
                            // Navigate to Find Projects (index 1)
                            final navState = NavigationStateWidget.of(context);
                            if (navState != null) {
                              navState.updateSelectedIndex(1);
                            }
                          }
                      ),
                      _buildQuickAccessButton(
                          buttonColor: Theme.of(context).colorScheme.tertiaryFixed,
                          context: context,
                          icon: 'message',
                          label: 'Messages',
                          onPressed: () {
                            // Navigate to Messages (index 3)
                            final navState = NavigationStateWidget.of(context);
                            if (navState != null) {
                              navState.updateSelectedIndex(3);
                            }
                          }
                      ),
                      _buildQuickAccessButton(
                          buttonColor: Theme.of(context).colorScheme.tertiaryFixedDim,
                          context: context,
                          icon: 'calendar',
                          label: 'Availability',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AvailabilityScreen(),
                              ),
                            );
                          }
                      )
                    ],
                  ),
                ],
              ),
            ),

            // Project Matches
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Project Matches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isLoadingProjects)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (newProjectMatches.isEmpty)
                    Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No new project matches at the moment. Check back later!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...newProjectMatches.map((project) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildProjectCard(
                        context: context,
                        title: project.title,
                        location: project.location,
                        image: _getProjectImage(project.type),
                        budget: _formatBudget(project.budget),
                        timeline: _calculateTimeline(project.startDate, project.endDate),
                        type: project.type,
                        projectId: project.id,
                      ),
                    )),
                ],
              ),
            ),

            // Recent Messages
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Messages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMessageCard(
                    name: 'Emily Richardson',
                    image: 'https://via.placeholder.com/100x100',
                    message: "Hi Farjaad, I've reviewed your proposal for the lakeside villa project and I have a few questions...",
                    time: '2h ago',
                    hasUnread: false,
                  ),
                  const SizedBox(height: 12),
                  _buildMessageCard(
                    name: 'Robert Thompson',
                    image: 'https://via.placeholder.com/100x100',
                    message: 'Thanks for submitting your bid. When would you be available to discuss the project timeline in more detail?',
                    time: 'Yesterday',
                    hasUnread: true,
                  ),
                ],
              ),
            ),

            // Portfolio Preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Portfolio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoadingPortfolio)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                        children: [
                          ...portfolioProjects.map((project) => _buildPortfolioItem(
                            image: project['image'] ?? 'assets/images/placeholder.jpg',
                            title: project['title'] ?? 'Untitled Project',
                            subtitle: project['subtitle'] ?? 'Unknown Date',
                          )),
                          _buildAddPortfolioItem(context),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Bottom padding to account for the tab bar
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    bool isProgress = false,
    double progressValue = 0.0,
    String icon = 'default',
    Color? iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (isProgress)
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      strokeWidth: 4,
                    ),
                    Text(
                      '${(progressValue * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                child: Center(
                  child: SvgIcon(
                    iconName: icon,
                    color: iconColor,
                    size: 34,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildQuickAccessButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onPressed,
    Color? buttonColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[500]!, width: 0.2),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SvgIcon(
                iconName: icon,
                color: Colors.white,
                size: 34
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required BuildContext context,
    required String title,
    required String location,
    required String image,
    required String budget,
    required String timeline,
    required String type,
    String? projectId,
  }) {
    bool isBookmarked = false;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return IconButton(
                      icon: SvgIcon(
                        iconName: isBookmarked ? 'bookmark-fill' : 'bookmark',
                        color: isBookmarked
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey[400],
                      ),
                      onPressed: () {
                        setState(() {
                          isBookmarked = !isBookmarked;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    image,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgIcon(
                              iconName: 'money-dollar',
                              color: Colors.grey[600]!,
                              size: 18
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child:Text(
                              budget,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgIcon(
                              iconName: 'calendar',
                              color: Colors.grey[600]!,
                              size: 18
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeline,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgIcon(
                              iconName: 'building',
                              color: Colors.grey[600]!,
                              size: 18
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                          child: Text(
                            type,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (projectId != null) {
                    final project = newProjectMatches.firstWhere((p) => p.id == projectId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(project: project),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required String name,
    required String image,
    required String message,
    required String time,
    required bool hasUnread,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioItem({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 128,
            width: double.infinity,
            child: image.startsWith('assets/')
                ? Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                    size: 40,
                  ),
                );
              },
            )
                : Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: image.startsWith('assets/') || image.contains('placeholder')
                      ? Image.asset(
                    _getProjectImage('default'), // Use your existing method
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        _getProjectImage('default'),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPortfolioItem(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.primary,
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgIcon(
                iconName: 'add',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Project',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}