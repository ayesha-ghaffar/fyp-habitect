import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({Key? key}) : super(key: key);

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final user = FirebaseAuth.instance.currentUser;
  String? username;
  bool isLoading = true;
  int _selectedIndex = 0;

  // Define the color scheme
  final ColorScheme _colorScheme = ColorScheme.light(
    primary: const Color(0xFF6B8E23),
    secondary: const Color(0xFFE2725B),
    secondaryFixed: const Color(0xFFBDC6C2),
    tertiary: const Color(0xFFDCB287),
    tertiaryFixed: const Color(0xFF9E897B),
    tertiaryFixedDim: const Color(0xFFB5855B),
    surface: Colors.white,
    background: const Color(0xFFF9F9F7),
  );

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child("users/${user!.uid}/username");
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          username = snapshot.value.toString();
          isLoading = false;
        });
      } else {
        setState(() {
          username = "Client";
          isLoading = false;
        });
      }
    } else {
      setState(() {
        username = "Guest";
        isLoading = false;
      });
    }
  }

  Future<void> confirmLogout() async {
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
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _colorScheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _colorScheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              _buildSectionTitle('Quick Actions'),
              _buildQuickActions(),
              _buildSectionTitle('Project Management'),
              _buildMenuCards(),
              _buildSectionTitle('Account & Profile'),
              _buildAccountMenuCards(),
              _buildProjectsSection(),
              _buildArchitectsSection(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _colorScheme.surface,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _colorScheme.secondaryFixed,
                  child: ClipOval(
                    child: Image.network(
                      'https://via.placeholder.com/40',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username ?? 'Client',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Client Account',
                      style: TextStyle(
                        fontSize: 12,
                        color: _colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_none, color: _colorScheme.onSurface),
                      onPressed: () {
                        // Handle notifications
                      },
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _colorScheme.secondary, // Notification badge color
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '3', // Example notification count
                          style: TextStyle(
                            color: _colorScheme.onSecondary,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'profile_settings') {
                      navigateToProfile();
                    } else if (value == 'logout') {
                      confirmLogout();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'profile_settings',
                      child: Text('Profile Settings', style: TextStyle(color: _colorScheme.onSurface)),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout', style: TextStyle(color: _colorScheme.onSurface)),
                    ),
                  ],
                  icon: Icon(Icons.menu, color: _colorScheme.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _colorScheme.primary, // Using primary color
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ready to See Your Ideas Take Shape? Begin Here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _colorScheme.onPrimary, // Text color on primary background
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorScheme.onPrimary,
              foregroundColor: _colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: const Text(
              'Start Creating',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showViewAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _colorScheme.onSurface,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: _colorScheme.primary, // Using primary color
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildActionCard(
            icon: Icons.add,
            title: 'Post Project',
            onTap: () {
              Navigator.pushNamed(context, '/post-project');
            },
          ),
          _buildActionCard(
            icon: Icons.search,
            title: 'Search Architects',
            onTap: () {
              Navigator.pushNamed(context, '/search-architects');
            },
          ),
          _buildActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'Chats',

            onTap: () {
              Navigator.pushNamed(context, '/chatListScreen');
            },
          ),
          _buildActionCard(
            icon: Icons.flag,
            title: 'Uploaded Project',
            progress: 0.65,
            onTap: () {
              Navigator.pushNamed(context, '/uploaded-projects');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    String? badge,
    double? progress,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _colorScheme.primary.withOpacity(0.1), // Using primary color
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: _colorScheme.primary, // Using primary color
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: _colorScheme.onSurface,
                    ),
                  ),
                  if (progress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: 100,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _colorScheme.onSurface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _colorScheme.primary, // Using primary color
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _colorScheme.secondary, // Badge color
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: _colorScheme.onSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCards() {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.list,
        'title': 'Track Projects',
        'description': 'Monitor your ongoing projects',
        'onTap': () {
          // Navigate to project tracking
        },
      },
      {
        'icon': Icons.map,
        'title': 'View 3D Models & Plans',
        'description': 'Review and approve designs',
        'onTap': () {
          // Navigate to models view
        },
      },
      {
        'icon': Icons.star,
        'title': 'AI Recommendations',
        'description': 'Get architect suggestions',
        'onTap': () {
          // Navigate to recommendations
        },
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Payments & Transactions',
        'description': 'Manage project payments',
        'onTap': () {
          // Navigate to payments
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: items.map((item) => _buildMenuCard(
          icon: item['icon'],
          title: item['title'],
          description: item['description'],
          onTap: item['onTap'],
        )).toList(),
      ),
    );
  }

  Widget _buildAccountMenuCards() {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.person,
        'title': 'Personal Account Settings',
        'description': 'Update your profile information',
        'onTap': navigateToProfile,
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Transaction History',
        'description': 'View past payments and receipts',
        'onTap': () {
          // Navigate to transaction history
        },
      },
      {
        'icon': Icons.star,
        'title': 'Reviews & Ratings',
        'description': 'Rate architects and view feedback',
        'onTap': () {
          // Navigate to reviews
        },
      },
      {
        'icon': Icons.image,
        'title': 'Portfolio Gallery',
        'description': 'View your completed projects',
        'onTap': () {
          // Navigate to portfolio
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: items.map((item) => _buildMenuCard(
          icon: item['icon'],
          title: item['title'],
          description: item['description'],
          onTap: item['onTap'],
        )).toList(),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _colorScheme.primary.withOpacity(0.1), // Using primary color
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _colorScheme.primary, // Using primary color
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: _colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: _colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recent Projects', showViewAll: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              _buildProjectCard(
                imageUrl: 'https://via.placeholder.com/320x180',
                title: 'Modern Lakeside Villa',
                architect: 'Architect: Sarah Johnson',
                progress: 0.65,
              ),
              _buildProjectCard(
                imageUrl: 'https://via.placeholder.com/320x180',
                title: 'Urban Loft Renovation',
                architect: 'Architect: Michael Chen',
                progress: 0.30,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard({
    required String imageUrl,
    required String title,
    required String architect,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      architect,
                      style: TextStyle(
                        fontSize: 12,
                        color: _colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'In Progress - ${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: _colorScheme.primary, // Using primary color
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: _colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _colorScheme.primary, // Using primary color
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recommended Architects', showViewAll: true),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              _buildArchitectCard(
                imageUrl: 'https://via.placeholder.com/100',
                name: 'Emma Wilson',
                specialty: 'Modern Residential',
                rating: '4.9',
              ),
              _buildArchitectCard(
                imageUrl: 'https://via.placeholder.com/100',
                name: 'David Park',
                specialty: 'Sustainable Design',
                rating: '4.8',
              ),
              _buildArchitectCard(
                imageUrl: 'https://via.placeholder.com/100',
                name: 'Sophia Rodriguez',
                specialty: 'Interior Architecture',
                rating: '4.7',
              ),
              _buildArchitectCard(
                imageUrl: 'https://via.placeholder.com/100',
                name: 'Robert Johnson',
                specialty: 'Commercial Spaces',
                rating: '4.9',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArchitectCard({
    required String imageUrl,
    required String name,
    required String specialty,
    required String rating,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            specialty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFFFD700), // Gold color for stars
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                rating,
                style: TextStyle(
                  fontSize: 12,
                  color: _colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: _colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: _colorScheme.surface,
        selectedItemColor: _colorScheme.primary, // Using primary color
        unselectedItemColor: _colorScheme.onSurface.withOpacity(0.6),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            backgroundColor: _colorScheme.surface,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.flag),
            label: 'Projects',
            backgroundColor: _colorScheme.surface,
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.chat_bubble_outline),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: _colorScheme.secondary, // Badge color
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '5',
                      style: TextStyle(
                        color: _colorScheme.onSecondary,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Messages',
            backgroundColor: _colorScheme.surface,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile',
            backgroundColor: _colorScheme.surface,
          ),
        ],
      ),
    );
  }
}