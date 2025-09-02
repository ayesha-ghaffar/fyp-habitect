import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp/services/cloudinary_service.dart';
import '../../services/auth_service.dart';
import 'profile_settings_screen.dart';
import 'package:fyp/views/svg_icon.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onRefreshNeeded;

  const ProfilePage({
    super.key,
    this.onRefreshNeeded,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final databaseRef = FirebaseDatabase.instance.ref();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  User? get user => _authService.currentUser;

  // User data
  String name = '';
  String username = '';
  String email = '';
  String phone = '';
  String? dateOfBirth;
  String gender = '';
  bool isLoading = true;
  String? profileImageUrl;
  String? avatarUrl; // Added for Cloudinary avatar URL
  File? localProfileImage;

  @override
  void initState() {
    super.initState(); // Initialize with current image
    _loadUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    await _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final snapshot = await databaseRef.child('users/${user!.uid}').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        setState(() {
          name = data['name']?.toString() ?? user!.displayName ?? 'User';
          username = data['username']?.toString() ?? '';
          phone = data['phoneNumber']?.toString() ?? '';
          dateOfBirth = data['dateOfBirth']?.toString();
          gender = _capitalizeGender(data['gender']?.toString() ?? '');
          profileImageUrl = data['profileImageUrl']?.toString();
          avatarUrl = data['avatarUrl']?.toString(); // Load avatar URL
        });
      } else {
        setState(() {
          name = user!.displayName ?? 'User';
        });
      }

      email = user!.email ?? '';
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _capitalizeGender(String genderFromDB) {
    switch (genderFromDB.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return '';
    }
  }

  Widget _buildProfileImage() {
    // Check if we have an avatar URL from Cloudinary first, then fall back to profileImageUrl
    final imageUrl = avatarUrl ?? profileImageUrl;

    if (localProfileImage != null) {
      return Image.file(
        localProfileImage!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl != null
            ? _cloudinaryService.getOptimizedImageUrl(
          avatarUrl!,
          width: 160,
          height: 160,
        )
            : imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
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
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        // Cover area with solid color
        Container(
          height: 130,
          width: double.infinity,
          color: const Color(0xFFF9F9F7),
        ),
        // Profile content
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  // Profile Picture - updated to use new method
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
                      borderRadius: BorderRadius.circular(40),
                      child: _buildProfileImage(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name and other text content
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Username
                        if (username.isNotEmpty)
                          Text(
                            '@$username',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B8E23),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Email
                        Text(
                          email,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEEEEEE),
      ),
      child: const Icon(
        Icons.person,
        size: 40,
        color: Color(0xFF999999),
      ),
    );
  }

  Widget _buildQuickInfo() {
    List<Map<String, String>> infoItems = [];

    if (phone.isNotEmpty) {
      infoItems.add({'icon': 'phone', 'label': 'Phone', 'value': phone});
    }
    if (gender.isNotEmpty) {
      infoItems.add({'icon': 'user', 'label': 'Gender', 'value': gender});
    }
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      infoItems.add({'icon': 'calendar', 'label': 'Birth Date', 'value': _formatDate(dateOfBirth)});
    }

    if (infoItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          ...infoItems.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SvgIcon(
                  iconName: item['icon']!,
                  size: 16,
                  color: const Color(0xFF666666),
                ),
                const SizedBox(width: 12),
                Text(
                  item['label']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  item['value']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildAccountMenuCards() {
    final List<Map<String, dynamic>> items = [
      {
        'icon': 'user',
        'title': 'Personal Account Settings',
        'description': 'Update your personal information',
        'onTap': () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileSettingsScreen(
                currentProfileImage: localProfileImage,
                onProfileImageChanged: (File? newImage) {
                  setState(() {
                    localProfileImage = newImage;
                  });
                  // Also notify the parent (main screen)
                },
              ),
            ),
          );

          // Reload user profile when returning from settings to get updated avatar URL
          if (result != null || mounted) {
            await _loadUserProfile();
            // Notify parent to refresh other screens
            if (widget.onRefreshNeeded != null) {
              widget.onRefreshNeeded!();
            }
          }
        },
      },
      {
        'icon': 'schedule',
        'title': 'Your Activity',
        'description': 'View your recent activities and history',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity page coming soon!')),
          );
        },
      },
      {
        'icon': 'notification',
        'title': 'Notification Settings',
        'description': 'Manage your notification preferences',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification settings coming soon!')),
          );
        },
      },
      {
        'icon': 'star',
        'title': 'Reviews & Ratings',
        'description': 'Rate architects and view feedback',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reviews page coming soon!')),
          );
        },
      },
      {
        'icon': 'help',
        'title': 'Help & Support',
        'description': 'Get help and contact support',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Help & Support coming soon!')),
          );
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildMenuCard(
            icon: item['icon'],
            title: item['title'],
            description: item['description'],
            onTap: item['onTap'],
          )).toList(),
        ],
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      DateTime date;
      if (RegExp(r'^\d+$').hasMatch(dateString)) {
        date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateString));
      } else {
        date = DateTime.parse(dateString);
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B8E23)),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadUserProfile,
        color: const Color(0xFF6B8E23),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 8),
              _buildQuickInfo(),
              // Divider
              Divider(color: Colors.grey.shade200, thickness: 8),
              const SizedBox(height: 8),
              _buildAccountMenuCards(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}