import 'package:flutter/material.dart';
import '../svg_icon.dart';
import 'client_home_screen.dart';
import 'uploaded_projects_screen.dart';
import 'profile_screen.dart';
import 'search_architects_screen.dart';
import 'chat_list_screen.dart';

// Main container widget that manages navigation for client
class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _selectedIndex = 0;
  bool _isProfileMenuOpen = false;

  // List of screens for bottom navigation - updated to include search
  final List<Widget> _screens = [
    const ClientHomeScreen(),     // Index 0: Home
    const SearchArchitects(),         // Index 1: Search
    const UploadedProjectsScreen(), // Index 2: Projects
    const ChatListScreen(),     // Index 3: Messages (placeholder)
    const ProfileScreen(),        // Index 4: Profile
  ];

  // Method to update the selected index - expose this to child widgets
  void updateSelectedIndex(int index) {
    print('Updating selected index to: $index');
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleProfileMenu() {
    setState(() {
      _isProfileMenuOpen = !_isProfileMenuOpen;
    });
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
    setState(() {
      _isProfileMenuOpen = false;
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
          Stack(
            children: [
              IconButton(
                icon: SvgIcon(iconName: 'notification'),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Single profile implementation using PopupMenuButton
          PopupMenuButton<String>(
            offset: const Offset(0, 52),
            onSelected: (String value) {
              if (value == 'profile') {
                _navigateToProfile();
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFF4EBD0),
                  radius: 16,
                  backgroundImage: const NetworkImage(
                    'https://via.placeholder.com/80x80',
                  ),
                ),
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
      body: GestureDetector(
        onTap: () {
          if (_isProfileMenuOpen) {
            setState(() {
              _isProfileMenuOpen = false;
            });
          }
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens.map((screen) {
            return ClientNavigationStateWidget(
              updateSelectedIndex: updateSelectedIndex,
              child: screen,
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: ClientCustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: updateSelectedIndex,
      ),
    );
  }
}

// InheritedWidget to pass down navigation state
class ClientNavigationStateWidget extends InheritedWidget {
  final Function(int) updateSelectedIndex;

  const ClientNavigationStateWidget({
    required this.updateSelectedIndex,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  static ClientNavigationStateWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClientNavigationStateWidget>();
  }

  @override
  bool updateShouldNotify(ClientNavigationStateWidget oldWidget) {
    return updateSelectedIndex != oldWidget.updateSelectedIndex;
  }
}

// Custom Bottom Navigation Bar Widget - Updated with Search tab
class ClientCustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const ClientCustomBottomNav({
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
            // Home tab (index 0)
            BottomNavigationBarItem(
              icon: SvgIcon(
                iconName: 'home',
                color: selectedIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
              label: 'Home',
            ),
            // Search tab (index 1) - NEW
            BottomNavigationBarItem(
              icon: SvgIcon(
                iconName: 'search',
                color: selectedIndex == 1
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
              label: 'Search',
            ),
            // Projects tab (index 2)
            BottomNavigationBarItem(
              icon: SvgIcon(
                iconName: 'file-list',
                color: selectedIndex == 2
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[500],
              ),
              label: 'Projects',
            ),
            // Messages tab (index 3)
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  SvgIcon(
                    iconName: 'message',
                    color: selectedIndex == 3
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[500],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              label: 'Messages',
            ),
            // Profile tab (index 4)
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