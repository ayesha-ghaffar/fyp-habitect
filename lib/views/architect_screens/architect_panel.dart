import 'package:flutter/material.dart';
import 'package:fyp/views/svg_icon.dart';
import 'architect_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAvailable = true;

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
                              const Text(
                                'Welcome back, Michael',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'May 16, 2025',
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
                            navState.updateSelectedIndex(0);
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
                            // Stay on home screen for now (index 0)
                            // You could create a dedicated availability screen later
                            final navState = NavigationStateWidget.of(context);
                            if (navState != null) {
                              navState.updateSelectedIndex(0);
                            }
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
                  _buildProjectCard(
                    context: context,
                    title: 'Modern Lakeside Villa',
                    location: 'Boston, MA',
                    image: 'assets/images/Modern Villa.jpg',
                    budget: '\$250,000 - \$350,000',
                    timeline: '6-8 months',
                    type: 'Residential, New Construction',
                  ),
                  const SizedBox(height: 12),
                  _buildProjectCard(
                    context: context,
                    title: 'Urban Café Renovation',
                    location: 'Cambridge, MA',
                    image: 'assets/images/Urban Cafe.jpg',
                    budget: '\$75,000 - \$120,000',
                    timeline: '3-4 months',
                    type: 'Commercial, Renovation',
                  ),
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
                    message: "Hi Michael, I've reviewed your proposal for the lakeside villa project and I have a few questions...",
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
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                      children: [
                        _buildPortfolioItem(
                          image: 'assets/images/Hillside Residence.jpg',
                          title: 'Hillside Residence',
                          subtitle: 'Residential, 2024',
                        ),
                        _buildPortfolioItem(
                          image: 'assets/images/Nexus Office.jpg',
                          title: 'Nexus Office Space',
                          subtitle: 'Commercial, 2023',
                        ),
                        _buildPortfolioItem(
                          image: 'assets/images/Boutique.jpg',
                          title: 'Meridian Boutique Hotel',
                          subtitle: 'Hospitality, 2023',
                        ),
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
                          Text(
                            budget,
                            style: const TextStyle(fontSize: 12),
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
                onPressed: () {},
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
            child: Image.asset(
              image,
              fit: BoxFit.cover,
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