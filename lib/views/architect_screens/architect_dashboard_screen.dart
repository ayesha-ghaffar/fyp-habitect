import 'package:flutter/material.dart';
import '../svg_icon.dart';
import 'architect_portfolio_screen.dart';
import 'find_projects_screen.dart';
import 'architect_panel.dart';

// Main container widget that manages navigation
class ArchitectDashboard extends StatefulWidget {
  const ArchitectDashboard({super.key});

  @override
  State<ArchitectDashboard> createState() => _ArchitectDashboardState();
}

class _ArchitectDashboardState extends State<ArchitectDashboard> {
  int _selectedIndex = 0;

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),
    const FindProjects(),
    const Placeholder(), // Projects screen
    const Placeholder(), // Messages screen
    const PortfolioPage(), // Profile/My screen
  ];

  // Method to update the selected index - expose this to child widgets
  void updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
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
          IconButton(
            icon: SvgIcon(iconName: 'notification'),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF4EBD0),
              radius: 16,
              backgroundImage: const NetworkImage(
                'https://via.placeholder.com/80x80',
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
              label: 'My',
            ),
          ],
        ),
      ],
    );
  }
}