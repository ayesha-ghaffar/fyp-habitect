import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../svg_icon.dart';
import 'client_dashboard_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? username;
  bool isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 16),
            _buildSectionTitle('Quick Access'),
            _buildQuickActions(),
            const SizedBox(height: 32),
            _buildArchitectsSection(),
            const SizedBox(height: 32),
            _buildProjectsSection(),
            const SizedBox(height: 32),
            _buildSectionTitle('Project Management'),
            _buildMenuCards(),
            const SizedBox(height: 32),
            _buildSectionTitle('Account & Profile'),
            _buildAccountMenuCards(),
            const SizedBox(height: 48), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF4EBD0),
                radius: 28,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/100x100',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${username ?? 'Client'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'May 24, 2025',
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
          const SizedBox(height: 24),
          _buildWelcomeCard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              'Ready to See Your Ideas Take Shape? Begin Here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4EBD0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
              child: const Text(
                'Start Creating',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ],
        ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: () {},
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
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
        childAspectRatio: 1.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildQuickAccessButton(
            buttonColor: Theme.of(context).colorScheme.tertiaryFixedDim,
            icon: 'add',
            label: 'Post Project',
            onPressed: () => Navigator.pushNamed(context, '/post-project'),
          ),
          _buildQuickAccessButton(
            buttonColor: Theme.of(context).colorScheme.tertiary,
            icon: 'search',
            label: 'Find Architects',
            onPressed: () => Navigator.pushNamed(context, '/search-architects'),
          ),
          _buildQuickAccessButton(
            buttonColor: Theme.of(context).colorScheme.tertiaryFixed,
            icon: 'message',
            label: 'Messages',
            onPressed: () {
              final navState = ClientNavigationStateWidget.of(context);
              if (navState != null) {
                navState.updateSelectedIndex(2);
              }
            },
          ),
          _buildQuickAccessButton(
            buttonColor: Theme.of(context).colorScheme.secondaryFixed,
            icon: 'file-list',
            label: 'My Projects',
            onPressed: () {
              final navState = ClientNavigationStateWidget.of(context);
              if (navState != null) {
                navState.updateSelectedIndex(1);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required Color buttonColor,
    required String icon,
    required String label,
    required VoidCallback onPressed,
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
          SvgIcon(
            iconName: icon,
            color: Colors.white,
            size: 34,
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

  Widget _buildMenuCards() {
    final List<Map<String, dynamic>> items = [
      {
        'icon': 'file-list',
        'title': 'Track Projects',
        'description': 'Monitor your ongoing projects',
        'onTap': () {
          Navigator.pushNamed(context, '/track-project');
        },
      },
      {
        'icon': 'gallery',
        'title': 'View 3D Model',
        'description': 'Review and approve designs',
        'onTap': () {
          Navigator.pushNamed(context, '/view-3d-model');
        },
      },
      {
        'icon': 'money-dollar',
        'title': 'Payments & Transactions',
        'description': 'Manage project payments',
        'onTap': () {
          Navigator.pushNamed(context, '/payments');
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
        'icon': 'user',
        'title': 'Personal Account Settings',
        'description': 'Update your profile information',
        'onTap': () {
          final navState = ClientNavigationStateWidget.of(context);
          if (navState != null) {
            navState.updateSelectedIndex(3);
          }
        },
      },
      {
        'icon': 'calendar',
        'title': 'Transaction History',
        'description': 'View past payments and receipts',
        'onTap': () {
          Navigator.pushNamed(context, '/transaction-history');
        },
      },
      {
        'icon': 'star',
        'title': 'Reviews & Ratings',
        'description': 'Rate architects and view feedback',
        'onTap': () {
          // Navigate to reviews
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
    required String icon,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgIcon(
                iconName: icon,
                color: Theme.of(context).colorScheme.background,
                size: 20,
              ),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: SvgIcon(
            iconName: 'arrow-right',
            size: 24,
            color: Colors.grey[600],
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
                image: 'assets/images/Modern Villa.jpg',
                title: 'Modern Lakeside Villa',
                architect: 'Architect: Sarah Johnson',
                progress: 0.65,
              ),
              _buildProjectCard(
                image: 'assets/images/Urban Cafe.jpg',
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
    required String image,
    required String title,
    required String architect,
    required double progress,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.asset(
              image,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'In Progress - ${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
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
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(right: 10),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(
                  iconName: 'star',
                  color: const Color(0xFFFFD700),
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  rating,
                  style: const TextStyle(
                    fontSize: 12,
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