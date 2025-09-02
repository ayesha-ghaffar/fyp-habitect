import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp/services/cloudinary_service.dart';
import '../svg_icon.dart';
import 'architect_portfolio_screen.dart';
import 'find_projects_screen.dart';
import 'project_management_screen.dart';
import 'architect_panel.dart';
import '../client_screens/chat_list_screen.dart';
import '../client_screens/profile_settings_screen.dart';

// Main container widget that manages navigation
class ArchitectDashboard extends StatefulWidget {
  const ArchitectDashboard({super.key});


  @override
  State<ArchitectDashboard> createState() => _ArchitectDashboardState();
}

class _ArchitectDashboardState extends State<ArchitectDashboard> {
  int _selectedIndex = 0;
  bool _isProfileMenuOpen = false;
  String? _currentAvatarUrl;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final databaseRef = FirebaseDatabase.instance.ref();
  User? get user => FirebaseAuth.instance.currentUser;

  Key _homeScreenKey = UniqueKey();
  Key _portfolioScreenKey = UniqueKey();

  // List of screens for bottom navigation
  List<Widget> get _screens => [
    HomeScreen(key: _homeScreenKey, onRefreshNeeded: _refreshHomeScreen),
    const FindProjects(),
    const ProjectsScreen(),
    const ChatListScreen(),
    PortfolioPage(key: _portfolioScreenKey, onRefreshNeeded: _refreshPortfolioScreen),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  void _refreshPortfolioScreen() {
    setState(() {
      _portfolioScreenKey = UniqueKey();
    });
  }

  // Add method to refresh home screen
  void _refreshHomeScreen() {
    setState(() {
      _homeScreenKey = UniqueKey(); // Force recreation of HomeScreen
    });
  }

// Load user avatar from Firebase
  Future<void> _loadUserAvatar() async {
    if (user == null) return;

    try {
      final snapshot = await databaseRef.child('users/${user!.uid}').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        setState(() {
          _currentAvatarUrl = data['avatarUrl']?.toString();
        });
      }
    } catch (e) {
      print('Error loading user avatar: $e');
    }
  }

  // Method to update the selected index - expose this to child widgets
  void updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Build profile avatar widget
  Widget _buildProfileAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade400,
          width: 0.25,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: _cloudinaryService.getOptimizedImageUrl(
            _currentAvatarUrl!,
            width: 64,
            height: 64,
          ),
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B8E23)),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade300,
            child: const Icon(
              Icons.person,
              size: 20,
              color: Colors.grey,
            ),
          ),
        )
            : Container(
          width: 32,
          height: 32,
          color: Colors.grey.shade300,
          child: const Icon(
            Icons.person,
            size: 20,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgIcon(iconName: 'menu'),
          onPressed: () {},
        ),
        title: Text(
          'Habitect',
          style: TextStyle(
            fontFamily: 'Judson',
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: SvgIcon(iconName: 'notification'),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 52),
            onSelected: (String value) {
              if (value == 'profile') {
                _navigateToProfileSettings();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgIcon(
                      iconName: 'user',
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    const Text('Profile Settings'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildProfileAvatar(),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE0E0E0),
            height: 0.25,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens.map((screen) {
          // Wrap each screen with InheritedWidget to pass down the updateSelectedIndex method
          return NavigationStateWidget(
            updateSelectedIndex: updateSelectedIndex,
            child: screen,
          );
        }).toList(),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: updateSelectedIndex,
      ),
    );
  }

  void _navigateToProfileSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSettingsScreen(
          currentProfileImage: null,
          onProfileImageChanged: null,
        ),
      ),
    );

    // Reload avatar when returning from profile settings
    _loadUserAvatar();

    // Force both HomeScreen and PortfolioPage to refresh
    setState(() {
      _homeScreenKey = UniqueKey(); // This forces HomeScreen to rebuild completely
      _portfolioScreenKey = UniqueKey(); // This forces PortfolioPage to rebuild completely
    });
  }

  void _logout() async {
    final shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout")),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Add your logout logic here
      Navigator.pushReplacementNamed(context, '/login');
    }
    setState(() {
      _isProfileMenuOpen = false;
    });
  }
}

// InheritedWidget to pass down navigation state
class NavigationStateWidget extends InheritedWidget {
  final Function(int) updateSelectedIndex;

  const NavigationStateWidget({
    required this.updateSelectedIndex,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  static NavigationStateWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavigationStateWidget>();
  }

  @override
  bool updateShouldNotify(NavigationStateWidget oldWidget) {
    return updateSelectedIndex != oldWidget.updateSelectedIndex;
  }
}

// Custom Bottom Navigation Bar Widget
class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 0.25,
          color: const Color(0xFFE0E0E0),
        ),
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[500],
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              icon: SvgIcon(
                iconName: 'home',
                color: selectedIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgIcon(
                iconName: 'search',
                color: selectedIndex == 1
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: SvgIcon(
                iconName: 'active',
                color: selectedIndex == 2
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: SvgIcon(
                iconName: 'message',
                color: selectedIndex == 3
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: SvgIcon(
                iconName: 'user',
                color: selectedIndex == 4
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
              label: 'Profile',
            ),
          ],
        ),
      ],
    );
  }
}